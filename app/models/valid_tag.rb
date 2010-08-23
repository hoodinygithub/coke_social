class ValidTag < ActiveRecord::Base
  belongs_to :tag
  belongs_to :site
  
  attr_accessor :tag_name
  delegate :name, :to => :tag
  
  before_validation :find_and_update_tag_related
  after_destroy :remove_taggings_records
  
  define_index do
    where "valid_tags.deleted_at IS NULL"
    indexes tag.name, :sortable => true
    
    # Added for Playlist Create sorting
    has tag.name, :as => :tag_name, :sortable => true
    #
    has tag(:id), :as => :tag_id
    has site(:id), :as => :site_id
    
    set_property :min_prefix_len => 1
    set_property :enable_star => 1
    set_property :allow_star => 1
  end
  
  def playlists
    Tagging.count(:conditions => ["taggable_type = 'Playlist' and tag_id = ?", tag_id])
  end
  
  def self.search(params={})
    conditions = "" 
    if params
      conditions << "site_id:#{params[:market]} " if params[:market]
      conditions << "tag_name:#{params[:tag_name]}*" if params[:tag_name]      
    end
    super(conditions)
  end
  
  def mark_as_deleted
    self.deleted_at = Time.now
    save(false)
  end
  
private
  def find_and_update_tag_related
    self.tag ||= Tag.find_or_create_by_name(tag_name)
  end
  
  def remove_taggings_records
    
  end
end
