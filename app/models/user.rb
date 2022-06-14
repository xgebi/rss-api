class User < ApplicationRecord
  has_secure_password

  validates :password_digest, length: { minimum: 6 }
  validates :username, uniqueness: true, presence: true
end
