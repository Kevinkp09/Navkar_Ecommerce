class ChangeCourierIdInOrders < ActiveRecord::Migration[7.1]
  def change
    change_column_null :orders, :courier_id, true
  end
end
