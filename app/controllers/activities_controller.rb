class ActivitiesController < ApplicationController
  include ActionView::Helpers::DateHelper
  include ApplicationHelper

  before_filter :account, :except => [:latest_activities]
  before_filter :set_page, :except => [ :song ]
  before_filter :login_required, :only => [:update_status]
  before_filter :load_user_activities, :only => [:index, :latest]

  ACTIVITIES_MAX                 = 50
  ACTIVITIES_PAGE_SIZE           = 12
  ACTIVITIES_DASHBOARD_PAGE_SIZE = 8
  ACTIVITY_SHOW_MORE_SIZE        = 12

  def index
    if params[:count]
      get_more(ACTIVITIES_PAGE_SIZE)
    else
      @collection = @collection[0..ACTIVITIES_PAGE_SIZE-1]
      @dashboard_menu = :activity
      if request.xhr? && !params[:ajax]
        render :partial => 'ajax_list'
      end
    end
  end

  def get_more(page_size)
    activity_count = params[:count].to_i rescue page_size
    if activity_count < ACTIVITIES_MAX
      activity_to = activity_count+page_size-1
      activity_to = ACTIVITIES_MAX-1 if activity_to > ACTIVITIES_MAX-1
      @collection = @collection[activity_count..activity_to]
      @has_more = (ACTIVITIES_MAX-activity_to > 1)
      render :partial => "activities/list", :layout => false
    else
      render :nothing => true
    end
  end

  def get_activity
    @activities = load_related_item_activity( account.transformed_activity_feed(:kind => params[:type].to_sym,
                                                    :page => params[:page],
                                                    :before_timestamp => @before_timestamp,
                                                    :after_timestamp => @after_timestamp,
                                                    :group => activity_group) )
    expires_now
    respond_to do |format|
      format.js { render :partial => "modules/activity/#{@type}_activity", :collection => @activities, :layout => false }
      format.json do
        message = ""
        items   = @activities.size
        link    = "<a id=\"push_notification_refresh\" href=\"#{my_dashboard_path}\">#{t("activity.push_notification_refresh")}</a>"
        message = t("activity.push_notification", { :count => items, :link  => link }) if items > 0
        render :json => { :message => message, :items => items, :juq => @just_update_qty }
      end
    end
  end

  def song
    @song = Song.find(params[:song_id])
    @activity = record_listen_song_activity(@song).merge( 'record' => @song )
    render(
      :partial => "modules/activity/listen_activity",
      :collection => [ @activity ])
  end

  def update
    if request.post? and request.xhr?
      if params[:type] == 'status'
        item = {:message => params[:message]}
      end

      success = false
      
      if false #Rails.env.development?
        # TESTING - Update info if this user is not in your DB
        activity_status = {"message" => params[:message], "timestamp"=>"1297971608", :pk=>"1600280/status/1297971608", "user_avatar"=>"/images/multitask/djs/sim_autor.jpg", "account_id"=>"1600280", "type"=>"status", "id"=>"23688250472120", "user_id"=>"1600280", "user_slug"=>"sue008"}
        success = true
      else
        activity_status = Activity::Status.new(current_user)
        success = true if activity_status.put(item)
      end

      if success
        set_activity_objects(activity_status)
        render :json => { :success => true, :latest => render_to_string(:partial => 'activities/item', :locals => {:item => activity_status}) }   
      else
        render :json => { :success => false, :errors => activity_status.errors.to_json }
      end  
    end
  end

  def latest
    render latest_activity
  end

  def latest_activity
    if params[:after]
      last_element_index = @collection.collect {|a| a['timestamp']}.index(params[:after])
      @collection        = @collection.slice(0, last_element_index + ACTIVITY_SHOW_MORE_SIZE + 1)
    else
      @collection = @collection[0..ACTIVITIES_DASHBOARD_PAGE_SIZE-1]
    end

    if params[:public]
      { :partial => 'activities/line', :collection => @collection }
    else
      { :partial => 'activities/item', :collection => @collection }
    end
  end

  def latest_tweet
    account = get_account_by_slug(params[:slug])
    @collection = account.transformed_activity_feed.first
    render :partial => 'shared/tweet_msg', :locals => {:slug => params[:slug]}
  end

  private
  def set_activity_objects(a)
    account      =  Account.find(a['account_id'])
    a['account'] = account
    if a['type'] == 'station'
      station      = Station.find(a['item_id']).playable
      a['station'] = station
      a['artist']  = station.artist
    end
  end
  
  def load_user_activities
    @has_more = false

    if profile_account
      @account = profile_account
    else
      @account = get_account_by_slug(params[:slug])
    end

    group = :all
    if params[:sort_by]
      @filter_type = (params[:sort_by] =~ /(user_followings|user|followings)/i) ? params[:sort_by] : "user_followings"
      group        = :all            if @filter_type == 'user_followings'
      group        = :just_me        if @filter_type == 'user'
      group        = :just_following if @filter_type == 'followings'
    end
    
    if false #Rails.env.development?
      # TESTING - Update info if this user is not in your DB
      test_item = {"timestamp"=>"1297971608", :pk=>"1600280/status/1297971608", "user_avatar"=>"/images/multitask/djs/sim_autor.jpg", "account_id"=>"1600280", "type"=>"status", "id"=>"23688250472120", "user_id"=>"1600280", "user_slug"=>"sue008"}
      collection = []
      50.times do |i|
        collection << test_item.merge("message" => "Message #{i+1}")
      end
    else
      collection      = @account.activity_feed(:group => group)
    end
    @collection     = collection.sort_by {|a| a['timestamp'].to_i}.reverse
    
    if collection.size - ACTIVITIES_PAGE_SIZE > 0
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

  def set_page
    params[:page]   ||= 1
    @type             = params[:type] || nil
    @show_user        = !@account.is_a?(Artist) && (params[:su]=="true")
    @show_follow      = (params[:sf]=="true")
    @before_timestamp = params[:bts]
    @after_timestamp  = params[:ats]
    @just_update_qty  = (params[:juq] == "true")
  end

  def activity_group
    return :just_following if artist? || @type == "twitter"
    if params[:su] == 'true' && params[:sf] == 'true'
      :all
    elsif params[:su] == 'false' && params[:sf] == 'true'
      :just_following
    elsif params[:su] == 'true' && params[:sf] == 'false'
      :just_me
    end
  end

  def artist?
    @account && @account.artist?
  end

  def account
    @account = params[:user] ? Account.find(params[:user]) : nil
  end

  def get_account_by_slug(slug)
    if slug
      @account = AccountSlug.find_by_slug(slug).account
    elsif current_user
      @account = current_user
    end
  end

end

