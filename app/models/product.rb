class Product < ApplicationRecord
  has_one_attached :main_image
  has_many_attached :other_images
end
