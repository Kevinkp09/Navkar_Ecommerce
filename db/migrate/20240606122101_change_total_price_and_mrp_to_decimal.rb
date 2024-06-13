class ChangeTotalPriceAndMrpToDecimal < ActiveRecord::Migration[7.1]
  def change
    change_column :orders, :total_price, :decimal, :precision => 10, :scale => 2
    change_column :products, :mrp, :decimal, :precision => 10, :scale => 2

  end
end
