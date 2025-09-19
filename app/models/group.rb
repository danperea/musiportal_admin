class Group < ApplicationRecord
  # Single Table Inheritance
  self.inheritance_column = :type

  # Soft delete
  scope :active, -> { where(deleted_at: nil) }

  # Associations
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :gigs, dependent: :destroy
  has_many :events, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :type, presence: true, inclusion: { in: %w[Band Venue Promoter EventPlanner Festival] }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(['http', 'https']) }, allow_blank: true
  validates :genres, length: { maximum: 5 }
  validates :vibes, length: { maximum: 8 }
  validates :demo_video_url, format: { with: URI::DEFAULT_PARSER.make_regexp(['http', 'https']) }, allow_blank: true
  validates :featured_videos, length: { maximum: 5 }

  # Valid vibes list
  VALID_VIBES = %w[chill rowdy dance pool beachy surf funny moody calm relaxed technical funky energetic upbeat mellow groovy jazzy soulful experimental ambient acoustic electric].freeze

  validate :validate_vibes_format
  validate :validate_featured_videos_format

  # Scopes
  scope :by_type, ->(type) { where(type: type) }
  scope :verified, -> { where(verified: true) }
  scope :with_genres, ->(genres) { where('genres && ARRAY[?]::varchar[]', genres) }
  scope :with_vibes, ->(vibes) { where('vibes && ARRAY[?]::varchar[]', vibes) }
  scope :near_location, ->(location, radius = 50) {
    # This would need proper geocoding setup
    where("location ILIKE ?", "%#{location}%")
  }

  # Instance methods
  def owner
    memberships.where("roles @> ?", ['owner'].to_json).first&.user
  end

  def admins
    memberships.where("roles @> ? OR roles @> ?", ['admin'].to_json, ['owner'].to_json).includes(:user).map(&:user)
  end

  def members
    memberships.where(status: 'active').includes(:user).map(&:user)
  end

  def add_member(user, roles: ['member'])
    roles = Array(roles) # Ensure roles is an array
    memberships.create!(
      user: user,
      roles: roles,
      status: 'active',
      joined_at: Time.current
    )
  end

  def remove_member(user)
    membership = memberships.find_by(user: user)
    return false unless membership

    membership.update!(
      status: 'inactive',
      left_at: Time.current
    )
  end

  def member?(user)
    memberships.exists?(user: user, status: 'active')
  end

  def admin?(user)
    memberships.where(user: user, status: 'active')
               .where("roles @> ? OR roles @> ?", ['admin'].to_json, ['owner'].to_json)
               .exists?
  end

  def soft_delete!
    update!(deleted_at: Time.current)
    memberships.update_all(deleted_at: Time.current)
  end

  def active?
    deleted_at.nil?
  end

  def genre_list
    genres&.join(', ') || ''
  end

  def vibes_list
    vibes&.join(', ') || ''
  end

  def search_text
    [name, bio, description, location, genre_list, vibes_list, type].compact.join(' ').downcase
  end

  def validate_vibes_format
    return unless vibes.is_a?(Array)

    invalid_vibes = vibes - VALID_VIBES
    if invalid_vibes.any?
      errors.add(:vibes, "contains invalid vibes: #{invalid_vibes.join(', ')}")
    end
  end

  def validate_featured_videos_format
    return unless featured_videos.is_a?(Array)

    featured_videos.each_with_index do |video, index|
      next unless video.is_a?(Hash)

      unless video['url'].present? && video['url'] =~ URI::DEFAULT_PARSER.make_regexp(['http', 'https'])
        errors.add(:featured_videos, "video at position #{index + 1} must have a valid URL")
      end

      # Validate genres
      if video['genres'].present?
        unless video['genres'].is_a?(Array)
          errors.add(:featured_videos, "video at position #{index + 1} genres must be an array")
        else
          valid_genre_names = Genre.pluck(:name)
          invalid_genres = video['genres'] - valid_genre_names
          if invalid_genres.any?
            errors.add(:featured_videos, "video at position #{index + 1} has invalid genres: #{invalid_genres.join(', ')}")
          end
        end
      end

      # Validate vibes
      if video['vibes'].present?
        unless video['vibes'].is_a?(Array)
          errors.add(:featured_videos, "video at position #{index + 1} vibes must be an array")
        else
          invalid_vibes = video['vibes'] - VALID_VIBES
          if invalid_vibes.any?
            errors.add(:featured_videos, "video at position #{index + 1} has invalid vibes: #{invalid_vibes.join(', ')}")
          end
        end
      end
    end
  end

  # Class methods
  def self.search(query)
    return all if query.blank?

    where(
      "LOWER(CONCAT(name, ' ', COALESCE(bio, ''), ' ', COALESCE(description, ''), ' ', COALESCE(location, ''), ' ', COALESCE(genres #>> '{}', ''), ' ', type)) LIKE ?",
      "%#{query.downcase}%"
    )
  end

  def self.types
    %w[Band Venue Promoter EventPlanner Festival]
  end

  # Convert to API JSON format
  def as_json(options = {})
    json = super(options.merge(
      except: [:deleted_at],
      methods: [:genre_list, :vibes_list, :member_count, :video_data]
    ))
    # Ensure type field is included for frontend display
    json['type'] = self.type
    json
  end

  def video_data
    require_relative '../helpers/videos_helper'
    helper = Object.new.extend(VideosHelper)

    videos = []

    # Add demo video
    if demo_video_url.present?
      demo_data = helper.video_embed_data(demo_video_url)
      videos << demo_data.merge(video_category: 'demo') if demo_data
    end

    # Add featured videos
    featured_videos.each do |video_hash|
      video_data = helper.video_embed_data(video_hash['url'])
      if video_data
        videos << video_data.merge(
          video_category: 'featured',
          title: video_hash['title'] || video_data[:title],
          description: video_hash['description']
        )
      end
    end

    videos
  end

  private

  def member_count
    memberships.where(status: 'active').count
  end
end