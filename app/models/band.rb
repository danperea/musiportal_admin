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
end