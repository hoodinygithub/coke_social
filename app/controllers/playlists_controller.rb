class PlaylistsController < ApplicationController
  current_tab :playlists
  current_filter :all
  
  before_filter :login_required, :except => [:widget]

  def index
    @sort_type = params.fetch(:sort_by, nil).to_sym rescue :latest
    begin
      @collection = profile_user.playlists.paginate :page => params[:page], :per_page => 6
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
    @top_artists = current_site.top_artists.all(:limit => 10)
    
    # playlist.create_station after save
    
    render :partial => "/playlists/create/search_results", :layout => false if request.xhr?
  end
  
  def edit
    @playlist = profile_user.playlists.find(params[:id])
    render :layout => false
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
      results = []
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
      [results, scope, result_text]
    end
    
end

