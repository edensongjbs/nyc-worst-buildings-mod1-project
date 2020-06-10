class Building < ActiveRecord::Base
    has_many :dob_violations
    has_many :hpd_violations
    def self.sort_worst
        Building.all.sort{|building1, building2| building1.hpd_violations.count <=> building2.hpd_violations.count}.reverse
        # Building.all.map{|building| building.hpd_violations.count}
    end
end
