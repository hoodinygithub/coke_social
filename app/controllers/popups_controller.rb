class PopupsController < ApplicationController

  layout 'popup'

  def index
    @station_obj = nil
    station = Station.find_by_id_and_playable_type(params[:station_id], 'Playlist') rescue nil
    @station_obj = station if station and station.playable and station.playable.owner and station.playable.owner.active?
    @station_queue = @station_obj.playable.station_queue(:ip_address => remote_ip) if @station_obj
  end
  
  def widget
    respond_to do |format|
      format.js
    end
  end

end
