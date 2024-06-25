class Page < ApplicationRecord
  has_many_attached :client_logos
  has_many_attached :images
end
