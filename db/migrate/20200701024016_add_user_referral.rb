class AddUserReferral < ActiveRecord::Migration[6.0]
  def change
    add_index :users, :referral_id, null: true
    add_foreign_key :users, :users, column: :referral_id
  end
end
