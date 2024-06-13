class RemoveCouponFromProducts < ActiveRecord::Migration[7.1]
  def change
    remove_column :products, :coupon_name
    remove_column :products, :coupon_discount
  end
end
