class Product < ApplicationRecord
  has_one_attached :main_image
  has_many_attached :other_images
  has_one_attached :brochure
  belongs_to :category, foreign_key: "category_id"
  belongs_to :order, class_name: "order", foreign_key: "order_id", optional: true
end
