class AddInstiutionIdToStudent < ActiveRecord::Migration[8.0]
  def change
    add_reference :students, :institution, foreign_key: true

    remove_column :students, :institution, :string
  end
end
