class Promoter < Group
  # Promoter-specific validations
  validates :location, presence: true

  # Promoter-specific methods
  def promoted_events
    events.where('starts_at > ?', Time.current)
  end

  def active_promotions
    promoted_events.where('starts_at > ? AND starts_at < ?', Time.current, 3.months.from_now)
  end

  def booking_available?
    verified? && active? && location.present?
  end

  # Override search to include promoter-specific terms
  def search_text
    super + ' promoter promotion booking agent manager events shows concerts'
  end

  def self.in_area(location)
    where("location ILIKE ?", "%#{location}%")
  end
end