class Gig < ApplicationRecord
  belongs_to :user
  belongs_to :event, optional: true
  has_many :gig_applications, dependent: :destroy

  enum :status, { open: 0, closed: 1, filled: 2 }

  validates :title, presence: true
end

