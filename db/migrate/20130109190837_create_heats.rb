class CreateHeats < ActiveRecord::Migration
  def change
    create_table :heats do |t|
      t.integer :sequence
      t.string :status

      t.timestamps
    end
  end
end
