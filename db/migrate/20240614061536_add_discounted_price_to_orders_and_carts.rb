class AddDiscountedPriceToOrdersAndCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :total_price, :decimal
    add_column :carts, :discounted_price, :decimal
    add_column :orders, :discounted_price, :decimal

  end
end
