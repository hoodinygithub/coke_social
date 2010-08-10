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
    badge = Badge.find_by_badge_key(badge_key.to_s)
    if (badge and winner)
      if single
        BadgeAward.create(:badge_id => badge.id, :winner_id => winner.id, :name => badge.name, :name_coke_es => badge.name_coke_es, :name_coke_br => badge.name_coke_br, :playlist_id => playlist.id) unless winner.badges.include?(badge)
      else
        BadgeAward.create(:badge_id => badge.id, :winner_id => winner.id, :name => badge.name, :name_coke_es => badge.name_coke_es, :name_coke_br => badge.name_coke_br, :playlist_id => playlist.id)
      end
    end
  end

end