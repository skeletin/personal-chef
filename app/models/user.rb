class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :username, with: ->(n) { n.to_s.strip.downcase.presence }

  validates :username, presence: true, uniqueness: true, format: {
    with: /\A[a-z0-9._-]+\z/i,
    message: "letters, numbers, dot, hyphen, underscore only"
  }, length: { maximum: 50 }
end
