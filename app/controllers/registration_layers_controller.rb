class RegistrationLayersController < ApplicationController
  before_filter :find_stats
  before_filter :not_display_layer, :except => [:add_song, :radio_add_song]  
  before_filter :display_layer, :only => [:add_song, :radio_add_song, :copy_playlist, :create_playlist, :review_playlist]  
  before_filter :set_return_to
  before_filter :set_return_to_with_back, :only => [:radio_add_song, :max_radio, :add_mixer, :max_song, :copy_playlist, :create_playlist, :review_playlist]
    
  def index
  end

  def follow_artist
  end

  def follow_user
  end

  def add_song
  end

  def add_mixer
  end

  def max_song
  end
  
  def radio_add_song
    render :action => :add_song
  end  
  
  def max_radio
    render :action => :max_song    
  end  

  def copy_playlist
  end

  def create_playlist
  end

  def review_playlist
  end
    
  private
    def find_stats
      @account = Account.find(params[:account_id]) if params[:account_id]
      @songs   = current_site.site_statistic.total_songs   rescue 0
      @artists = current_site.site_statistic.total_artists rescue 0
      @users   = current_site.site_statistic.total_global_users   rescue 0
      @code    = "/registration/#{params[:action].classify.downcase}layer"
    end
    
    def set_return_to_with_back
      session[:return_to] = request.referer
    end
end
