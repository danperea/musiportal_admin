class User < ApplicationRecord
  has_secure_password

  # Roles are stored as JSONB array for multiple customizable roles
  validates :roles, presence: true

  # Role validation
  VALID_ROLES = %w[musician band venue promoter event_planner producer sound_engineer booking_agent manager songwriter vocalist guitarist bassist drummer keyboardist dj].freeze

  validate :validate_roles_format

  before_validation :ensure_roles_array
  before_save :normalize_email

  def validate_roles_format
    return unless roles.is_a?(Array)

    invalid_roles = roles - VALID_ROLES
    if invalid_roles.any?
      errors.add(:roles, "contains invalid roles: #{invalid_roles.join(', ')}")
    end
  end

  def ensure_roles_array
    self.roles = [] if roles.nil?
    self.roles = Array(roles) unless roles.is_a?(Array)
  end

  # Role helper methods
  def has_role?(role)
    roles.include?(role.to_s)
  end

  def add_role(role)
    role = role.to_s
    return false unless VALID_ROLES.include?(role)
    return false if has_role?(role)

    self.roles = roles + [role]
    save
  end

  def remove_role(role)
    role = role.to_s
    return false unless has_role?(role)

    self.roles = roles - [role]
    save
  end

  def primary_role
    roles.first
  end

  # Group memberships
  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships
  has_many :owned_groups, -> { where("memberships.roles @> ?", ['owner'].to_json) },
           through: :memberships, source: :group
  has_many :admin_groups, -> { where("memberships.roles @> ? OR memberships.roles @> ?", ['admin'].to_json, ['owner'].to_json) },
           through: :memberships, source: :group

  # Active group relationship
  belongs_to :active_group, class_name: 'Group', optional: true

  has_many :gigs, foreign_key: :user_id, dependent: :nullify
  has_many :gig_applications, dependent: :destroy
  has_many :events, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :vibes, length: { maximum: 8 }
  validates :portfolio_videos, length: { maximum: 3 }

  validate :validate_vibes_format
  validate :validate_portfolio_videos_format

  # Group-related methods
  def member_of?(group)
    memberships.exists?(group: group, status: 'active')
  end

  def admin_of?(group)
    membership = memberships.find_by(group: group, status: 'active')
    return false unless membership
    membership.has_role?('admin') || membership.has_role?('owner')
  end

  def owner_of?(group)
    membership = memberships.find_by(group: group, status: 'active')
    return false unless membership
    membership.has_role?('owner')
  end

  def join_group(group, roles: ['member'])
    return false if member_of?(group)

    roles = Array(roles) # Ensure roles is an array

    memberships.create!(
      group: group,
      roles: roles,
      status: 'active',
      joined_at: Time.current
    )
  end

  def leave_group(group)
    membership = memberships.find_by(group: group, status: 'active')
    return false unless membership

    membership.deactivate!
  end

  def active_memberships
    memberships.active.includes(:group)
  end

  # Active group methods
  def set_active_group(group)
    return false unless member_of?(group)

    update(active_group: group)
  end

  def clear_active_group
    update(active_group: nil)
  end

  def has_active_group?
    active_group.present?
  end

  def active_group_type
    active_group&.type
  end

  def vibes_list
    vibes&.join(', ') || ''
  end

  def validate_vibes_format
    return unless vibes.is_a?(Array)

    invalid_vibes = vibes - Group::VALID_VIBES
    if invalid_vibes.any?
      errors.add(:vibes, "contains invalid vibes: #{invalid_vibes.join(', ')}")
    end
  end

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end

  def validate_portfolio_videos_format
    return unless portfolio_videos.is_a?(Array)

    portfolio_videos.each_with_index do |video, index|
      next unless video.is_a?(Hash)

      unless video['url'].present? && video['url'] =~ URI::DEFAULT_PARSER.make_regexp(['http', 'https'])
        errors.add(:portfolio_videos, "video at position #{index + 1} must have a valid URL")
      end

      # Validate genres
      if video['genres'].present?
        unless video['genres'].is_a?(Array)
          errors.add(:portfolio_videos, "video at position #{index + 1} genres must be an array")
        else
          valid_genre_names = Genre.pluck(:name)
          invalid_genres = video['genres'] - valid_genre_names
          if invalid_genres.any?
            errors.add(:portfolio_videos, "video at position #{index + 1} has invalid genres: #{invalid_genres.join(', ')}")
          end
        end
      end

      # Validate vibes
      if video['vibes'].present?
        unless video['vibes'].is_a?(Array)
          errors.add(:portfolio_videos, "video at position #{index + 1} vibes must be an array")
        else
          invalid_vibes = video['vibes'] - Group::VALID_VIBES
          if invalid_vibes.any?
            errors.add(:portfolio_videos, "video at position #{index + 1} has invalid vibes: #{invalid_vibes.join(', ')}")
          end
        end
      end
    end
  end

  def as_json(options = {})
    json = super(options.merge(
      except: [:password_digest],
      methods: [:vibes_list, :portfolio_video_data]
    ))
    # Include active_group with proper serialization
    if active_group.present?
      json['active_group'] = active_group.as_json
    end
    json
  end

  def portfolio_video_data
    require_relative '../helpers/videos_helper'
    helper = Object.new.extend(VideosHelper)

    videos = []

    portfolio_videos.each do |video_hash|
      video_data = helper.video_embed_data(video_hash['url'])
      if video_data
        videos << video_data.merge(
          title: video_hash['title'] || video_data[:title],
          description: video_hash['description']
        )
      end
    end

    videos
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "email", "location", "bio", "phone", "created_at", "updated_at", "active_group_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["groups", "events", "memberships", "active_group"]
  end
end

