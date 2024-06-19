class Order < ApplicationRecord
  belongs_to :user
  belongs_to :courier, optional: :true
  belongs_to :coupon, optional: :true
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  enum status: {"Pending": 0, "In Transit": 1, "Out for Delivery": 2, "Delivered": 3}
  enum payment_status: {"pending": 0, "paid": 1}
end
