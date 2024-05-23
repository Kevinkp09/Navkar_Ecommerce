class PersonalInfo < ApplicationRecord
  belongs_to :user
  validates :logo, :cin_no, :bank_name, :account_name, :account_no, :branch_name, :ifsc, :trade_name, :pan, presence: true, if: :admin?

  def admin?
    user.role == "admin"
  end
end
