class CreateSingleValues < ActiveRecord::Migration
  def change
    create_table :single_values do |t|
      t.hstore :value
      t.string :type

      t.timestamps
    end
  end
end
