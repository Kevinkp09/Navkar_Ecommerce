class AddCategoryIdToProducts < ActiveRecord::Migration[7.1]
  def change
    add_reference :products, :category, null: false, foreign_key: true
    remove_reference :categories, :product, index: true, foreign_key: true
  end
end
