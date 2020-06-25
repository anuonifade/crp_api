class Reward < ApplicationRecord
  belongs_to :user

  validates :amount, presence: true
end
