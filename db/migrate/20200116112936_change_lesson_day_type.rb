class ChangeLessonDayType < ActiveRecord::Migration[5.0]
  def change
    remove_column :lessons, :day
    add_column :lessons, :day, :date
  end
end
