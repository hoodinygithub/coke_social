# == Schema Information
#
# Table name: station_listeners
#
#  id          :integer(4)      not null, primary key
#  station_id  :integer(4)
#  listener_id :integer(4)
#  total_plays :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

class StationListener < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'listener_id'
  belongs_to :station

end
