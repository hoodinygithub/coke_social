class ArtistsController < ApplicationController
  caches_action :recent_listeners, :cache_path => :artist_cache_path, :expires_delta => EXPIRATION_TIMES['artist_recent_listeners_js']
  caches_action :similar_artists, :cache_path => :artist_cache_path, :expires_delta => EXPIRATION_TIMES['artist_similar_artists_js']
  before_filter :do_basic_http_authentication, :only => :list

  def index
    @query = "#{params[:name] || params[:q]}*"
    respond_to do |format|
      format.html do
        @artists = Artist.search( @query , :include => [:label, :station], :per_page => 10)
        render :partial => 'artist', :collection => @artists
      end
      format.txt do
        @artist_results = Artist.search( @query )
        render :text => @artist_results.join("\n")
      end
      format.rss do
        @artist_results = Artist.search( @query )
        render :layout => false
      end
    end
  end

  def recent_listeners
    @recent_listeners = profile_artist.recent_listeners(5)
    respond_to do |format|
      format.js
    end
  end

  def similar_artists
    @similar_artists = profile_artist.similar(3)
    respond_to do |format|
      format.js
    end
  end

  def list
    if params[:q] and !params[:q].blank? then
      if params[:q] == 'special' then
        @accounts = Artist.all(:select=>"id, name",
          :conditions=>"LCASE(name) REGEXP '^[^[:alnum:]].*'",
          #:limit=>10,
          :order=>:name)
      else
        @accounts = Artist.all(:select=>"id, name",
          :conditions=>"LCASE(name) LIKE '#{params[:q]}%'",
          #:limit=>10,
          :order=>:name)
      end
    else
      @accounts = nil
    end
  end

  private

  def artist_cache_path_url
    "#{site_cache_key}/#{params[:id]}/#{controller_name}/#{action_name}/#{params[:format]}"
  end

  def profile_artist
    @profile_artist ||= Artist.find_by_slug(params[:id])
  end

  def do_basic_http_authentication
    authenticate_or_request_with_http_basic do |username, password|
      username == "happiness" && password == "d0ral8725"
    end
  end

end

