# frozen_string_literal: true

class CreateStudents < ActiveRecord::Migration[5.0]
  def change
    create_table :students do |t|
      t.string :name
      t.string :email
      t.string :instrument
      t.date :start_date
      t.string :institution
      t.string :mobile_number
      t.integer :lesson_day
      t.time :lesson_time
      t.text :goals
      t.references :user
      t.timestamps
    end
  end
end
