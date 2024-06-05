class ChangeFeaturesAndSpecialFeaturesToJsonbInProducts < ActiveRecord::Migration[7.1]
  def change
    remove_column :products, :features, :string
    remove_column :products, :special_features, :string
    add_column :products, :features, :jsonb, default: []
    add_column :products, :special_features, :jsonb, default: []
  end
end
