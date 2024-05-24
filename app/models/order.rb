class Order < ApplicationRecord
  belongs_to :user, class_name: "User", foreign_key: "user_id"
  belongs_to :courier
  validates :status, :total_price, presence: true
  enum status: {pending: 0, transit: 1, delivered: 2}
end
