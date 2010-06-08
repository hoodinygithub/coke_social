class BadgesController < ApplicationController
  def index
    @dashboard_menu = :badges
    @sort_type = params.fetch(:sort_by, nil).to_sym rescue :latest

    begin
        sort_types = { :latest => 'badge_awards.created_at DESC', :alphabetical => "badge_awards.name_#{current_site.default_locale.to_s.downcase}"  }
        @collection = profile_user.badge_awards.paginate :page => params[:page], :per_page => 10, :order => sort_types[@sort_type]

      if request.xhr?
        render :partial => 'list'
      end
    rescue NoMethodError
      redirect_to new_session_path
    end
  end

  def show
    @dashboard_menu = :badges
    begin
      @badge_award = profile_user.badge_awards.find(params[:id])
      @friends_with_badge = profile_user.followees.with_badge(@badge_award)
      @others_with_badge = @badge_award.badge.winners.other_than_user_and_followees(profile_user)
    rescue
      redirect_to new_session_path
    end
  end
  
  def set_notified
    if request.xhr?
      if profile_owner?
        profile_user.badge_awards.set_notified!
        render :text => "notifications set", :layout => false
      else
        render :text => "notifications not set", :layout => false
      end
    else
      redirect_to profile_owner? ? my_dashboard_path : user_path(profile_user)
    end
  end
end
