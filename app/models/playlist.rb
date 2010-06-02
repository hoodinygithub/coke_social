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
  include Station::Playable

  acts_as_taggable

  acts_as_commentable
  acts_as_rateable(:class => 'Comment', :as => 'commentable')

  before_save :update_cached_artist_list
  before_create :increment_owner_total_playlists
  
  belongs_to :owner, :class_name => 'User', :conditions => { :network_id => 2 }
  delegate :network, :to => :owner
    
  has_many :items, :class_name => 'PlaylistItem', :order => "playlist_items.position ASC", :include => :song
  has_many :songs, :through => :items, :order => "playlist_items.position ASC"
  has_one :editorial_station, :foreign_key => 'mix_id'
  
  has_attached_file :avatar, :styles => { :album => "300x300#", :medium => "86x86#", :small => "60x60#" }
  validates_attachment_content_type :avatar,
    :content_type => ["image/jpeg", "image/png", "image/gif", "image/pjpeg", "image/x-png"]
      
  validates_presence_of :name
  
  default_scope :conditions => { :deleted_at => nil }  

  define_index do
    where "playlists.deleted_at IS NULL AND accounts.deleted_at IS NULL AND accounts.network_id = 2"
    indexes :name, :sortable => true
    indexes :cached_tag_list
    indexes :cached_artist_list
    set_property :min_prefix_len => 1
    set_property :enable_star => 1
    set_property :allow_star => 1
    has created_at, updated_at, owner(:network_id)
    has total_plays, :as => 'playlist_total_plays'
    has rating_cache, :sortable => true
  end
  
  # def self.search(*args)
  #   if RAILS_ENV =~ /test/ # bad bad bad
  #     options = args.extract_options!
  #     starts_with(args[0]).paginate :page => (options[:page] || 1)
  #   else
  #     args[0] = "#{args[0]}*"
  #     super(*args).compact        
  #   end
  # end

  def includes(limit=3)
    songs.all(:limit => limit).uniq_by { |s| s.artist_id }
  end
  
  def deactivate!
    update_attribute(:deleted_at, Time.now)
    self.owner.decrement!(:total_playlists)
  end

  def activate!
    update_attribute(:deleted_at, nil)
    increment_owner_total_playlists
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

  def update_cached_artist_list
    unless songs.empty?
      update_attribute(:cached_artist_list, includes.collect{ |s| s.artist.name rescue nil }.compact.join(', ') ) if cached_artist_list.blank?
    end
  end

  def increment_owner_total_playlists
    self.owner.increment!(:total_playlists)
  end

  def artists_contained(options = {})
    options[:limit] ||= 4
    options[:random] = true unless options.has_key?(:random)
    artists = songs.find(:all, :group => :artist_id, :limit => options[:limit]).collect { |s| s.artist }
    artists = artists.sort_by {rand} if options[:random]
    artists
  end

  # def artists
  #   @artists ||= Artist.find_by_sql( [ ARTISTS_FROM_PLAYLIST, self.id ] ).uniq
  # end

  def avatar_with_default
    if avatar_file_name.blank? && owner && !owner.avatar_file_name.blank?
      owner.avatar
    else
      avatar_without_default
    end
  end

  def tag_cloud
    @tags = self.tag_counts
  end

  def update_tags(tags)
    tags = tags.map { |m| m.gsub(/\"/,"") unless m.blank? }.compact
    unless tags.empty?
      transaction do
        self.taggings.destroy_all
        self.tag_list.clear
        self.tag_list.add(tags) 
        self.save
        owner.update_cached_tag_list
      end
    end
  end
  
  def add_tags(tags)
    tags = tags.split(/('.*?'|".*?"|\s+)/).map { |m| m.gsub(/\"/,"") unless m.blank? }.compact
    
    unless tags.empty?
      transaction do
        self.tag_list.add(tags) 
        self.save
        owner.update_cached_tag_list
      end
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

  def rate_with(rating)
    add_rating(rating)
    update_attribute('rating_cache', self.rating)
  end

end
