class Building < ActiveRecord::Base
    has_many :dob_violations
    has_many :hpd_violations

end
