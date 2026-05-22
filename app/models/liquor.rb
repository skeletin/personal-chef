class Liquor < ApplicationRecord
  has_one_attached :photo

  PHOTO_CONTENT_TYPES = %w[image/jpeg image/png image/webp].freeze
  PHOTO_MAX_SIZE = 5.megabytes
  COMPARISON_NOTE_MAX = 600
  COMPARISON_URL_MAX = 2000

  validates :name, presence: true, uniqueness: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :typical_store_price, numericality: { greater_than: 0 }, allow_nil: true
  validates :comparison_note, length: { maximum: COMPARISON_NOTE_MAX }, allow_blank: true
  validates :comparison_url, length: { maximum: COMPARISON_URL_MAX }, allow_blank: true
  validate :photo_must_be_acceptable, if: -> { photo.attached? }
  validate :comparison_url_must_be_http_https, if: -> { comparison_url.present? }

  normalizes :name, with: ->(n) { n.to_s.strip }
  normalizes :category, with: ->(c) { c.to_s.strip.presence }

  scope :alphabetical, -> { order(Arel.sql("LOWER(liquors.name)")) }

  before_validation :cleanup_comparison_fields

  # Difference: positive means customer saves vs curated shelf benchmark.
  def shelf_savings_vs_typical
    return nil unless typical_store_price.present?

    typical_store_price.to_d - price.to_d
  end

  def comparison_public_visible?
    typical_store_price.present? || comparison_note.present? || comparison_url.present?
  end

  private

    def cleanup_comparison_fields
      self.typical_store_price = nil if typical_store_price.respond_to?(:blank?) && typical_store_price.blank?
      self.typical_store_price = nil if typical_store_price.is_a?(Numeric) && typical_store_price.to_d.zero?
      self.comparison_note = comparison_note.to_s.strip.presence
      self.comparison_url = comparison_url.to_s.strip.presence
    end

    def comparison_url_must_be_http_https
      uri = URI.parse(comparison_url.to_s)

      unless uri.is_a?(URI::HTTP) && uri.host.present?
        errors.add(:comparison_url, "must be a valid http(s) link")
      end
    rescue URI::InvalidURIError
      errors.add(:comparison_url, "must be a valid http(s) link")
    end

    def photo_must_be_acceptable
      unless PHOTO_CONTENT_TYPES.include?(photo.content_type.to_s.downcase.strip)
        errors.add(:photo, "must be a JPEG, PNG, or Webp image.")
        return
      end

      blob = photo.blob
      return if blob.blank?

      if blob.byte_size > PHOTO_MAX_SIZE
        errors.add(:photo, "must be #{ActiveSupport::NumberHelper.number_to_human_size(PHOTO_MAX_SIZE)} or smaller.")
      end
    end
end
