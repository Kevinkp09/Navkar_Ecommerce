class Order < ApplicationRecord
  belongs_to :user
  belongs_to :courier, optional: :true
  belongs_to :coupon, optional: :true
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  enum status: {"pending": 0, "transit": 1, "delivered": 2}
end
