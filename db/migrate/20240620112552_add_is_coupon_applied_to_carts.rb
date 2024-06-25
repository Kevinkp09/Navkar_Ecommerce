class AddIsCouponAppliedToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :is_coupon_applied, :boolean, :default => false
  end
end
