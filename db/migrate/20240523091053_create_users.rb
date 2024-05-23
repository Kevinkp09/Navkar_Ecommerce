class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password
      t.string :mobile_no
      t.text :delivery_address
      t.string :pin_code
      t.string :city
      t.string :state
      t.string :gst_no
      t.string :role
      t.timestamps
    end
  end
end
