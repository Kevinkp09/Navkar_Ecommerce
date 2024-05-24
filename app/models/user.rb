class User < ApplicationRecord
  validates :name, :email, :mobile_number, :delivery_address, :pincode, :city, :state, presence: true
  validates :gst_number, presence: true, if: :customer?
  has_one :personal_info
  has_many :orders
  has_one_attached :logo

  def customer?
    user.role == "customer"
  end
end
