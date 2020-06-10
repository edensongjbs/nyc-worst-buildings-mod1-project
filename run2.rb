require_relative './config/environment'
# gem ‘tty-prompt’

def add_leading_zeros(string, total_chars)
    num_zeros = total_chars-string.length
    if num_zeros > 0
        num_zeros.times {string = '0'+string}
    end
    return string
end

def standardize_identifier(results) # iterate through array
    # and create new key standard_id that from the borough block and lot #'s
    # 10 digits total (1 for boro, 5 for block, 4 for lot)
    results.each do |result|
        boro = result["boroid"]
        block = add_leading_zeros(result["block"], 5)
        lot=result["lot"] = add_leading_zeros(result["lot"], 4)
        result["bbl"]=boro+block+lot
    end  
end

def find_building_from_result(result)
    Building.all.find {|building| building.bbl==result["bbl"]}
end

def create_building_from_result(result) # needs more parameters
    Building.create(
        bbl: result["bbl"],
        house_number: result["housenumber"],
        street_name: result["streetname"],
        zip: result["zip"],
        building_class: result["class"],
        story: result["story"],
    )
end

def create_hpd_violation_from_result_and_building(result, building)
    violation = HpdViolation.create(
      novdescription: result["novdescription"],
      issue_date: result["novissuedate"],
      status_id: result["currentstatusid"],
      status: result["currentstatus"],
      novid: result["novid"],
      violation_num: result["violationid"],
      building_id: building.id
    )
    building.hpd_violations << violation
end

def create_dob_violation_from_result_and_building(result, building)
    violation = DobViolation.create(
      violation_category: result["violation_category"],
      violation_type: result["violations_type"],
      issue_date: result["issue_date"],
      disposition_date: result["disposition_date"],
      disposition_comments: result["disposition_comments"],
      dob_violation_num: result["violation_number"],
      building_id: building.id
    )
    building.dob_violations << violation
end

def create_buildings_and_hpd_violations(results) #iterates through standardized results and adds new building
    # when it encounters a new blocklot that's not already in Building.all
    results.each do |result|
        found_building=find_building_from_result(result)
        if !found_building
            found_building=create_building_from_result(result)
        end
        create_hpd_violation_from_result_and_building(result, found_building)
    end
end

def get_worst_buildings(num) # 
    Building.sort_worst.take(num)
end

#  url = "https://data.cityofnewyork.us/resource/wvxf-dwi5.json"
#  response = HTTParty.get(url)

#  binding.pry
#  0
