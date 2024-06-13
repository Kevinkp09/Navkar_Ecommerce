class AddBestsellerFeaturedToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :bestseller, :boolean
    add_column :products, :featured, :boolean
  end
end
