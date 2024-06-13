class AddAmountToCoupon < ActiveRecord::Migration[7.1]
  def change
    add_column :coupons, :amount, :integer
  end
end
