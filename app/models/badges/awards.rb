module Badges::Awards
  def award_badge(badge_key, winner, single=true)
    badge = Badge.find_by_badge_key(badge_key.to_s)
    if (badge and winner) 
      if single
        BadgeAward.create(:badge_id => badge.id, :winner_id => winner.id, :name => badge.name, :name_coke_es => badge.name_coke_es, :name_coke_br => badge.name_coke_br) unless winner.badges.include?(badge)
      else
        BadgeAward.create(:badge_id => badge.id, :winner_id => winner.id, :name => badge.name, :name_coke_es => badge.name_coke_es, :name_coke_br => badge.name_coke_br)
      end
    end
  end

  def award_badge_for_playlist(badge_key, winner, playlist, single=true)
    # TODO: single works for 1 badge/user, but not for 1 badge/user/playlist
    badge = Badge.find_by_badge_key(badge_key.to_s)
    if (badge and winner)
      if single
        BadgeAward.create(:badge_id => badge.id, :winner_id => winner.id, :name => badge.name, :name_coke_es => badge.name_coke_es, :name_coke_br => badge.name_coke_br, :playlist_id => playlist.id) unless winner.badges.include?(badge)
      else
        BadgeAward.create(:badge_id => badge.id, :winner_id => winner.id, :name => badge.name, :name_coke_es => badge.name_coke_es, :name_coke_br => badge.name_coke_br, :playlist_id => playlist.id)
      end
    end
  end

  def award_xmas_badges_playlist

    if promo_playlist?

      award_badge(:merry_dj, owner)

      unless Badge.find_by_badge_key("twinkle").winners.include? owner
        if owner.playlists.all(:conditions => ["created_at > ?", Time.now - 1.day]).select { |p| p.promo_playlist? }.length == 5
          award_badge(:twinkle, owner)
        end
      end

      count = nil
      wins = BadgeAward.all(:conditions => { :winner_id => owner.id }).map(&:badge_id)

      if !wins.include? Badge.find_by_badge_key("santa_claus").id
        if Time.now.month == 12 and Time.now.day == 25
          award_badge(:santa_claus, owner)
        end
      end

      if !wins.include? Badge.find_by_badge_key("rey_mago").id
        if Time.now.month == 1 and Time.now.day == 6
          award_badge(:rey_mago, owner)
        end
      end

      if !wins.include? Badge.find_by_badge_key("xmas_musician").id
        count ||= owner.playlists.select { |p| p.promo_playlist? }.length
        award_badge(:xmas_musician, owner) if count >= 3
      end

      if (count.nil? or count >= 5) and !wins.include? Badge.find_by_badge_key("xmas_dj").id
        count ||= owner.playlists.select { |p| p.promo_playlist? }.length
        award_badge(:xmas_dj, owner) if count >= 5
      end

      if (count.nil? or count >= 10) and !wins.include? Badge.find_by_badge_key("bota").id
        count ||= owner.playlists.select { |p| p.promo_playlist? }.length
        award_badge(:bota, owner) if count >= 10
      end

    end

  end

  def award_xmas_badges_comment

    # Getting promo_tags for every playlist you've commented on may be too heavy.  Try to short circuit if already won.
    unless Badge.find_by_badge_key("xmas_xpert").winners.include? user
      if commentable.promo_playlist? and user.comments.all(:include=>:commentable).select{|c| c.commentable.promo_playlist?}.length >= 10
        award_badge(:xmas_xpert, user)
      end
    end

    # award_badge doesn't check for multiple badges per user for each playlist
    unless Badge.find_by_badge_key("xmas_rocker").winners.with_playlist(commentable.id).include? user
      # Assumes each comment must be from a unique user.  No duplicate comments per user.
      if commentable.promo_playlist? and commentable.comments.count >= 20
        award_badge_for_playlist(:xmas_rocker, commentable.owner, commentable.id, false)
      end
    end

    if rating == 5 and commentable.promo_playlist?
      award_badge_for_playlist(:cool_lo, commentable.owner, commentable.id)
    end

    if rating == 5 and commentable.promo_playlist? and commentable.comments.count(:conditions => {:rating => 5}) >= 3
      award_badge_for_playlist(:que_bolas, commentable.owner, commentable.id)
    end

    unless Badge.find_by_badge_key("recalentado").winners.include? user
      # This line of code is flippin' awesome!  (and heavy)
      if commentable.owner.playlists.all(:include => :comments).select{|p| p.promo_playlist?}.map(&:comments).flatten.map(&:rating).inject({}) { |hash, x| hash[x].nil? ? hash[x] = 1 : hash[x] += 1; hash }.select{|k,v| v >= 2; }.size > 0
        award_badge(:recalentado, commentable.owner) 
      end
    end

    unless Badge.find_by_badge_key("regalo").winners.include? user
      if rating > 3 and user.comments.all(:order => "created_at DESC", :include => :commentable).select{|c| c.commentable.promo_playlist?}[0..4].select{|c| c.rating > 3}.size >= 3 
        award_badge(:regalo, user)
      end
    end

  end
end

