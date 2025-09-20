class Event < ApplicationRecord
  belongs_to :user
  belongs_to :group, optional: true
  has_many :gigs, dependent: :nullify

  validates :title, presence: true
  validates :date, presence: true
  validates :time, presence: true
  validates :location, presence: true
  validates :event_type, presence: true, inclusion: { in: ['performance', 'practice', 'recording'] }

  scope :for_group, ->(group) { where(group: group) }
  scope :without_group, -> { where(group: nil) }

  def gig_count
    gigs.count
  end

  def associated_groups
    gigs.joins(:user).joins('JOIN memberships ON memberships.user_id = users.id')
        .joins('JOIN groups ON groups.id = memberships.group_id')
        .where('memberships.status = ?', 'active')
        .select('DISTINCT groups.*')
  end

  def formatted_time
    # Convert 24-hour time to AM/PM format
    # Assumes time is stored as string in format "HH:MM"
    return time unless time.present?

    begin
      # Parse the time string and format it
      parsed_time = Time.parse(time)
      parsed_time.strftime("%-I:%M %p")
    rescue ArgumentError
      # If parsing fails, return the original time
      time
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "title", "date", "time", "location", "description", "event_type", "user_id", "group_id", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user", "group", "gigs"]
  end
end
