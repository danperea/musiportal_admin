class Vibe < ApplicationRecord
  belongs_to :created_by, class_name: 'User'

  validates :name, presence: true, uniqueness: true

  # Similarities where this vibe is the source
  has_many :source_similarities, as: :source, class_name: 'Similarity', dependent: :destroy

  # Similarities where this vibe is the target
  has_many :target_similarities, as: :target, class_name: 'Similarity', dependent: :destroy

  # Get all vibes similar to this one
  def similar_vibes
    similar_vibe_ids = source_similarities.where(target_type: 'Vibe').pluck(:target_id) +
                      target_similarities.where(source_type: 'Vibe').pluck(:source_id)
    Vibe.where(id: similar_vibe_ids.uniq)
  end

  # Get all genres similar to this vibe
  def similar_genres
    similar_genre_ids = source_similarities.where(target_type: 'Genre').pluck(:target_id) +
                       target_similarities.where(source_type: 'Genre').pluck(:source_id)
    Genre.where(id: similar_genre_ids.uniq)
  end

  # Get all items (vibes and genres) similar to this vibe
  def similar_items
    {
      vibes: similar_vibes,
      genres: similar_genres
    }
  end

  # Add similarity to another vibe or genre
  def add_similarity(target_item, user)
    return false if target_item == self

    # Check if similarity already exists (in either direction)
    existing = Similarity.where(
      "(source_type = ? AND source_id = ? AND target_type = ? AND target_id = ?) OR " \
      "(source_type = ? AND source_id = ? AND target_type = ? AND target_id = ?)",
      self.class.name, self.id, target_item.class.name, target_item.id,
      target_item.class.name, target_item.id, self.class.name, self.id
    ).exists?

    return false if existing

    Similarity.create!(
      source: self,
      target: target_item,
      created_by: user
    )
  end

  # Remove similarity with another vibe or genre
  def remove_similarity(target_item)
    Similarity.where(
      "(source_type = ? AND source_id = ? AND target_type = ? AND target_id = ?) OR " \
      "(source_type = ? AND source_id = ? AND target_type = ? AND target_id = ?)",
      self.class.name, self.id, target_item.class.name, target_item.id,
      target_item.class.name, target_item.id, self.class.name, self.id
    ).destroy_all
  end

  scope :search, ->(query) { where("name ILIKE ?", "%#{query}%") if query.present? }
  scope :recent, -> { order(created_at: :desc) }

  def as_json(options = {})
    super(options.merge(
      include: {
        created_by: { only: [:id, :name] }
      }
    ))
  end
end