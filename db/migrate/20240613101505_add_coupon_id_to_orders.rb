class AddCouponIdToOrders < ActiveRecord::Migration[7.1]
  def change
    add_reference :orders, :coupon, foreign_key: true
  end
end
