# == Schema Information
#
# Table name: accounts
#
#  id                               :integer(4)      not null, primary key
#  email                            :string(255)
#  name                             :string(255)
#  crypted_password                 :string(40)
#  salt                             :string(40)
#  created_at                       :datetime
#  updated_at                       :datetime
#  remember_token                   :string(255)
#  remember_token_expires_at        :datetime
#  gender                           :string(255)
#  born_on                          :date
#  marketing_opt_out                :boolean(1)
#  confirmation_code                :string(255)
#  slug                             :string(255)
#  type                             :string(255)
#  followee_cache                   :text
#  avatar_file_name                 :string(255)
#  avatar_content_type              :string(255)
#  avatar_file_size                 :integer(4)
#  avatar_updated_at                :datetime
#  amg_id                           :string(10)
#  city_id                          :integer(4)
#  receives_following_notifications :boolean(1)      default(TRUE)
#  websites                         :text
#  entry_point_id                   :integer(4)
#  color_header_bg                  :string(6)
#  color_main_font                  :string(6)
#  color_links                      :string(6)
#  color_bg                         :string(6)
#  private_profile                  :boolean(1)      default(FALSE)
#  cell_index                       :integer(4)
#  background_file_name             :string(255)
#  background_content_type          :string(255)
#  background_file_size             :integer(4)
#  background_updated_at            :datetime
#  background_align                 :string(255)
#  background_repeat                :string(255)
#  background_fixed                 :boolean(1)
#  deleted_at                       :datetime
#  created_by_id                    :integer(4)
#  status                           :string(255)
#  genre_id                         :integer(4)
#  default_locale                   :string(255)
#  label_id                         :integer(4)
#  song_play_count                  :integer(4)      default(0)
#  followee_count                   :integer(4)      default(0)
#  follower_count                   :integer(4)      default(0)
#  influences                       :text
#  label_type                       :string(255)
#  management_email                 :string(255)
#  reset_code                       :string(255)
#  visit_count                      :integer(4)      default(0)
#  total_listen_count               :integer(4)      default(0)
#  music_label                      :string(255)
#  msn_live_id                      :string(255)
#  twitter_username                 :string(255)
#  twitter_id                       :integer(4)
#  songs_count                      :integer(4)      default(0)
#  has_custom_profile               :boolean(1)      default(FALSE)
#  ip_address                       :string(255)
#  country_id                       :integer(4)
#  total_user_stations              :integer(4)      default(0), not null
#  total_albums                     :integer(4)      default(0), not null
#  cached_tag_list                  :text
#  network_id                       :integer(4)
#  total_playlists                  :integer(4)      default(0), not null
#  total_badges                     :integer(4)      default(0), not null
#  receives_coke_newsletter         :boolean(1)      default(TRUE), not null
#  encrypted_born_on_string         :string(255)
#  encrypted_name                   :string(255)
#  encrypted_gender                 :string(255)
#  encrypted_email                  :string(255)
#  receives_reviews_notifications   :boolean(1)      default(TRUE), not null
#  receives_badges_notifications    :boolean(1)      default(TRUE), not null
#

class User < Account
  include Account::Encryption
  include Account::Authentication  
  include Account::ProfileColors
  include Account::FolloweeCache
  include Account::SingleShortBio
  include Account::RegistrationStates
  include Searchable::ByNameAndSlug

  index [:type]

  after_update :update_followings_with_partial_name

  default_scope :conditions => { :network_id => 2 }  
  has_one :bio, :autosave => true, :foreign_key => :account_id
  validates_associated :bio

  has_many :stations,  
           :foreign_key => :owner_id,
           :select => "user_stations.*",
           :class_name => "UserStation",
           :include => :abstract_station,
           :source => :abstract_station,
           :conditions => 'abstract_stations.deleted_at IS NULL AND user_stations.deleted_at IS NULL'

  has_many :comments,  
           :foreign_key => :user_id,
           :conditions => "commentable_type = 'Playlist'"

  has_many :playlists, :foreign_key => :owner_id, :conditions => 'playlists.deleted_at IS NULL' do
    def top(limit = 4)
      all(:order => 'total_plays DESC', :limit => limit)
    end

    def latest(limit = 6)
      all(:order => 'updated_at DESC', :limit => limit)
    end
  end

  has_many :taggings, :through => :playlists

  # Until we know what a promo is (besides id and timestamps), I haven't created a promo or promo_sites table.  CokeBR just doesn't play.
  has_many :badge_awards, :foreign_key => :winner_id, :include => :badge,
    :conditions => (ApplicationController.current_site.id == 22 ? "badges.promo_id IS NULL" : nil) do
    def notifications
      all(:conditions => 'notified_at IS NULL')
    end
    def set_notified!
      # Doesn't work because badges.promo_id in this scope is not a valid update condition
      # update_all('notified_at = now()', 'notified_at IS NULL')
      notifications.each{ |ba| ba.notified_at = Time.now(); ba.save! }
    end
  end
  has_many :badges, :through => :badge_awards, :include => :badge_awards, 
    :conditions => (ApplicationController.current_site.id == 22 ? { :promo_id => nil } : nil)

  has_many :followings, :foreign_key => 'follower_id'
  has_many :followees, :through => :followings, :conditions => "accounts.type = 'User' AND accounts.network_id = 2 AND followings.approved_at IS NOT NULL", :source => :followee do
    def with_badge(badge, limit=9)
      badge = if badge.is_a?(BadgeAward)
        badge.badge_id
      elsif badge.is_a?(Badge)
        badge.id
      else
        badge
      end
      
      find(:all, :joins => "INNER JOIN `badge_awards` ON `followings`.`followee_id` = `badge_awards`.`winner_id` AND `badge_awards`.`badge_id` = #{badge}", :limit => limit, :order => 'badge_awards.created_at DESC').uniq
    end

    def with_limit(limit=10)
      find(:all, :limit => limit)
    end
  end

  has_many :blocks_as_blockee, :class_name => 'Block', :foreign_key => 'blockee_id'
  has_many :blockers, :through => :blocks_as_blockee, :source => :blocker
  has_many :blockees, :through => :blocks, :source => :blockee
  has_many :blocks, :foreign_key => 'blocker_id'
  has_many :messages

  belongs_to :entry_point, :class_name => 'Site', :foreign_key => 'entry_point_id'
  belongs_to :network
  
  validates_presence_of :entry_point_id
  validates_presence_of :born_on_string

  validates_inclusion_of :gender, :in => ['Male', 'Female'], :message => :gender

  validate :check_born_on_in_future, :unless => Proc.new { |user| user.born_on.blank? }
  validate :check_age_is_at_least_13, :unless => Proc.new { |user| user.born_on.blank? }
  
  validates_uniqueness_of :sso_facebook, :scope => :deleted_at, :allow_nil => true
  validates_uniqueness_of :msn_live_id, :scope => :deleted_at, :allow_nil => true

  def self.forgot?(attributes, current_site=nil)
    user = User.new(attributes)
    if user.email.to_s.blank?
      user.errors.add(:email, I18n.t("activerecord.errors.messages.blank"))
    elsif !(user.email =~ EMAIL_REGEXP)
      user.errors.add(:email, I18n.t("activerecord.errors.messages.invalid"))
    end

    if user.slug.to_s.blank?
      user.errors.add(:slug, I18n.t("activerecord.errors.messages.blank"))
    end    
    
    if user.errors.empty?
      network_ids = current_site.networks.collect(&:id)
      user = User.find_by_email_and_slug_and_deleted_at_and_network_id( attributes[:email], attributes[:slug], nil, network_ids )
    end
    user
  end

  def <=>(b)
    id <=> b.id
  end

  def tag_counts_from_playlists(current_site, limit=60)
    options = { :select => "DISTINCT tags.*",
                :joins => "INNER JOIN #{Tagging.table_name} ON #{Tag.table_name}.id = #{Tagging.table_name}.tag_id INNER JOIN #{Playlist.table_name} ON #{Tagging.table_name}.taggable_id = #{Playlist.table_name}.id AND #{Tagging.table_name}.taggable_type = 'Playlist' INNER JOIN valid_tags ON valid_tags.tag_id = #{Tag.table_name}.id",
                :order => "taggings.created_at DESC",
                :conditions => "playlists.owner_id = #{self.id} AND playlists.deleted_at IS NULL AND valid_tags.site_id = #{current_site.id} AND valid_tags.deleted_at IS NULL",
                :limit => limit }

    Tag.all(options)
    # options = { :limit => limit, 
    #             :joins => "INNER JOIN #{Playlist.table_name} ON #{Tagging.table_name}.taggable_id = #{Playlist.table_name}.id AND #{Tagging.table_name}.taggable_type = 'Playlist'",
    #             :order => "taggings.created_at DESC",
    #             :conditions => "playlists.owner_id = #{self.id}" }
    # Tag.counts(options)
  end

  def tags_from_playlists
    taggings.map(&:tag)
  end

  def update_cached_tag_list
    update_attribute(:cached_tag_list, TagList.new(tags_from_playlists.map(&:name)).to_s)
  end

  def follow(followee)
    followee_id = followee.kind_of?(Account) ? followee.id : followee
    following = followings.create(:followee_id => followee_id, :followee_name => User.find(followee_id).name[0..2], :follower_name => self.name[0..2])
  end

  def unfollow(followee_id)
    followee_id = followee_id.id if followee_id.kind_of? Account
    if following = followings.find_by_followee_id(followee_id)
      following.destroy
    end
  end

  def follows?(followee_id)
    followee_id = followee_id.id if followee_id.kind_of? Account
    # followings.approved.exists?(:followee_id => followee_id)
    cached_followee_ids.include?(followee_id)
  end

  def awaiting_follow_approval?(followee_id)
    followee_id = followee_id.id if followee_id.kind_of? Account
    # followings.pending.exists?(:followee_id => followee_id)
    cached_pending_followee_ids.include?(followee_id)
  end

  def can_enter?(site)
    site && site.allowed_entry_points.include?(entry_point_id) ? true : false
  end

  def create_user_station(options={})
    user_station = nil
    transaction do
      user_station = UserStation.create(options.merge({:owner => self}))
      user_station.create_station
      self.increment!(:total_user_stations)
    end
    user_station.station if user_station
  end

  def block(blockee_id)
    blockee_id = blockee_id.id if blockee_id.kind_of? User
    Block.create! :blocker_id => id, :blockee_id => blockee_id
    playlists.each { |p| p.update_attribute('rating_cache', p.rating); p.save! }
  end
  
  def unblock(blockee_id)
    blockee_id = blockee_id.id if blockee_id.kind_of? User
    blocked = Block.first(:conditions => {:blocker_id => id, :blockee_id => blockee_id})
    blocked.destroy if blocked
    playlists.each { |p| p.update_attribute('rating_cache', p.rating); p.save! }
  end

  def blocks?(blockee_id)
    blockee_id = blockee_id.id if blockee_id.kind_of? User
    blocks.map(&:blockee_id).include?(blockee_id)
  end

  def blocked_by?(blocker_id)
    blocker_id = blocker_id.id if blocker_id.kind_of? User
    blockers.map(&:id).include?(blocker_id)
  end

  def user?
    true
  end

  # User is part of the current site's network
  def part_of_network?
    ApplicationController.current_site.networks.include? self.network
  end

  # User is part of a secure network with encrypted demographics
  def secure_network?
    # TODO: add boolean column network.is_secure
    self.network_id == 2
  end

  def private?
    self.private_profile
  end

  def default_locale
    result = begin
      YAML.load( self.read_attribute(:default_locale) )
    rescue
      self.read_attribute(:default_locale)
    end
    result || (self.entry_point && self.entry_point.default_locale)
  end

  def cached_followee_ids
    Rails.cache.fetch("#{cache_key}/followee_ids") do
      followings.approved.find(:all, :select => 'followee_id').map{|f| f.followee_id}
    end
  end

  def cached_pending_followee_ids
    Rails.cache.fetch("#{cache_key}/pending_followee_ids") do
      followings.pending.find(:all, :select => 'followee_id').map{|f| f.followee_id}
    end
  end

  def win_badge(badge)
    badge = badge.is_a?(Fixnum) ? Badge.find(badge) : badge
    BadgeAward.find_or_create_by_badge_id_and_winner_id(:badge_id => badge.id, :winner_id => self.id, :name => badge.name,  :name_coke_es => badge.name_coke_es, :name_coke_br => badge.name_coke_br)
  end

  after_destroy :remove_customizations
  def remove_customizations
    CustomizationWriter.new(self).remove_css if File.exists?(CustomizationWriter.css_path(self.id))
  end

  def remove_avatar
    self.avatar_file_name    = nil
    self.avatar_content_type = nil
    self.avatar_file_size    = nil
    self.avatar_updated_at   = nil
    self.save
  end

  def custom_errors
    on_convention = [I18n.t("activerecord.errors.messages.blank"), 
                     I18n.t("activerecord.errors.messages.confirmation")]
    errors_hash = self.errors.inject({}) { |h,(k,v)| h[k] ||= on_convention.include?(v) ? "#{self.class.human_attribute_name(k)} #{v}" : v; h }
    errors_hash.to_a
  end

  def born_on=(date)
    self.born_on_string = date.to_s if date and date.is_a?(Date)
  end

  def born_on
    Date.parse(born_on_string) unless born_on_string.nil?
  end

  protected
  def check_born_on_in_future
    errors.add(:born_on, :cant_be_in_future) if born_on > Date.today
  end

  def check_age_is_at_least_13
    errors.add(:born_on, I18n.t("registration.must_be_13_years_older")) if underage?
  end

  def update_followings_with_partial_name
    if name_changed? or encrypted_name_changed?
      followings.update_all(:follower_name => self.name[0..2]) 
      followings_as_followee.update_all(:followee_name => self.name[0..2]) 
    end
  end


  # deprecated.  Use find_by_email_with_exclusive_scope.  It supports additional find conditions.
  def self.find_by_email_on_all_networks(email)
    unless email.nil?
      with_exclusive_scope do
        encrypted_email = User.encrypt_email(email)
        users = User.find_by_sql ["SELECT * FROM accounts WHERE type = 'User' AND (email = ? or encrypted_email = ?) AND deleted_at IS NULL", 
          email, 
          encrypted_email]
        users.first
      end
    end
  end

  def self.find_with_exclusive_scope( *args )
    with_exclusive_scope do
      find(*args)
    end
  end

  # Don't use this directly.  Use find_by_email_with_exclusive_scope to find across all sites.
  named_scope :with_email, lambda { |email|
    { :conditions => ["deleted_at IS NULL AND (email = ? OR encrypted_email = ?)", email, User.encrypt_email(email)] }
  }
  # Find by email, ignoring default scopes.  Supports additional find options.
  def self.find_by_email_with_exclusive_scope(email, *args)
    args = [ :all ] if args.size == 0

    with_exclusive_scope {
      with_email(email).find(*args)
    }
  end
end

