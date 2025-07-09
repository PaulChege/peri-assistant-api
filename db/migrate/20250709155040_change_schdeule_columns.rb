class ChangeSchdeuleColumns < ActiveRecord::Migration[8.0]
  def change
    remove_column :students, :lesson_day, :integer
    remove_column :students, :lesson_time, :time
    remove_column :students, :lesson_duration, :integer
    remove_column :students, :lesson_charge, :integer

    add_column :students, :schedule, :jsonb, default: []
    add_column :students, :lesson_unit_charge, :integer, default: 0
  end
end