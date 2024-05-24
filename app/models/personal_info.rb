class PersonalInfo < ApplicationRecord
  belongs_to :user
  validates :logo, :cin_no, :bank_name, :account_name, :account_no, :branch_name, :ifsc, :trade_name, :pan, presence: true, if: :admin?
  has_one_attached :logo
  has_one_attached :hero_image
  has_many_attached :testimonial
  def admin?
    user.role == "admin"
  end
end
