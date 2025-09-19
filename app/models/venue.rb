class Venue < Group
  # Venue-specific validations
  validates :location, presence: true

  # Venue-specific methods
  def capacity
    # This could be extracted from description or stored in a separate field
    description&.match(/capacity[:\s]*(\d+)/i)&.[](1)&.to_i
  end

  def booking_contact
    owner || admins.first
  end

  def available_for_events?
    verified? && active? && location.present?
  end

  # Override search to include venue-specific terms
  def search_text
    super + ' venue space hall club bar restaurant booking events'
  end

  def self.with_capacity(min_capacity)
    # This is a simple implementation - in a real app you'd want a dedicated capacity field
    where("description ILIKE '%capacity%' AND description ~ '\\d+'")
  end
end