class QuotationItem < ApplicationRecord
  belongs_to :quotation
  belongs_to :product
  validates :quantity, :discount, :price, presence: true
end
