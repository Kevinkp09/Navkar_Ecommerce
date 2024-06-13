class Product < ApplicationRecord
  has_one_attached :main_image
  has_many_attached :other_images
  has_one_attached :brochure
  belongs_to :category, foreign_key: "category_id"
  has_many :order_items, dependent: :destroy
  has_many :cart_items, dependent: :destroy
end
