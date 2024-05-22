class ChangeNamesToProducts < ActiveRecord::Migration[7.1]
  def change
    rename_column :products, :model_name, :product_model_name
    rename_column :products, :model_no, :product_model_no
  end
end
