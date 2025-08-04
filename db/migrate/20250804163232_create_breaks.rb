class CreateBreaks < ActiveRecord::Migration[8.0]
  def change
    create_table :breaks do |t|
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.references :breakable, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :breaks, [:breakable_type, :breakable_id], name: 'index_breaks_on_breakable_type_and_breakable_id'
    add_index :breaks, :start_date
    add_index :breaks, :end_date
  end
end
