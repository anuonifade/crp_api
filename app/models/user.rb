class User < ApplicationRecord
  has_secure_password
  has_many :rewards, dependent: :destroy
  belongs_to :referral, :class_name => 'User', optional: true
  has_many :users, :foreign_key => 'referral_id'

  VALID_EMAIL_FORMAT = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :password_digest, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_FORMAT }
end
