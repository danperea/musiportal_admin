class Band < Group
  # Band-specific validations
  validates :genres, presence: true, length: { minimum: 1, maximum: 5 }

  # Band-specific scopes
  scope :covers_only, -> { where("description ILIKE '%covers%' OR bio ILIKE '%covers%'") }
  scope :originals_only, -> { where.not("description ILIKE '%covers%' OR bio ILIKE '%covers%'") }

  # Band-specific methods
  def primary_genre
    genres&.first
  end

  def covers_band?
    description&.downcase&.include?('covers') || bio&.downcase&.include?('covers')
  end

  def available_for_gigs?
    verified? && active? && genres.present?
  end

  # Override search to include band-specific terms
  def search_text
    super + ' musician band music live performance'
  end
  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "bio", "location", "created_at", "updated_at", "type", "description", "website", "email", "phone", "verified", "image_url", "genres", "latitude", "longitude", "vibes", "zipCode", "demo_video_url", "featured_videos", "group_pictures", "video_data", "deleted_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["users", "memberships", "events", "gigs"]
  end
end
