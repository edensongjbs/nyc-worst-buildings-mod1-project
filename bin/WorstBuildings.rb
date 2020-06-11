require 'pry'
require_relative '../run2.rb'


    $prompt = TTY::Prompt.new
    $table = Terminal::Table.new
    $a = Artii::Base.new :font => 'slant'


def run
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

def makeBuildingTable(worstBuildings)
    table = Terminal::Table.new     
    table.title = "Top #{worstBuildings.count} Worst Buildings" 
    table.headings = ['Ranking',"HPD\nViolations","DOB\nViolations" ,'Address', 'Borough', 'Zip Code',"Block #", "Lot #"]

    worstBuildings.each_with_index do |building,index|
        table.add_row  [index+1,building.hpd_violations.count,0, building.address ,building.borough,building.zip,building.block,building.lot]
        index == worstBuildings.length - 1 ? break : table.add_separator
    end
    puts table
    violationInfo(worstBuildings)
end


def violationInfo(worstBuildings)
    more_info = $prompt.select("Do you want more information about a building?", %w(Yes No))
    while more_info == "Yes"
        building_num = $prompt.ask("Enter The Number of The Building:") 
        index = building_num.to_i - 1
        makeViolationTable(worstBuildings[index].hpd_violations, building_num)
        more_info = $prompt.select("Do you want more information about a building?", %w(Yes No))    
    end
end

def makeViolationTable(violations, building_num)
    table = Terminal::Table.new 
    table.title = "All Violations For Building ##{building_num}"
    table.headings = ['Issue Date',"ViolationID","Status"]


    violations.sort_by{|violation| violation.issue_date}.each_with_index do |violation,index|
        table.add_row  [violation.issue_date[0..9], violation.violation_num, violation.status]
        index == violations.length - 1 ? break : table.add_separator
    end
    puts table
end

def runner
    puts $a.asciify("Find The Worst Buildings")
    makeBuildingTable(run)
end

runner




