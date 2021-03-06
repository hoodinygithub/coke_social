class DashboardsController < ApplicationController
  before_filter :login_required
  before_filter :load_user_activities, :only => [:show]

  ACTIVITIES_MAX           = 50
  ACTIVITIES_PAGE_SIZE     = 12

  layout_except_xhr 'application'

  def show
    @dashboard_menu = :home
    @top_playlists_limit = 6
    @top_playlists = current_site.top_playlists.all(:limit => @top_playlists_limit)
    @notifications = profile_owner? ? profile_user.badge_awards.notifications : []
    # Perf: Don't get activity and throw it away.  Slice it before you get here.
    #@activity = @activity[0..ACTIVITIES_PAGE_SIZE-1]
    
    respond_to do |format|
      format.html
      format.json do
        render :text => profile_user.activity_feed
      end
    end
  end
  
  private
  def load_user_activities
    @has_more = false

    group = :all
    if params[:sort_by]
      @filter_type = (params[:sort_by] =~ /(user_followings|user|followings)/i) ? params[:sort_by] : "user_followings"
      group        = :all            if @filter_type == 'user_followings'
      group        = :just_me        if @filter_type == 'user'
      group        = :just_following if @filter_type == 'followings'
    end
    
    unless (Activity::Feed.db rescue nil)
      # TESTING - Update info if this user is not in your DB
      user = User.first
      test_item = {"timestamp"=>"1297971608", :pk=>"1600280/status/1297971608", "user_avatar"=>"#{user.avatar.path}", "account_id"=>"#{user.id}", "type"=>"status", "id"=>"23688250472120", "user_id"=>"#{user.id}", "user_slug"=>"#{user.slug}"}
      collection = []
      (ACTIVITIES_PAGE_SIZE+1).times do |i|
        collection << test_item.merge("message" => "Message #{i+1}")
      end
    else
      collection      = current_user.activity_feed(:group => group)
    end
    @activity     = collection.sort_by {|a| a['timestamp'].to_i}.reverse[0..ACTIVITIES_PAGE_SIZE-1]
    
    if collection.size - ACTIVITIES_PAGE_SIZE > 0
      @has_more = true
    end

    # perf todo: We're saving db time, but not Tyrant time.  Activity model needs to support a limit param.
    @activity.each do |a|
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

