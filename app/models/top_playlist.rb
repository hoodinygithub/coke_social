# == Schema Information
#
# Table name: top_playlists
#
#  id             :integer(4)      not null, primary key
#  playlist_id    :integer(4)
#  site_id        :integer(4)
#  total_requests :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#

class TopPlaylist < ActiveRecord::Base
  include Db::Predicates::LimitedTo
  include Summary::Predicates
  belongs_to :site
  belongs_to :playlist
end
