class AddDiscountedTotalPriceToQuotations < ActiveRecord::Migration[7.1]
  def change
    add_column :quotations, :discounted_total_price, :decimal
  end
end
