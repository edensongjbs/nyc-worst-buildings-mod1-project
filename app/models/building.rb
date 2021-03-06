class Building < ActiveRecord::Base
    has_many :dob_violations
    has_many :hpd_violations
    @@HPD_IGNORE_STATUS = ["3", "4", "9", "19", "36"]
    @@DOB_IGNORE_STATUS = ["v*-dob violation - dismissed", "v*-dob violation - resolved", "vh*-violation hazardous dismissed", "vp*-violation unserved ecb- dismissed", "vpw*-violation unserved ecb-work without permit-dismissed", "vwh*-violation work w/out pmt hazardous dismissed", "vw*-violation - work w/o permit dismissed"]

    def self.sort_worst(ic=false)
            worst=Building.all.sort{|building1, building2| building1.hpd_violations_ignore_closed(ic).count <=> building2.hpd_violations_ignore_closed(ic).count}.reverse
            # worstBuilding.all.sort{|building1, building2| building1.hpd_violations.count <=> building2.hpd_violations.count}.reverse
    end

    def hpd_violations_ignore_closed(ic=false)  
        if ic
            violations=hpd_violations.reject {|violation| @@HPD_IGNORE_STATUS.include?(violation.status_id)}
        else
            violations=self.hpd_violations
        end
        return violations
    end

    def dob_violations_ignore_closed(ic=false)
        if ic
            violations=dob_violations.reject {|violation| @@DOB_IGNORE_STATUS.include?(violation.violation_category.downcase)}
        else
            violations=self.dob_violations
        end
        return violations
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
