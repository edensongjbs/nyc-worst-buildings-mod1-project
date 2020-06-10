class CreateBuildings < ActiveRecord::Migration[5.2]
  def change
    create_table :buildings do |t|
      t.string :bbl
      t.string :house_number
      t.string :street_name
      t.string :zip
      t.string :building_class
      t.string :story
    end
  end
end
