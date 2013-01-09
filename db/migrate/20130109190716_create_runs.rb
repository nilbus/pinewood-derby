class CreateRuns < ActiveRecord::Migration
  def change
    create_table :runs do |t|
      t.integer :contestant_id
      t.integer :heat_id
      t.decimal :time
      t.integer :lane

      t.timestamps
    end
  end
end
