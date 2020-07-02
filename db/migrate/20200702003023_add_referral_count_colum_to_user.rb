class AddReferralCountColumToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :referral_count, :integer, :default => 0
  end
end
