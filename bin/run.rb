require_relative '../config/environment'

def greet_user
end

def display_menu #gives user menu of commands (help)
end

def get_date
end

def get_zip  # user can enter multiple zips, returns an array of zipcodes
end

def get_ignore_closed
end

def get_num_results
end

def send_query(start_date:, end_date:, zipcodes:, ignore_closed?:, uri: )
    # returns arry of JSON hashes of results
end

def standardize_identifier(results) # iterate through array
    # and create new key standard_id that from the borough block and lot #'s
    # 10 digits total (1 for boro, 5 for block, 4 for lot) 
end

def find_building_from_result(result)
    Building.all.find {|building| building.id==result.standard_id}
end

def create_building_from_result(result) # needs more parameters
    Building.create(
    id: result.standard_id,  
    boroid: result.boroid
    )
    ## MUST RETURN THE BUILDING!
end

def create_hpd_violation_from_result_and_building(result, building)
    violation = HpdViolation.create(
        parameters:
    )
    building.hpd_violations << violation
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

# def create_hpd_violations(results) # parameter is a json of results from send_query
#     # iterates through hash and creates many new HpdViolation objects
# end


def get_worst_buildings(num) # 
    Building.sort_worst.take(num)
end

app = WorstBuildings.new
app.run

# url = "https://data.cityofnewyork.us/resource/wvxf-dwi5.json"
# response = HTTParty.get(url)

# binding.pry
# 0
