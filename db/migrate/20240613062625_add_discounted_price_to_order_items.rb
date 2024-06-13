class AddDiscountedPriceToOrderItems < ActiveRecord::Migration[7.1]
  def change
    add_column :order_items, :discounted_price, :decimal
  end
end
