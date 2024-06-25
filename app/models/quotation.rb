class Quotation < ApplicationRecord
  has_many :quotation_items, dependent: :destroy
  validates :name, :email, :mobile_number, presence: true
  has_one_attached :pdf
end
