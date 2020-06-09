require_relative './config/environment'
# gem ‘tty-prompt’


url = "https://data.cityofnewyork.us/resource/wvxf-dwi5.json"
response = HTTParty.get(url)

binding.pry
0