# == Schema Information
#
# Table name: playlists
#
#  id             :integer(4)      not null, primary key
#  owner_id       :integer(4)
#  name           :string(255)
#  comments_count :integer(4)      default(0)
#  songs_count    :integer(4)      default(0)
#  created_at     :datetime
#  updated_at     :datetime
#  total_time     :integer(4)      default(0)
#

class Playlist < ActiveRecord::Base
  include AvatarImporter

  define_index do
    where "deleted_at IS NULL"
    indexes :name, :sortable => true
    set_property :min_prefix_len => 1
    set_property :enable_star => 1
    set_property :allow_star => 1
    has created_at
  end

  belongs_to :owner, :class_name => 'User'

  has_many :songs, :through => :items, :order => "playlist_items.position ASC"
  has_many :items, :class_name => 'PlaylistItem', :order => "playlist_items.position ASC", :include => :song
  has_one :editorial_station, :foreign_key => 'mix_id'
  
  has_attached_file :avatar, :styles => { :album => "300x300#", :medium => "86x86#", :small => "60x60#" }
  validates_attachment_content_type :avatar,
    :content_type => ["image/jpeg", "image/png", "image/gif", "image/pjpeg", "image/x-png"]
    
  validates_presence_of :name

  def includes(limit=3)
    songs.all(:limit => limit).uniq_by { |s| s.artist_id }
  end
  
  def deactivate!
    update_attribute(:deleted_at, Time.now)
  end

  def activate!
    update_attribute(:deleted_at, nil)
  end

  def owner_is?(user)
    is_owner = false
    unless user.nil?
      is_owner = owner == user 
    end
  end
  
  def station_queue(params={})
    "/playlists/#{id}.xml"
  end  
  
  def artists_contained(options = {})
    options[:limit] ||= 4
    options[:random] = true unless options.has_key?(:random)
    artists = songs.find(:all, :group => :artist_id, :limit => options[:limit]).collect { |s| s.artist }
    artists = artists.sort_by {rand} if options[:random]
    artists
  end

  def artists
    @artists ||= Artist.find_by_sql( [ ARTISTS_FROM_PLAYLIST, self.id ] ).uniq
  end

  def avatar_with_default
    if avatar_file_name.blank? && owner && !owner.avatar_file_name.blank?
      owner.avatar
    else
      avatar_without_default
    end
  end

  def gender
    owner.gender
  end
  
  def total_time
    @total_time ||= items.sum(:duration).to_i
  end
 
  ARTISTS_FROM_PLAYLIST = %Q!
    SELECT a.* FROM accounts a
    INNER JOIN songs s ON a.id = s.artist_id
    INNER JOIN playlist_items p ON p.song_id = s.id
    WHERE p.playlist_id = ?
  !

end
