class CampaignSerializer < ActiveModel::Serializer # :nodoc:
  attributes :id, :title, :body, :url, :created_at
  has_many :pledges

  include ApplicationHelper

  def title
    object.title.titleize
    # This will titleize the title attribute in the returned JSON object
  end

  def url
    campaign_url(object, host: 'http://localhost:3000')
  end

  def created_at
    formatted_date(object.created_at)
  end
end
