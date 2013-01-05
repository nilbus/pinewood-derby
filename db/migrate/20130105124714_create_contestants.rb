class CreateContestants < ActiveRecord::Migration
  def change
    create_table :contestants do |t|
      t.string :name
      t.boolean :retired

      t.timestamps
    end
  end
end
