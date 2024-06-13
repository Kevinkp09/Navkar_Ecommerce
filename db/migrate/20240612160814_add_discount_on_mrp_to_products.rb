class AddDiscountOnMrpToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :discount_on_mrp, :decimal
    change_column :products, :discount, :decimal
  end
end
