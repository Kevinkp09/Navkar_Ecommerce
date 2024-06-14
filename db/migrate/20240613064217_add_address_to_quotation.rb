class AddAddressToQuotation < ActiveRecord::Migration[7.1]
  def change
    add_column :quotations, :address, :text
  end
end
