class DashboardsController < ApplicationController
  before_filter :login_required
  before_filter :auto_follow_profile

  layout_except_xhr 'application'

  def show
    @dashboard_menu = :home
    
    @top_playlists = current_site.top_playlists.all(:limit => 6)
    
    respond_to do |format|
      format.html
      format.json do
        render :text => profile_user.activity_feed
      end
    end
  end

end

