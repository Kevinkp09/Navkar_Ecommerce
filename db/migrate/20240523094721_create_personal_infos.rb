class CreatePersonalInfos < ActiveRecord::Migration[7.1]
  def change
    create_table :personal_infos do |t|
      t.string :trade_name
      t.string :pan_no
      t.string :cin_no
      t.string :bank_name
      t.string :account_name
      t.string :account_no
      t.string :ifsc
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
