class AddStatusToStudents < ActiveRecord::Migration[8.0]
  def change
    add_column :students, :status, :integer, default: 0, null: false
  end
end
