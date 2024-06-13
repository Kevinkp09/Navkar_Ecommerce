class Order < ApplicationRecord
  belongs_to :user
  belongs_to :courier, optional: :true
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  validates :status, presence: true
end
