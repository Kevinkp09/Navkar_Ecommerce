class AddUuidToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :uuid, :string
  end
end
