require "faraday"
require "json"

BASE_URL = "http://localhost:3000/"

conn = Faraday.new(url: BASE_URL) do |faraday|
  faraday.request  :url_encoded             # form-encode POST params
  # faraday.response :logger                  # log requests to STDOUT
  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
end

response = conn.get "api/v1/campaigns?api_key=ea78610769a2fc3deb7253500920992c5160cb2ad519851a21d7924ecc86a8d6"
# Make sure this connects to the index page and not the show (remove campaign id)

puts response.body
puts "\n >>>>>>>>>>>>>>>>>>>>>>>>>>> \n\n" # just to make things easier to read
campaigns = JSON.parse(response.body)
puts campaigns
puts "\n >>>>>>>>>>>>>>>>>>>>>>>>>>> \n\n"

campaigns.each do |campaign|
  puts campaign["title"]
end
