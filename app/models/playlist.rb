# == Schema Information
#
# Table name: playlists
#
#  id                      :integer(4)      not null, primary key
#  owner_id                :integer(4)
#  name                    :string(255)
#  reviews_count           :integer(4)      default(0), not null
#  songs_count             :integer(4)      default(0)
#  created_at              :datetime
#  updated_at              :datetime
#  deleted_at              :datetime
#  total_time              :integer(4)      default(0)
#  avatar_file_name        :string(255)
#  avatar_file_size        :integer(4)
#  avatar_content_type     :string(255)
#  avatar_updated_at       :datetime
#  total_plays             :integer(4)      default(0), not null
#  locked                  :boolean(1)      default(TRUE), not null
#  cached_tag_list         :text
#  cached_artist_list      :text
#  rating_cache            :float           default(0.0), not null
#  site_id                 :integer(4)
#  playlist_copyings_count :integer(4)      default(0), not null
#  locked_at               :datetime
#

class Playlist < ActiveRecord::Base
  include AvatarImporter
  include Station::Playable
  include Badges::Awards

  acts_as_taggable

  acts_as_commentable
  acts_as_rateable(:class => 'Comment', :as => 'commentable')

  before_save :update_cached_artist_list
  # after_save :award_xmas_badges_playlist
  before_create :increment_owner_total_playlists

  belongs_to :site
  belongs_to :owner, :class_name => 'User'
  delegate :networks, :to => :owner

  has_many :items, :class_name => 'PlaylistItem', :conditions => "songs.deleted_at IS NULL AND accounts.deleted_at IS NULL", :order => "playlist_items.position ASC", :include => { :song => :artist }
  has_many :songs, :through => :items, :order => "playlist_items.position ASC", :include => :artist, :conditions => { :deleted_at => nil }
  has_one :editorial_station, :foreign_key => 'mix_id'

  has_attached_file :avatar, :styles => { :album => "300x300#", :medium => "86x86#", :small => "60x60#", :large => "150x150#" }, :url => "/system/playlists/:sharded_id/:style/:basename.:extension", :path => ':rails_root/public/system/playlists/:sharded_id/:style/:basename.:extension'
  validates_attachment_content_type :avatar,
    :content_type => ["image/jpeg", "image/png", "image/gif", "image/pjpeg", "image/x-png"]

  validates_presence_of :name

  has_many :playlist_copyings, :foreign_key => 'original_playlist_id'
  has_many :copies, :through => :playlist_copyings, :source => :new_playlist
  has_one :playlist_copying, :foreign_key => 'new_playlist_id'
  has_one :copied_from, :through => :playlist_copying, :source => :original_playlist

  has_many :badge_awards

  default_scope :conditions => { :deleted_at => nil }  

  define_index do
    where "playlists.deleted_at IS NULL AND accounts.deleted_at IS NULL AND networks.id = 1"
    indexes :cached_tag_list
    indexes "UPPER(playlists.name)", :as => :normalized_name, :sortable => true
    indexes :cached_artist_list
    set_property :min_prefix_len => 1
    set_property :enable_star => 1
    set_property :allow_star => 1
    has :created_at, :updated_at, owner(:id)
    has owner.networks(:id)
    has :total_plays, :as => :playlist_total_plays
    has :rating_cache, :as => :rating_cache
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
    songs.all(:limit => limit, :group => 'songs.artist_id')
  end
  
  def deactivate!
    update_attribute(:deleted_at, Time.now)
    self.owner.decrement!(:total_playlists)
  end

  def activate!
    update_attribute(:deleted_at, nil)
    increment_owner_total_playlists
  end

  def award_mixmaster_badges
    badge_keys = { :mixmaster_white => 2, :mixmaster_yellow => 5, :mixmaster_green => 10, :mixmaster_brown => 25, :mixmaster_black => 50, :mixmaster_red => 100 }
    badge_keys.each_pair do |k, v|
      if owner.total_playlists >= v
        award_badge(k, owner)
      end
    end      
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
      self.cached_artist_list = all_artists.collect(&:name).join(', ')
    end
    add_default_avatar_if_none_defined
  end

  def increment_owner_total_playlists
    self.owner.increment!(:total_playlists)
    award_mixmaster_badges
  end

  def all_artists
    songs.find(:all, :group => 'songs.artist_id').collect(&:artist).compact
  end

  def artists_contained(options = {})
    options[:limit] ||= 4
    options[:random] = true unless options.has_key?(:random)
    artists = songs.find(:all, :group => 'songs.artist_id', :limit => options[:limit]).collect { |s| s.artist }
    artists = artists.sort_by {rand} if options[:random]
    artists
  end

  # ARTISTS_FROM_PLAYLIST = %Q!
  #   SELECT a.* FROM accounts a
  #   INNER JOIN songs s ON a.id = s.artist_id
  #   INNER JOIN playlist_items p ON p.song_id = s.id
  #   WHERE p.playlist_id = ?
  # !
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

  def tag_cloud(current_site=nil)
    conditions = "taggings.taggable_id = #{self.id}"
    joins      = "INNER JOIN #{Tagging.table_name} ON #{Tag.table_name}.id = #{Tagging.table_name}.tag_id AND #{Tagging.table_name}.taggable_type = 'Playlist'"
    
    unless current_site.nil?
      conditions << " AND valid_tags.site_id = #{current_site.id} AND valid_tags.deleted_at IS NULL"
      joins      << " INNER JOIN valid_tags ON valid_tags.tag_id = #{Tag.table_name}.id"
    end
    
    options = { :select => "DISTINCT tags.*",
                :joins => joins,
                :order => "taggings.created_at DESC",
                :conditions => conditions }
                
    @tags = Tag.all(options)
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

  def tags=(string)
    update_tags(string.split(','))
  end

  def gender
    owner.gender
  end
  
  def total_time
    @total_time ||= items.sum(:duration).to_i
  end
 
  def rate_with(p_review)
    add_rating(p_review)
    update_attribute(:rating_cache, rating) if rating_cache != rating
  end

   def to_s
    self.name
  end

  def valid_tags
    tags.all(:joins => "INNER JOIN valid_tags ON valid_tags.tag_id = tags.id",
      :conditions => ["valid_tags.site_id = ? and valid_tags.deleted_at IS NULL", ApplicationController.current_site.id])
  end
  
  # defaults to xmas promo
  def promo_tags(p_promo_id = 1)
    tags.all(:joins => "INNER JOIN valid_tags ON valid_tags.tag_id = tags.id",
      :conditions => ["valid_tags.promo_id = ? and valid_tags.site_id = ?", p_promo_id, ApplicationController.current_site.id])
  end

  def promo_playlist?(p_promo_id = 1)
    promo_tags(p_promo_id).size > 0
  end

  # Add default avatar if non added
  def add_default_avatar_if_none_defined
    # SET DEFAULT IF NONE DEFINED
    if avatar.path.nil?
      logger.info "############################ SETTING DEFAULT #########################"
      avatar = self.songs.first.album.avatar
      self.save
    end
  end

  # Default scopes with where conditions are evil.
  def self.find_including_deleted(p_id)
    with_exclusive_scope {
      Playlist.find(p_id)
    }
  end
end

