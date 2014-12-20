class CreateSingleValues < ActiveRecord::Migration
  def change
    create_table :single_values do |t|
      t.string :type
      t.text :value

      t.timestamps
    end
  end
end
