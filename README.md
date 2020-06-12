# WorstBuildingsNYC

WorstBuildingsNYC is a Ruby CLI application designed with tenant advocacy in mind. The program helps users to easily access information about distressed and poorly maintained buildings throughout NYC.  The interface allows the user to enter some basic search parameters, specifically zip code(s) and a date range, and will return a ranking of the worst buildings in those zip codes based upon the number of total filed HPD (Housing Preservation & Development) Maintenance Code Violations during that time period.  Additionally, the results will include any DOB (Department of Buildings) violations for those same buildings during that specified time period.  The user can opt to view additional information about the individual violations and all results will be exported as a .csv file. 

# Installation

Begin installation by cloning or downloading this repository.  In your terminal, navigate to the project's directory and run the following commands:

bundle install  
rake db:migrate

Use the following command to run the program:  
ruby bin/run.rb


# Usage

Just follow the onscreen prompts to enter information necessary to the initial search.  You can specify one or multiple zip codes.  Please enter dates in the specificed YYYY-MM-DD format.  Once the initial listings are retrieved via NYC Open Data, you can specify how many buildings you would like to return in your ranked results.  If you prefer to only view open violations, you can do this by electing to "ignore closed violations".  Once the table of worst buildings is displayed, the information will be exported as a .csv.  From this point, you have the option to display additional information regarding the individual violations by selecting a single building from the list (by rank #).  You can opt to view as many buildings as you'd like, and each table will be exported as a separate .csv file.
