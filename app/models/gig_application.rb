class GigApplication < ApplicationRecord
  belongs_to :gig
  belongs_to :user
  belongs_to :group, optional: true

  enum :status, { pending: 0, accepted: 1, declined: 2, withdrawn: 3 }

  validates :offer_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Validation to ensure user is a member of the group when applying on behalf of group
  validate :user_must_be_group_member, if: :group_id?

  private

  def user_must_be_group_member
    return unless group && user

    unless user.member_of?(group)
      errors.add(:group, "User must be a member of the group to apply on its behalf")
    end
  end
end

