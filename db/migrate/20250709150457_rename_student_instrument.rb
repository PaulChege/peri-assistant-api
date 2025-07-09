class RenameStudentInstrument < ActiveRecord::Migration[8.0]
  def change
    rename_column :students, :instrument, :instruments
  end
end
