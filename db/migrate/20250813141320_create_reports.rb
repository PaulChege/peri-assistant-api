class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.text :summary, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.references :student, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :reports, :start_date
    add_index :reports, :end_date
    add_index :reports, [:start_date, :end_date]
    
    # Add check constraint to ensure end_date is after start_date
    add_check_constraint :reports, "end_date > start_date", name: "check_end_date_after_start_date"
  end
end
