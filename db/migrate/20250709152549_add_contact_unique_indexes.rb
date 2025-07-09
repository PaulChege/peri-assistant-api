class AddContactUniqueIndexes < ActiveRecord::Migration[8.0]
  def change
    add_index :students, [:mobile_number, :user_id], unique: true
    add_index :students, [:email, :user_id], unique: true
  end
end
