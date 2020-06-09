class CreateBuildings < ActiveRecord::Migration[5.2]
  def change
    create_table :buildings do |t|
      t.integer :bbl
      t.string :house_number
      t.string :street_name
      t.string :zip
      t.string :class
      t.string :story
    end
  end
end
