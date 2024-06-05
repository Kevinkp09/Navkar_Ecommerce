class ChangeMobileApplicationToProducts < ActiveRecord::Migration[7.1]
  def change
    change_column :products, :mobile_application, :boolean, using: 'mobile_application::boolean'
  end
end
