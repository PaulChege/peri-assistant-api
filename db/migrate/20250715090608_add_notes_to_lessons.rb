class AddNotesToLessons < ActiveRecord::Migration[8.0]
  def change
    add_column :lessons, :notes, :text
  end
end
