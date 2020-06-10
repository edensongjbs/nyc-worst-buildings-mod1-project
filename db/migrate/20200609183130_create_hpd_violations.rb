class CreateHpdViolations < ActiveRecord::Migration[5.2]
  def change
    create_table :hpd_violations do |t|
      t.string :novdescription
      t.string :issue_date
      t.string :status_id
      t.string :status
      t.string :novid
      t.string :violation_num
      t.integer :building_id
    end
  end
end
