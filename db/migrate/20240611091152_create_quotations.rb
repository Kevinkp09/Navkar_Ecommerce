class CreateQuotations < ActiveRecord::Migration[7.1]
  def change
    create_table :quotations do |t|
      t.string :name
      t.string :email
      t.string :mobile_number
      t.decimal :total_price

      t.timestamps
    end
  end
end
