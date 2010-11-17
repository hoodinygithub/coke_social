namespace :notifications do
  desc "Send badges win notifications"
  task :win_badges => :environment do
    BadgeAward.all(:conditions => 'email_sent = 0').each do |badge_award|
        if badge_award.winner.receives_badges_notifications?
          puts "************** #{Time.now}: SENT BADGE AWARD EMAIL (#{badge_award.name}) TO: #{badge_award.winner.slug}"
          UserNotification.send_badge_notification({:badge_award_id => badge_award.id})
        end
    end
  end
end
  
