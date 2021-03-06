class RadioController < ApplicationController
  protect_from_forgery :except => [:search, :artist_info]
  #Explicitly removing caching on radio per Demian - 2009-09-29
  #caches_action :show, :expires_in => EXPIRATION_TIMES['radio_show'], :cache_path => :radio_show_cache_key

  def index
    @station_obj = nil

    station = Station.find_by_id_and_playable_type(params[:station_id], 'Playlist') rescue nil
    @station_obj = station if station and station.playable and station.playable.owner and station.playable.owner.active?
    
    if @station_obj
      @profile_account = @station_obj.playable.owner
      @section = "player_page" #used for css styling
      @station_queue = @station_obj.playable.station_queue(:ip_address => remote_ip)
      @station_obj.playable.track_a_play_for(current_user) if @station_obj.playable
      #set_origin
      
      @top_playlists_limit = 10
      @top_playlists = current_site.top_playlists.all(:limit => @top_playlists_limit)
      
      sort_order = (params[:sort_by] =~ /highest_rated/i )? "comments.rating DESC" : "comments.updated_at DESC"
      @comments = @station_obj.playable.comments.valid(:order => sort_order).paginate :page => params[:page], :per_page => 5
    else
      if request.xhr?
        redirect_to channel_mixes_path(:without_layout => 1)
      else
        redirect_to channel_mixes_path
      end
      # @top_djs_limit = 5
      # @top_djs = current_site.top_djs.all(:limit => @top_djs_limit)
      # @top_playlists_limit = 6
      # @top_playlists = current_site.top_playlists.all(:limit => @top_playlists_limit)
      # 
      # @latest_badges = BadgeAward.latest(6)
      # 
      # @top_artists_limit = 5    
      # @top_artists = current_site.top_artists.all(:limit => @top_artists_limit)
    end
  end

  def album_detail
    if request.xhr?
      @station_obj = Station.find(params[:station_id]) rescue nil
      if @station_obj
        @station_obj = create_user_station(@station_obj)
        @station_obj.playable.track_a_play_for(current_user) if @station_obj.playable
        render :partial => @station_obj.playable.class.to_s.underscore
      end
    else
      redirect_to radio_path(:station_id => params[:station_id])
    end
  end

  def analytics
    @code = params.fetch(:pageTracker, '/radio')
    render :layout => false, :partial => 'shared/google_analytics', :locale => @code
  end

  def my_stations_list
    if request.xhr?
      if logged_in? 
        @station_obj = Station.find(params[:station_id]) rescue nil
        render :partial => "my_#{@station_obj.playable.class.to_s.pluralize.underscore}"
      end
    else
      redirect_to radio_path(:station_id => params[:station_id])
    end
  end

  def twitstation
    @top_stations = current_site.summary_top_stations.limited_to(5)
    begin
      if params[:station_id]
        @station_obj = Station.find(params[:station_id])
      elsif params[:artist_name]
        @station_obj = AbstractStation.find_by_name(params[:artist_name])
      end
      render :layout => "twitstation"
    rescue
      respond_to do |format|
        format.html { redirect_to profile_not_found_path(params[:artist_name]) }
        format.xml  { render :xml => {:message => "Profile Not Found"} }
      end
    end
  end

  def show
    @station = Station.find(params[:station_id]).playable
    @songs = if @station.kind_of? AbstractStation
      rec_engine.get_rec_engine_play_list(:artist_id => @station.amg_id)
    elsif @station.kind_of? UserStation
      rec_engine.get_rec_engine_play_list(:artist_id => @station.amg_id)
    elsif @station.kind_of? EditorialStation
      if @station.sites_available.include? current_site.id
        @station.playlist
      else
        render :xml => { :alert => 'This station cannot play in this market' }.to_xml(:root => 'response')
      end
    end
    respond_to do |format|
      format.html { render :layout => false }
      format.xml { render :layout => false }
    end
    #end
  end

  def play
    @station = Station.find( params[:station_id] ).playable
    if @station
      respond_to do |format|
        format.html do
          redirect_to radio_path(:station_id => @station.station.id, :queue => true)
        end
        block = Proc.new do
          session[:current_station] = @station.id
          render :xml => Player::Station.from(@station,
                 :ip => remote_ip,
                 :user_id => @station.kind_of?(UserStation) ? @station.owner_id : nil).to_xml(:root => @station.kind_of?(UserStation) ? 'user_station' : 'station')
        end
        format.xml(&block)
        format.js(&block)
        format.rss
      end

    else

      not_found_message = t('stations.could_not_find_artist', :artist => params[:id])
      respond_to do |format|
        format.html do
          flash[:error] = not_found_message
          redirect_to radio_path
        end
        format.js { render :text => not_found_message, :layout => false }
        format.xml { render :xml => Player::Error.new(:error => not_found_message, :code => 404) }
        format.rss do
          feed_site = site_code.match(/^msnca.*/) ? "msncanada" : site_code
          redirect_to "http://cm.cyloop.com/feeds/#{feed_site}/feed_top_stations_#{site_code}.xml"
        end
      end

    end

  end

  def search
    params[:search_station_id] = params[:station_id] if params.has_key?(:station_id) #this is for backwards compatibility
    
    @station = Station.find(params[:search_station_id]) rescue nil
    if @station
      respond_to do |format|
        format.html do
          redirect_to(radio_path(:station_id => @station.id, :queue => true))
        end
        @station = create_user_station(@station)
        @station.playable.track_a_play_for(current_user) if @station.playable
        block = Proc.new do
          session[:current_station] = @station.id
          render :xml => Player::Station.from(@station.playable,
           :ip => remote_ip,
           :user_id => logged_in? ? current_user.id : nil).to_xml(:root => @station.playable.kind_of?(UserStation) ? 'user_station' : 'station')
        end
        format.xml(&block)
        format.js(&block)
        format.rss
      end

    else
      params[:search_station_name] = params[:station_name] if params.has_key?(:station_name) #this is for backwards compatibility
      
      not_found_message = t('stations.could_not_find_artist', :artist => params[:search_station_name])
      respond_to do |format|
        format.html do
          flash[:error] = not_found_message
          redirect_to radio_path
        end
        format.js { render :text => not_found_message, :layout => false }
        format.xml { render :xml => Player::Error.new(:error => not_found_message, :code => 404) }
        format.rss do
          feed_site = site_code.match(/^msnca.*/) ? "msncanada" : site_code
          redirect_to "http://cm.cyloop.com/feeds/#{feed_site}/feed_top_stations_#{site_code}.xml"
        end
      end

    end

  end

  def artist_info
    if(artist.nil?)
      render :nothing => true
    else
      @tabs = [:more_playlists, :recommended_playlists, :emotions] #others are coming.
      @station_obj = Station.find(params[:station_id]) rescue nil
      render :partial => "radio/artist_info"
    end
  end
  
  def station_info
      @tabs = [:more_playlists, :top_playlists, :emotions] #others are coming.
      @station_obj = Station.find(params[:station_id]) rescue nil
      render :partial => "radio/station_info"
  end

  private
  def radio_show_cache_key_url
    "#{CURRENT_SITE.cache_key}/#{current_country.code}/#{params[:station_id]}/station/#{params[:id]}"
  end

  def top_stations
    @top_stations ||= current_site.summary_top_stations(:include => :station).limited_to(5)
  end
  helper_method :top_stations

  def artist
    # changed from Artist. to Account. since the STI has a unique identifier of id.
    @artist ||= (Account.find(params[:artist_id])) rescue nil
  end
  helper_method :artist

  def recent_listeners
    @recent_listeners ||= artist.recent_listens(14) rescue []
  end
  helper_method :recent_listeners

  def similar_artists
    @similar_artists ||= artist.similar(4) #rescue []
    @similar_artists
  end
  helper_method :similar_artists

  def most_listened_songs
    @most_listened_songs ||= artist.most_listened_songs(5)
  end
  helper_method :most_listened_songs
end

