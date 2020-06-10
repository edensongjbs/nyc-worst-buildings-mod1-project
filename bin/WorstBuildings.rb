require 'pry'
require_relative '../run2.rb'


    $prompt = TTY::Prompt.new
    $table = Terminal::Table.new

def run
    #violation_type = $prompt.select("Choose by violation type:", %w(HPD DOB))
    zip_codes = []
    $prompt.collect do
        zip_codes << key(:zip).ask('Enter Zip Code:', required: true)  
        while $prompt.yes?("More Zip Codes?")
            zip_codes << key(:zip).ask('Enter Zip Code:')
        end
    end
    string_of_zips = zip_codes.map { |zip| "'" + zip + "'" }.join(",")

    start_date = $prompt.ask("Enter Start Date:",default: '2020-01-01') + "T00:00:00" #Defaults to start of 2020
    end_date = $prompt.ask("Enter End Date:", default:'2021-01-01') + "T00:00:00" #Defaults to end of 2020

    num_buildings = $prompt.ask("Enter Number of Buildings:",default: 10)


    url = "https://data.cityofnewyork.us/resource/wvxf-dwi5.json" 
    url += "?$where=zip in (#{string_of_zips})" 
    url += " AND novissueddate between '#{start_date}' and '#{end_date}'"
    url += "&$limit=100000"


    response = HTTParty.get(url)#.sort_by {|v| v["novissueddate"]}

    Building.destroy_all
    HpdViolation.destroy_all
    create_buildings_and_hpd_violations(response)

    worst = get_worst_buildings(num_buildings.to_i)  
    worst
end

def makeTable(worstBuildings)
    boroughs = ["", "Manhattan","Bronx","Brooklyn","Queens","Staten Island"]
    table = Terminal::Table.new     
    table.title = "Top #{worstBuildings.count} Worst Buildings" 
    table.headings = ['Ranking',"HPD\nViolations","DOB\nViolations" ,'Address', 'Borough', 'Zip Code',"Block #", "Lot #"]

    worstBuildings.each_with_index do |building,index|
        rank = index + 1
        address = building.house_number + " " +building.street_name
        borough = boroughs[building.bbl[0].to_i]
        zip = building.zip
        block = building.bbl[1..5]
        lot = building.bbl[6..]
        violations = building.hpd_violations.count

        table.add_row  [rank,violations,0,address ,borough,zip,block,lot]
        index == worstBuildings.length - 1 ? break : table.add_separator
    end
    puts table

    more_info = $prompt.select("Do you want more information about a building?", %w(Yes No))
    building_num = $prompt.ask("Enter The Number of The Building:") if more_info == "Yes"
    index = building_num.to_i - 1
    #binding.pry
    violationTable(worstBuildings[building_num.to_i - 1].hpd_violations, building_num)
    #binding.pry    
end

def violationTable(violations, building_num)
    table = Terminal::Table.new 
    table.title = "All Violations For Building ##{building_num}"
    table.headings = ['Issue Date',"ViolationID","Status"]

    violations.each_with_index do |violation,index|
        table.add_row  [nil, violation.violation_num, violation.status]
        index == violations.length - 1 ? break : table.add_separator
    end
    puts table

end


#binding.pry

makeTable(run)



