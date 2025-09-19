class Festival < Group
  # Festival-specific validations
  validates :location, presence: true
  validates :description, presence: true

  # Festival-specific methods
  def festival_events
    events.where('starts_at > ?', Time.current)
  end

  def upcoming_festivals
    festival_events.where('starts_at > ? AND starts_at < ?', Time.current, 1.year.from_now)
  end

  def accepting_submissions?
    verified? && active? && upcoming_festivals.any?
  end

  def festival_genres
    genres.present? ? genres : ['Multi-Genre']
  end

  def duration_days
    # Could extract from description or have dedicated fields
    description&.match(/(\d+)[- ]day/i)&.[](1)&.to_i || 1
  end

  # Override search to include festival-specific terms
  def search_text
    super + ' festival music fest concert series lineup artists performers'
  end

  def self.with_genre(genre)
    with_genres([genre])
  end

  def self.accepting_applications
    joins(:events).where('events.starts_at > ?', Time.current).distinct
  end
end