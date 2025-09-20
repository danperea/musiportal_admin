class Membership < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :group

  # Validations
  validates :user_id, uniqueness: { scope: :group_id, message: "is already a member of this group" }
  validates :roles, presence: true
  validates :status, inclusion: { in: %w[active inactive pending] }

  # Role validation for memberships
  VALID_GROUP_ROLES = %w[member admin owner founder lead_guitarist rhythm_guitarist bassist drummer vocalist keyboardist sound_tech manager producer booking_agent promoter venue_manager event_coordinator].freeze

  validate :validate_roles_format

  before_validation :ensure_roles_array

  def validate_roles_format
    return unless roles.is_a?(Array)

    invalid_roles = roles - VALID_GROUP_ROLES
    if invalid_roles.any?
      errors.add(:roles, "contains invalid roles: #{invalid_roles.join(', ')}")
    end
  end

  def ensure_roles_array
    self.roles = [] if roles.nil?
    self.roles = Array(roles) unless roles.is_a?(Array)
    self.roles = ['member'] if roles.empty?
  end

  # Callbacks
  before_create :set_joined_at, if: -> { status == 'active' }
  before_update :set_left_at, if: -> { status_changed? && status == 'inactive' }

  # Scopes
  scope :active, -> { where(status: 'active', deleted_at: nil) }
  scope :inactive, -> { where(status: 'inactive') }
  scope :pending, -> { where(status: 'pending') }
  scope :admins, -> { where("roles @> ? OR roles @> ?", ['admin'].to_json, ['owner'].to_json) }
  scope :owners, -> { where("roles @> ?", ['owner'].to_json) }
  scope :members_only, -> { where("roles @> ? AND NOT (roles @> ? OR roles @> ?)", ['member'].to_json, ['admin'].to_json, ['owner'].to_json) }

  # Instance methods
  def activate!
    update!(
      status: 'active',
      joined_at: Time.current,
      left_at: nil
    )
  end

  def deactivate!
    update!(
      status: 'inactive',
      left_at: Time.current
    )
  end

  def soft_delete!
    update!(deleted_at: Time.current)
  end

  def active?
    status == 'active' && deleted_at.nil?
  end

  # Role helper methods
  def has_role?(role)
    roles.include?(role.to_s)
  end

  def add_role(role)
    role = role.to_s
    return false unless VALID_GROUP_ROLES.include?(role)
    return false if has_role?(role)

    self.roles = roles + [role]
    save
  end

  def remove_role(role)
    role = role.to_s
    return false unless has_role?(role)
    return false if roles.length <= 1 # Must have at least one role

    self.roles = roles - [role]
    save
  end

  def primary_role
    roles.first
  end

  def admin?
    has_role?('admin') || has_role?('owner')
  end

  def owner?
    has_role?('owner')
  end

  def can_manage_group?
    admin? && active?
  end

  def can_invite_members?
    admin? && active?
  end

  def can_remove_members?
    admin? && active?
  end

  def can_edit_group?
    admin? && active?
  end

  def membership_duration
    return nil unless joined_at

    end_time = left_at || Time.current
    ((end_time - joined_at) / 1.day).round
  end

  # Class methods
  def self.for_user_and_group(user, group)
    find_by(user: user, group: group)
  end

  def self.active_memberships
    active.includes(:user, :group)
  end

  # Convert to API JSON format
  def as_json(options = {})
    super(options.merge(
      except: [:deleted_at],
      include: {
        user: { only: [:id, :name, :email] },
        group: { only: [:id, :name, :type] }
      },
      methods: [:membership_duration]
    ))
  end

  private

  def set_joined_at
    self.joined_at = Time.current if joined_at.blank?
  end

  def set_left_at
    self.left_at = Time.current if left_at.blank?
  end
  def self.ransackable_attributes(auth_object = nil)
    ["id", "user_id", "group_id", "status", "roles", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user", "group"]
  end
end
