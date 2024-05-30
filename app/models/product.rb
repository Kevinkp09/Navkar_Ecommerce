class Product < ApplicationRecord
  has_one_attached :main_image
  has_many_attached :other_images
  belongs_to :category, class_name: "category", foreign_key: "category_id"
end
