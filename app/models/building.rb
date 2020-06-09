class Building < ActiveRecord::Base
    has_many :dob_violations
    has_many :hpd_violations
    def self.sort_worst
        Building.all.sort{|building| building.hpd_violations.count}.reverse
    end
end
