class DashboardsController < ApplicationController
  before_filter :login_required
  before_filter :auto_follow_profile
  #before_filter :load_user_activities, :only => [:show]
  ACTIVITIES_MAX           = 15
  ACTIVITIES_DASHBOARD_MAX = 8
  ACTIVITY_SHOW_MORE_SIZE  = 5

  layout_except_xhr 'application'

  def show
    @dashboard_menu = :home
    @top_playlists_limit = 6
    @top_playlists = current_site.top_playlists.all(:limit => @top_playlists_limit)
    @notifications = profile_owner? ? profile_user.badge_awards.notifications.reject { |b| b.playlist.nil? } : []
    
    respond_to do |format|
      format.html
      format.json do
        render :text => profile_user.activity_feed
      end
    end
  end
  
  private
  def load_user_activities
    @has_more = true

    if profile_account
      @account = profile_account
    else
      @account = get_account_by_slug(params[:slug])
    end

    group = :all
    
    if params[:profile_owner] and params[:profile_owner].to_i == 0
      group = :just_me
    end
    
    if params[:filter_by]
      @filter_type = params[:filter_by]
      group        = :all            if @filter_type == 'all'
      group        = :just_me        if @filter_type == 'me'
      group        = :just_following if @filter_type == 'following'
    end
    
    collection      = @account.activity_feed(:group => group)
    @collection     = collection.sort_by {|a| a['timestamp'].to_i}.reverse
    
    if collection.size - ACTIVITIES_MAX > 0
      @has_more = true
    end

    @collection.each do |a|
      account      =  Account.find(a['account_id'])
      a['account'] = account
      if a['type'] == 'station'
        station      = Station.find(a['item_id']).playable
        a['station'] = station
        a['artist']  = station.artist
      end
    end
  end

end

