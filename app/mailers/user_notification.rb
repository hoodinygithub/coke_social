class UserNotification < BaseMailer

  def registration(user, options)
    subject  options[:subject]
    recipients user.email
    from ActionMailer::Base.smtp_settings[:default_from]
    body  options.merge({:user => user})
    content_type  "text/html"
  end

  def cancellation(user)
    subject  I18n.t("cancellation.email.subject")
    recipients user.email
    from ActionMailer::Base.smtp_settings[:default_from]
    body  :user => user
  end

  def reset_notification(subject_line, user, password)
    subject subject_line
    recipients user.email
    from ActionMailer::Base.smtp_settings[:default_from]
    body :user => user, :password => password
  end

  def following_request(subject_line, followee, follower, user_link, community_link)
    subject subject_line
    recipients followee.email
    from ActionMailer::Base.smtp_settings[:default_from]
    body :followee => followee, :follower => follower, :user_link => user_link, :my_community => community_link
  end
  
  def review_notification(subject_line, reviewer, playlist)
    subject subject_line
    recipients playlist.owner.email
    from ActionMailer::Base.smtp_settings[:default_from]
    body :reviewer => reviewer, :playlist => playlist
  end

  def review_notification(subject_line, badge_award)
    subject subject_line
    recipients badge_award.winner.email
    from ActionMailer::Base.smtp_settings[:default_from]
    body :badge_award => badge_award
  end

  def share_song(options)
    subject options[:subject_line]
    bcc options[:mailto]
    from ActionMailer::Base.smtp_settings[:default_from]
    body options
    content_type  "text/html"
  end

  def share_station(options)
    subject options[:subject_line]
    bcc options[:mailto]
    from ActionMailer::Base.smtp_settings[:default_from]
    body options
    content_type  "text/html"
  end

  def feedback_message(options)
    reply_to options[:address]
    if options[:cancellation]
      subject "Feedback - Account Cancellation"
    else
      subject "Feedback"
    end
    reply_to options[:address]
    recipients options[:mailto]
    from ActionMailer::Base.smtp_settings[:default_from]
    body options
  end

  def contact_us_message(options)
    reply_to options[:address]
    subject options[:category]
    recipients options[:mailto]
    from ActionMailer::Base.smtp_settings[:default_from]
    body options
  end

  class << self

    def send_registration( options )
      user = User.find(options[:user_id])
      UserNotification.deliver_registration(user, options)
    end

    def send_confirmation( options )
      user = User.find(options[:user_id])
      UserNotification.deliver_confirmation(options[:subject_line], user, options[:confirmation_link], options[:host_url])
    end

    def send_cancellation( options )
      user = User.find_by_sql( ["SELECT * FROM accounts WHERE id = ?", options[:user_id]] ).first
      UserNotification.deliver_cancellation(user)
    end

    def send_reset_notification( options )
      user = User.find(options[:user_id])
      I18n.with_locale( user.default_locale ) do
        UserNotification.deliver_reset_notification( I18n.t("reset.email.subject") , user, options[:password])
      end
    end

    def send_following_request(options)
      follower = Account.find(options[:follower_id])
      followee = Account.find(options[:followee_id])
      I18n.with_locale( followee.default_locale ) do
        subject_line = I18n.t('followings.email.subject', :follower => follower.name)
        UserNotification.deliver_following_request(subject_line, followee, follower, options[:user_link], options[:my_community])
      end
    end
    
    def send_review_notification(options)
      reviewer = Account.find(options[:reviewer_id])
      playlist = Playlist.find(options[:playlist_id])
      I18n.with_locale( playlist.owner.default_locale ) do
        subject_line = I18n.t('reviews.email.subject', :reviewer => reviewer.name)
        UserNotification.deliver_review_notification(subject_line, reviewer, playlist)
      end
    end

    def send_badge_notification(options)
      badge_award = BadgeAward.find(options[:badge_award_id])
      I18n.with_locale( badge_award.winner.default_locale ) do
        subject_line = I18n.t('badges.email.subject')
        UserNotification.deliver_badge_notification(subject_line, badge_award)
      end
    end

    def send_feedback_message( options )
      UserNotification.deliver_feedback_message(options)
    end

    def send_share_song( options )
      begin
        return [true, nil] if options[:mailto].blank?
        TMail::Address.parse(options[:mailto])
      rescue TMail::SyntaxError
        return [true, nil]
      end

      I18n.with_locale(options[:locale]) do
        UserNotification.deliver_share_song(options)
      end
    end

    def send_share_station( options )
      begin
        return [true, nil] if options[:mailto].blank?
        TMail::Address.parse(options[:mailto])
      rescue TMail::SyntaxError
        return [true, nil]
      end

      I18n.with_locale(options[:locale]) do
        UserNotification.deliver_share_station(options)
      end
    end

    def send_contact_us_message( options )
      UserNotification.deliver_contact_us_message(options)
    end

  end

end
