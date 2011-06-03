class AccountsController < ApplicationController
  # caches_page :show
  before_filter :record_visit, :only => [:show]
  before_filter :assert_profile_is_available, :only => [ :show ]
  before_filter :load_user_activities, :only => [ :show ]

  current_tab :home

  RECOMMENDED_STATIONS = 6
  ACTIVITIES_MAX = 5
  
  def show
    return redirect_to( user_path( profile_account.slug ) ) if params[:slug] != profile_account.slug
    @dashboard_menu = :home
    @mixes_recommended = (1..6).to_a
    @comments = (1..3).to_a
    @reviews = profile_account.comments.valid({:limit => 5, :order => "comments.updated_at DESC"})
    
    @followers = profile_account.followers.all(:limit => 4)

    respond_to do |format|
      format.html
      format.rss do
        @activities = load_related_item_activity(
          profile_account.transformed_activity_feed(
            :kind => :listen,
            :group => :just_me
          )
        )
      end
    end
  end

private

  def assert_profile_is_available
    unless profile_account.visible?
      redirect_to(profile_not_available_path(params[:slug]))
    else
      true
    end
  end

  def record_visit
    begin
      if !logged_in? || (logged_in? && (current_user.slug != params[:slug]))
        tracker_payload = {
          :owner_id => profile_account.id,
          :visitor_id => (current_user.nil?)? nil : current_user.id,
          :site_id => current_site.id,
          :visitor_ip_address => remote_ip,
          :timestamp => Time.now.to_i
        }
        Resque.enqueue(ProfileVisitJob, tracker_payload)
      end
    rescue Exception => e
      Rails.logger.error("*** Could not record visit! #{e}\n#{e.backtrace.join("\n")}\n#{tracker_payload}") and return true
    end
    #session[:origin_to] = request.request_uri if !logged_in?
  end

  def activity
    @activity ||= profile_account.parsed_activity_feed(false)#.lines(nil, false)
  end
  helper_method :activity

  def activity_for_page
    # @activity_for_page ||= activity[0..14] rescue []
    @activity_for_page ||= (activity.map{|a| a['activity']}[0..14])  rescue []
  end
  helper_method :activity_for_page

  def activity_for_js
    @activity_for_js ||= (activity[15..-1].collect{|a| "'" + a.to_json.gsub(/'/, "\\\\'") + "'"} rescue [])
  end
  helper_method :activity_for_js

  def type
    @type ||= (activity_for_page.first.feed_type.to_s rescue "listen")
  end
  helper_method :type
  
  def load_user_activities
    group = :just_me
    
    unless (Activity::Feed.db rescue nil)
      # TESTING - Update info if this user is not in your DB
      test_item = {"timestamp"=>"1297971608", :pk=>"1600280/status/1297971608", "user_avatar"=>"/images/multitask/djs/sim_autor.jpg", "account_id"=>"1600280", "type"=>"status", "id"=>"23688250472120", "user_id"=>"1600280", "user_slug"=>"sue008"}
      activity = []
      50.times do |i|
        activity << test_item.merge("message" => "Message #{i+1}")
      end
    else
      activity      = profile_account.activity_feed(:group => group)
    end
    @activity     = activity.sort_by {|a| a['timestamp'].to_i}.reverse
    
    @has_more = (activity.size > ACTIVITIES_MAX) rescue true

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

