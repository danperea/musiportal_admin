class Similarity < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  belongs_to :source, polymorphic: true
  belongs_to :target, polymorphic: true

  validates :source_type, presence: true, inclusion: { in: %w[Genre Vibe] }
  validates :target_type, presence: true, inclusion: { in: %w[Genre Vibe] }
  validates :source_id, presence: true
  validates :target_id, presence: true

  # Prevent self-referential similarities
  validate :not_self_referential

  # Prevent duplicate similarities (bidirectional)
  validates :source_type, uniqueness: {
    scope: [:source_id, :target_type, :target_id],
    message: "Similarity already exists"
  }

  # Custom validation to prevent bidirectional duplicates
  validate :no_bidirectional_duplicate

  scope :for_source, ->(source) { where(source: source) }
  scope :for_target, ->(target) { where(target: target) }
  scope :between_types, ->(source_type, target_type) {
    where(source_type: source_type, target_type: target_type)
  }

  private

  def not_self_referential
    if source_type == target_type && source_id == target_id
      errors.add(:target, "cannot be the same as source")
    end
  end

  def no_bidirectional_duplicate
    return unless source_type.present? && target_type.present? && source_id.present? && target_id.present?

    # Check for reverse similarity
    reverse_exists = Similarity.where(
      source_type: target_type,
      source_id: target_id,
      target_type: source_type,
      target_id: source_id
    ).where.not(id: id).exists?

    if reverse_exists
      errors.add(:base, "Reverse similarity already exists")
    end
  end

  def as_json(options = {})
    super(options.merge(
      include: {
        source: { only: [:id, :name] },
        target: { only: [:id, :name] },
        created_by: { only: [:id, :name] }
      }
    ))
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "created_by_id", "id", "id_value", "source_id", "source_type", "target_id", "target_type", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["created_by", "source", "target"]
  end
end