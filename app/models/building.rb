class Building < ActiveRecord::Base
    has_many :dob_violations
    has_many :hpd_violations

    def self.sort_worst
        Building.all.sort{|building1, building2| building1.hpd_violations.count <=> building2.hpd_violations.count}.reverse
        # Building.all.map{|building| building.hpd_violations.count}
    end

    def address
        self.house_number + " " + self.street_name
    end

    def borough
        boroughs = ["", "Manhattan","Bronx","Brooklyn","Queens","Staten Island"]
        boroughs[self.bbl[0].to_i]
    end

    def block
        self.bbl[1..5]
    end

    def lot
        self.bbl[6..]
    end

end
