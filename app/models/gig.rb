class Gig < ApplicationRecord
  belongs_to :user
  belongs_to :event, optional: true
  has_many :gig_applications, dependent: :destroy

  enum :status, { open: 0, closed: 1, filled: 2 }

  validates :title, presence: true
  def self.ransackable_attributes(auth_object = nil)
    ["id", "title", "description", "genres", "location", "starts_at", "ends_at", "budget_min", "budget_max", "status", "user_id", "event_id", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user", "event", "group", "gig_applications"]
  end
end
