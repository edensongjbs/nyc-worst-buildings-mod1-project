class CreateDobViolations < ActiveRecord::Migration[5.2]
  def change
    create_table :dob_violations do |t|
      t.string :violation_category
      t.string :violation_type
      t.string :issue_date
      t.string :disposition_date
      t.string :disposition_comments
      t.string :dob_violation_num
      t.integer :building_id
    end
  end
end
