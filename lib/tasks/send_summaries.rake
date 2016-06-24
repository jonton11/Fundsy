namespace :send_summaries do
  desc "Sending daily summary of pledges on campaigns"
  task :send_all => :environment do
    # adding :environment means that we loaded Rails
    Campaign.all.each do |campaign|
      SendCampaignSummaryJob.perform_later(campaign)
    end
  end
end
