class EventPlanner < Group
  # EventPlanner-specific validations
  validates :location, presence: true

  # EventPlanner-specific methods
  def planned_events
    events.where('starts_at > ?', Time.current)
  end

  def upcoming_events
    planned_events.where('starts_at > ? AND starts_at < ?', Time.current, 6.months.from_now)
  end

  def available_for_planning?
    verified? && active? && location.present?
  end

  def specialties
    # Could extract from description or have dedicated field
    genres.present? ? genres : ['General Events']
  end

  # Override search to include event planner-specific terms
  def search_text
    super + ' event planner planning coordinator wedding corporate private party'
  end

  def self.specializing_in(event_type)
    where("description ILIKE ? OR bio ILIKE ?", "%#{event_type}%", "%#{event_type}%")
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "bio", "location", "created_at", "updated_at", "type", "description", "website", "email", "phone", "verified", "image_url", "genres", "latitude", "longitude", "vibes", "zipCode", "demo_video_url", "featured_videos", "group_pictures", "video_data", "deleted_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["users", "memberships", "events", "gigs"]
  end
end