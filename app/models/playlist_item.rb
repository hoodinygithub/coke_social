# == Schema Information
#
# Table name: playlist_items
#
#  id          :integer(4)      not null, primary key
#  playlist_id :integer(4)
#  song_id     :integer(4)
#  position    :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

class PlaylistItem < ActiveRecord::Base
  acts_as_list :scope => :playlist

  default_scope :conditions => "playlist_items.id IN (
    SELECT playlist_items.id FROM playlist_items, songs WHERE 
      playlist_items.song_id = songs.id and songs.deleted_at IS NULL
  )"

  after_save :increment_playlist_total_time
  before_destroy :decrement_playlist_total_time

  belongs_to :song
  belongs_to :playlist, :counter_cache => :songs_count
  
  validates_presence_of :song, :playlist

  validates_uniqueness_of :song_id, :scope => :playlist_id

  delegate :artist, :title, :duration, :avatar, :to => :song, :allow_nil => true

  def increment_playlist_total_time
    playlist.update_attribute(:total_time, playlist.songs.sum(:duration))
  end

  def decrement_playlist_total_time
    duration = 0 if duration.blank?
    playlist.update_attribute(:total_time, playlist.songs.sum(:duration) - duration)
  end

end
