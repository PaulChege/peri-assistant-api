class CreateLessons < ActiveRecord::Migration[5.0]
  def change
    create_table :lessons do |t|
      t.references :student
      t.datetime  :time
      t.integer  :duration
      t.timestamps
    end
  end
end
