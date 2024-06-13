class AddDiscountedPriceToQuotationItems < ActiveRecord::Migration[7.1]
  def change
    add_column :quotation_items, :discounted_price, :decimal, :precision => 10, :scale => 2
  end
end
