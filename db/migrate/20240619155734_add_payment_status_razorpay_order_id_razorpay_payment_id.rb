class AddPaymentStatusRazorpayOrderIdRazorpayPaymentId < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :razorpay_order_id, :string
    add_column :orders, :razorpay_payment_id, :string
    add_column :orders, :payment_status, :integer, default: 0
  end
end
