class BadgesController < ApplicationController
  def index
    @dashboard_menu = :badges
    sort_types = { :latest => 'badge_awards.created_at DESC', :alphabetical => "badge_awards.name_#{(['coke_mx','coke_ar'].include? current_site.default_locale.to_s.downcase) ? 'coke_es' : current_site.default_locale.to_s.downcase } ASC"  }
    @sort_type = get_sort_by_param(sort_types.keys, :latest) #params.fetch(:sort_by, nil).to_sym rescue :latest
    @collection = profile_user.badge_awards.paginate :page => params[:page], :per_page => 10, :order => sort_types[@sort_type]
    
    if request.xhr? && !params[:ajax]
      render :partial => 'ajax_list'
    end
  end

  def show
    @dashboard_menu = :badges
    @badge_award = profile_user.badge_awards.find(params[:id])
    @friends_with_badge = profile_user.followees.with_badge(@badge_award)
    @others_with_badge = @badge_award.badge.winners.other_than_user_and_followees(profile_user)
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
  
  def list
    # promo_id doesn't mean anything yet.  Just CokeBR doesn't get to see it.
    @badges = current_site.id == 22 ? Badge.all({:conditions => { :promo_id => nil}}) : Badge.all
    render :layout => "logged_out" unless params[:ajax]
  end
end
