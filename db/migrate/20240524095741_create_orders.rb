class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.integer :status
      t.integer :tracking_id
      t.integer :total_price
      t.references :courier, null: false, foreign_key: true
      t.timestamps
    end
  end
end
