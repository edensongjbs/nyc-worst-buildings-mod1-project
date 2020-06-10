# require 'pry'

# class WorstBuildings

#     $prompt = TTY::Prompt.new

#     def run
#         #violation_type = $prompt.select("Choose by violation type:", %w(HPD DOB))
#         zip_codes = []
#         $prompt.collect do
#             zip_codes << key(:zip).ask('Enter Zip Code:', required: true)  
#             while $prompt.yes?("Continue?")
#                 zip_codes << key(:zip).ask('Enter Zip Code:')
#             end
#         end
#         string_of_zips = zip_codes.map { |zip| "'" + zip + "'" }.join(",")

#         start_date = $prompt.ask("Enter Start Date:",default: '2020-01-01') + "T00:00:00" #Defaults to start of 2020
#         end_date = $prompt.ask("Enter End Date:", default:'2021-01-01') + "T00:00:00" #Defaults to end of 2020

        
#         url = "https://data.cityofnewyork.us/resource/wvxf-dwi5.json" 
#         url += "?$where=zip in (#{string_of_zips})" 
#         url += " AND novissueddate between '#{start_date}' and '#{end_date}'"
#         url += "&$limit=100000"


#         response = HTTParty.get(url)#.sort_by {|v| v["novissueddate"]}
 
#         binding.pry
#         0
#     end

# end


