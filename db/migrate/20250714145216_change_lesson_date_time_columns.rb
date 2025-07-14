class ChangeLessonDateTimeColumns < ActiveRecord::Migration[8.0]
  def up
    # Add new column
    add_column :lessons, :date_time, :datetime

    # Remove old columns
    remove_column :lessons, :day, :date
    remove_column :lessons, :time, :time
  end

  def down
    # Add back old columns
    add_column :lessons, :day, :date
    add_column :lessons, :time, :time

    # Remove new column
    remove_column :lessons, :date_time, :datetime
  end
end
