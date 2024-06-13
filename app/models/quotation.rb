class Quotation < ApplicationRecord
  has_many :quotation_items, dependent: :destroy
  validates :name, :email, :mobile_number, presence: true
end
