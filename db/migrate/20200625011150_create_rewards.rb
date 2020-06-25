class CreateRewards < ActiveRecord::Migration[6.0]
  def change
    create_table :rewards do |t|
      t.references :user, null: false, foreign_key: true
      t.float :amount
      t.string :status

      t.timestamps
    end
  end
end
