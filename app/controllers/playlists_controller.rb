class PlaylistsController < ApplicationController
  current_tab :playlists
  current_filter :all
  
  before_filter :login_required, :except => [:widget]

  def index
    @sort_type = params.fetch(:sort_by, nil).to_sym rescue :latest
    begin
      sort_types  = { :latest => 'playlists.updated_at DESC', 
                      :alphabetical => 'playlists.name',
                      :top => 'playlists.total_plays DESC'  }

      @collection = profile_user.playlists.paginate :page => params[:page], :per_page => 6, :order => sort_types[@sort_type]

      respond_to do |format|
        format.html
        format.xml { render :layout => false }
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to new_session_path
    end
  end

  def create
    @results,@scope,@result_text = get_seeded_results
    unless request.xhr?
      if request.post?
        @playlist_item_ids = []
        @playlist_item_ids = params[:item_ids].split(',').map { |i| Song.find(i) }.compact
        unless @playlist_item_ids.empty?
          playlist = current_user.playlists.create(:name => params[:name], :avatar => params[:avatar])
          current_user.update_attribute(:total_playlists, current_user.playlists.count);
          if playlist
            @playlist_item_ids.each do |song|
              playlist.items.create(:song => song)
            end
            playlist.update_tags(params[:tags].split(','))
            playlist.create_station
            redirect_to my_playlists_path
          end
        end
      end
      
      create_page_vars
    else
      render :partial => "/playlists/create/search_results", :layout => false
    end
  end
  
  def edit
    @playlist = profile_user.playlists.find(params[:id]) rescue nil
    if @playlist
      unless request.xhr?
        @playlist_item_ids = @playlist.items.map{|i| i.song_id} if @playlist
        if request.post?
          @playlist_item_ids = params[:item_ids].split(',').map { |i| Song.find(i) }.compact
          unless @playlist_item_ids.empty?
            @playlist.update_attributes(:name => params[:name], :avatar => params[:avatar])
            @playlist.items.destroy_all
            @playlist_item_ids.each do |song|
              @playlist.items.create(:song => song)
            end
            @playlist.update_tags(params[:tags].split(','))
            redirect_to my_playlists_path
          end
        end
        create_page_vars
      else
        render :layout => false
      end
    else
      redirect_to :action => :create
    end
  end

  def update
    @playlist = profile_user.playlists.find(params[:id])
    @playlist.update_attribute(:name, params[:playlist][:name])
    respond_to do |format|
      format.html { redirect_to my_playlists_path }
      format.js
    end
  end
  
  def widget
    @playlist = Playlist.find(params["id"])
    @last_box = params["last_box"] == "true"
    render :layout => false, :partial => "widget_item"
  end

  def show
    if params[:id] != "0"
      begin

        @playlist = Playlist.find(params[:id])

        if request.xhr?
          respond_to do |format|
            format.html { render :layout => false, :partial => "playlist_result", :object => @playlist }
            format.xml { render :layout => false }
          end
        elsif
          respond_to do |format|
            format.html { }
            format.xml { render :layout => false }
          end
        end
      rescue ActiveRecord::RecordNotFound
        redirect_to new_session_path
      end
    else
      if request.xhr?
        respond_to do |format|
          format.html { render :layout => false, :partial => "playlist_result" }
          format.xml { render :layout => false }
        end
      end
    end
  end

  def delete_confirmation
    @playlist = profile_user.playlists.find(params[:id])
    render :layout => false
  end

  def destroy
    @playlist = profile_user.playlists.find(params[:id])
    #This query is very heavy - checking the existence of the playlist at render-time instead
    #NewActivityStore.delete_all("data like '%\"playlist_id\":#{@playlist.id},%'")
    @playlist.deactivate!
    respond_to do |format|
      format.js
      format.html { redirect_to :back }
    end
  end
  
  private
    def get_seeded_results
      results = nil
      result_text = ""
      
      scope = (params[:scope] =~ /(song|artist|album)/i) ? params[:scope].to_sym : nil
      if(scope)
        obj = scope.to_s.classify.constantize
        if params[:term]
          results = obj.search(params[:term]) rescue nil
          result_text = params[:term]
        elsif params[:item_id]
          obj_item = obj.find(params[:item_id]) rescue nil
          results = obj_item.songs if obj_item
          result_text = obj_item.to_s
        end
      end
      results.compact! unless results.nil?
      [results, scope, result_text]
    end
    
    def create_page_vars
      @player_id = current_site.players.all(:conditions => "player_key = 'ondemand_#{current_site.code}'")[0].id rescue nil
      @top_artists = current_site.top_artists.all(:limit => 10)
      @playlist_item_ids ||= session[:playlist_item_ids].nil? ? [] : session[:playlist_item_ids]
      @playlist_items ||= @playlist_item_ids.empty? ? [] : Song.find(@playlist_item_ids)
    end
end

