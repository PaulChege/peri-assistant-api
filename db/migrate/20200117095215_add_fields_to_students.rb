# frozen_string_literal: true

class AddFieldsToStudents < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :lesson_duration, :integer
    add_column :students, :lesson_charge, :integer
  end
end
