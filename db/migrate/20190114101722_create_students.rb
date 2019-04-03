class CreateStudents < ActiveRecord::Migration[5.0]
  def change
    create_table :students do |t|
      t.string :name
      t.string :institution
      t.string :mobile_number
      t.references :user
      t.timestamps
    end
  end
end
