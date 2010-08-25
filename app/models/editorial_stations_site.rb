# == Schema Information
#
# Table name: editorial_stations_sites
#
#  id                   :integer(4)      not null, primary key
#  editorial_station_id :integer(4)
#  site_id              :integer(4)
#  profile_id           :integer(4)
#  created_at           :datetime
#  updated_at           :datetime
#  player_id            :integer(4)
#

class EditorialStationsSite < ActiveRecord::Base
  belongs_to :site
  belongs_to :editorial_station
end
