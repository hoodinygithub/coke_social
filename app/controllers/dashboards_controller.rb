class DashboardsController < ApplicationController
  before_filter :login_required
  before_filter :find_user_stations
  before_filter :auto_follow_profile

  current_tab :dashboard
  current_filter :songs
  layout_except_xhr 'application'

  RECOMMENDED_STATIONS = 6

  def show
    @dashboard_menu = :home
    @mixes_recommended = (1..6).to_a

    stations = transformed_recommended_stations(40)
    @recommended_stations = stations[0..(RECOMMENDED_STATIONS-1)]
    @recommended_stations_queue = stations[RECOMMENDED_STATIONS..(stations.size)]

    respond_to do |format|
      format.html
      format.json do
        render :text => profile_user.activity_feed
      end
    end
  end

private
  # this is solely to cache so we don't do a ton of queries
  def find_user_stations
    stations = profile_user.stations.all(:limit => 5, :include => [:abstract_station])
    artist_ids = stations.map{|s| s.abstract_station.artist_id}
    Artist.find_all_by_id artist_ids
  rescue
  end
end

