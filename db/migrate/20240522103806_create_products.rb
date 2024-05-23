class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :category
      t.string :product_name
      t.string :brand_name
      t.string :model_name
      t.string :connecting_technology
      t.string :mobile_application
      t.string :model_no
      t.string :asin_no
      t.string :country
      t.text :description
      t.string :special_features
      t.string :features
      t.string :warranty
      t.decimal :mrp
      t.string :gst
      t.string :height
      t.string :width
      t.string :depth
      t.string :weight
      t.string :material
      t.integer :discount
      t.string :delivery_time
      t.string :coupon_name
      t.integer :coupon_discount
      t.string :info
      t.timestamps
    end
  end
end
