# frozen_string_literal: true

class CreateLessons < ActiveRecord::Migration[5.0]
  def change
    create_table :lessons do |t|
      t.references :student
      t.integer :day
      t.time :time
      t.integer :duration
      t.text :plan
      t.integer :status
      t.integer :charge
      t.boolean :paid
      t.timestamps
    end
  end
end
