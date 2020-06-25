class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :password_digest
      t.string :referral_token
      t.bigint :referral_id
 
      t.timestamps
    end
  end
end
