class BadgesController < ApplicationController
  def index
    @dashboard_menu = :badges
    @sort_type = params.fetch(:sort_by, nil).to_sym rescue :latest

    sort_types = { :latest => 'badge_awards.created_at DESC', 
                   :alphabetical => "badge_awards.name_#{current_site.default_locale.to_s.downcase}"  }

    @collection = profile_user.badge_awards.paginate :page => params[:page], :per_page => 10, 
                                                    :order => sort_type[@sort_type]
  end

  def show
    @dashboard_menu = :badges
    @badge_award = profile_user.badge_awards.find(params[:id])
    @friends_with_badge = profile_user.followees.with_badge(@badge_award)
    @others_with_badge = @badge_award.badge.winners.other_than_user_and_followees(profile_user)
  end
end
