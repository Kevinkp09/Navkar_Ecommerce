class ChangeTrackingIdToString < ActiveRecord::Migration[7.1]
  def change
    change_column :orders, :tracking_id, :string
  end
end
