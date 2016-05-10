require "faraday"
require "json"

BASE_URL = "http://localhost:3000/"

conn = Faraday.new(url: BASE_URL) do |faraday|
  faraday.request  :url_encoded             # form-encode POST params
  faraday.response :logger                  # log requests to STDOUT
  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
end

response = conn.get "api/v1/campaigns/2?api_key=ea78610769a2fc3deb7253500920992c5160cb2ad519851a21d7924ecc86a8d6"

campaigns = JSON.parse(response.body)

campaigns.each do |campaign|
  puts campaign["title"]
end
