class CreateHpdViolations < ActiveRecord::Migration[5.2]
  def change
    create_table :hpd_violations do |t|
      t.string :novdescription
      t.string :issue_date
      t.striing :status_id
      t.string :status
      t.string :novid
      t.string :building_id
    end
  end
end
