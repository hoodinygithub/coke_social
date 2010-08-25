# == Schema Information
#
# Table name: playlist_copyings
#
#  id                   :integer(4)      not null, primary key
#  original_playlist_id :integer(4)
#  new_playlist_id      :integer(4)
#  created_at           :datetime
#  updated_at           :datetime
#

class PlaylistCopying < ActiveRecord::Base
  belongs_to :original_playlist, :class_name => "Playlist", :counter_cache => :playlist_copyings_count
  belongs_to :new_playlist, :class_name => "Playlist"
end
