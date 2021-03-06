class WorstBuildings

    $prompt = TTY::Prompt.new
    $prompt = TTY::Prompt.new
    $table = Terminal::Table.new
    $a = Artii::Base.new :font => 'slant'
    attr_accessor :zip_codes, :start_date, :end_date, :string_of_zips, :num_listings, :ignore_closed
    def initialize
        @zip_codes=[]
    end

    def zip_prompt
        q = $prompt.ask('Enter Zip Code:') do |q|
            q.required true
            q.validate(/\d{5}/, 'Invalid zip code')
        end
        q
    end
    
    def get_zips
        zips=[]
        zips << zip_prompt
        while $prompt.yes?("Add Another Zip Code?")
            zips << zip_prompt
        end
        @zip_codes=zips
        build_zip_string
    end

    def get_num_listings
        @num_listings = $prompt.ask("How many worst buildings would you like to display?:",default: '20').to_i
    end

    def build_zip_string
        @string_of_zips = @zip_codes.map { |zip| "'" + zip + "'" }.join(",")
    end

    def get_dates
        @start_date = $prompt.ask("Enter Start Date:",default: '2020-01-01') + "T00:00:00" #Defaults to start of 2020
        @end_date = $prompt.ask("Enter End Date:", default:'2021-01-01') + "T00:00:00" #Defaults to end of 2020
    end

    def build_url(url)
        url += "?$where=zip in (#{@string_of_zips})" 
        url += " AND novissueddate between '#{@start_date}' and '#{@end_date}'"
        url += "&$limit=100000"
    end

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
          issue_date: result["novissueddate"],
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
          violation_type: result["violation_type"],
          issue_date: result["issue_date"],
          disposition_date: result["disposition_date"],
          disposition_comments: result["description"],
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
                if !found_building.bbl
                    found_building.update_attribute(:bbl, "1000000000")
                end
            end
            create_hpd_violation_from_result_and_building(result, found_building)
        end
    end
    
    def boro_block_lot(bblstring) # returns a hash
        if !bblstring
            bblstring="1000000000"
        end
        bblhash = {}
        bblhash[:boro] = bblstring[0]
        bblhash[:block] = bblstring[1,5]
        bblhash[:lot] = bblstring[6,4]
        return bblhash
    end
    
    def create_dob_violations_from_building(building)
        bbl = boro_block_lot(building.bbl)
        url = build_dob_url("https://data.cityofnewyork.us/resource/3h2n-5cm9.json", bbl)
        results=results = HTTParty.get(url) 
        results.each {|result| create_dob_violation_from_result_and_building(result, building)}
    end
    
    def create_dob_violations(worst_buildings)
        worst_buildings.each { |building| create_dob_violations_from_building(building) }
    end
    
    def get_worst_buildings 
        Building.sort_worst(@ignore_closed).take(@num_listings)
    end

    def build_dob_url(url, bbl)
        dob_start = @start_date.split("T")[0].delete("-")
        dob_end= @end_date.split("T")[0].delete("-")
        url += "?$where=issue_date between '#{dob_start}' and '#{dob_end}'&boro=#{bbl[:boro]}&block=#{bbl[:block]}&lot=0#{bbl[:lot]}"
    end

    def build_csv(row,filename)
        time = Time.new.to_s
        CSV.open("./csv/#{time[11..18]}#{filename}.csv", "a") do |csv|
            csv << row
        end
    end

    def make_building_table(worst_buildings)
        table = Terminal::Table.new
        table.style = {:width => 125}
        table.title = "Top #{worst_buildings.count} Worst Buildings" 
        table.headings = ['Ranking',"HPD\nViolations","DOB\nViolations" ,'Address', 'Borough', 'Zip Code',"Block #", "Lot #"]
    
        worst_buildings.each_with_index do |building,index|
            row = [index+1,building.hpd_violations.count,building.dob_violations.count, building.address ,building.borough,building.zip,building.block,building.lot]
            table.add_row row
            build_csv(row,"_#{worst_buildings.length}_worstbuildings")
            index == worst_buildings.length - 1 ? break : table.add_separator
        end
        puts table
        return table
    end

    def violation_info(worstBuildings,table)
        more_info = $prompt.select("Do you want more information about a building?", %w(Yes No))
        while more_info == "Yes"
            building_num = $prompt.ask("Enter The Number of The Building:").to_i
            while building_num > worstBuildings.length or  building_num < 1
                print "Please enter a valid building number."
                building_num = $prompt.ask(" Enter The Number of The Building:").to_i
            end
            index = building_num - 1
            selected_building = worstBuildings[index]
            make_violations_table(selected_building,building_num)
            more_info = $prompt.select("Do you want more information about a building?", %w(Yes No))
            puts table if more_info == "Yes"    
        end
    end
    
    def make_violations_table(building,building_num) 
        table = Terminal::Table.new 
        table.style = {:width => 125}
        table.title = "#{building.address}"#: HPD Violations"
        table.headings = ['Issue Date',"ViolationID","Status","Description"]

        hviolations = building.hpd_violations
        dviolations = building.dob_violations
    
        hviolations.sort_by{|violation| violation.issue_date}.each_with_index do |violation,index|
            row = [violation.issue_date[0..9], violation.violation_num, violation.status[0..25],violation.novdescription[0..60]+"..."]
            csvrow = [violation.issue_date[0..9], violation.violation_num, violation.status,violation.novdescription]
            table.add_row row
            build_csv(csvrow,"_#{building_num}_hpdViolations")
            index == hviolations.length - 1 ? break : table.add_separator
        end

        if building.dob_violations.count > 0
            table.add_separator
            table.add_row ["","","",""]
            table.add_separator
            dviolations.sort_by{|violation| violation.issue_date}.each_with_index do |violation,index|
                row = [violation.get_date, violation.dob_violation_num, violation.violation_category[0..25],violation.description[0..60]+"..."]
                table.add_row row
                build_csv(row,"_#{building_num.to_s}_dobViolations")
                index == dviolations.length - 1 ? break : table.add_separator
            end
        end
        puts table
    end




    def run
        system("clear") || system("cls")
        puts $a.asciify("Find NYC's Worst Buildings")
        puts "Clearing old records..."
        Building.destroy_all
        HpdViolation.destroy_all
        
        get_zips
        get_dates

        url=build_url("https://data.cityofnewyork.us/resource/wvxf-dwi5.json") 
        puts "Querying HPD Open Data..."
        results = HTTParty.get(url)   #.sort_by {|v| v["novissueddate"]}
        puts "Populating Local Database..."
        create_buildings_and_hpd_violations(results)
        puts "Found #{Building.all.count} buildings and #{HpdViolation.all.count} violations that matched your search."
        get_num_listings
        @ignore_closed=$prompt.yes?("Ignore Closed Violations?")
        puts "Sorting Worst Buildings..."
        worst_buildings=get_worst_buildings
        puts "Finding Accompanying DOB Violations..."
        create_dob_violations(worst_buildings)

        table = make_building_table(worst_buildings)

        violation_info(worst_buildings, table)
 
    end

end

