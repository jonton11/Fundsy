json.array! @campaigns do |campaign|
  json.id       campaign.id
  json.title    campaign.title.titleize
  json.url      campaign_url(campaign)
  json.api_url  api_v1_campaign_url(campaign)
  json.created_on formatted_date(campaign.created_at)
  json.end_date   formatted_date(campaign.end_date)
end
# json.array! @campaigns, :id, :title, url: { campaign_url(campaign) }
