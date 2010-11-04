# == Schema Information
#
# Table name: valid_tags
#
#  id         :integer(4)      not null, primary key
#  site_id    :integer(4)
#  tag_id     :integer(4)
#  deleted_at :datetime
#  created_at :datetime
#  updated_at :datetime
#

class ValidTag < ActiveRecord::Base
  belongs_to :tag
  belongs_to :site
  validates_uniqueness_of :tag_id, :scope => :site_id
  
  default_scope :conditions => { :deleted_at => nil }, :order => "promo_id DESC"
  
  attr_accessor :tag_name
  
  before_validation :find_and_update_tag_related
  
  def playlists
    Tagging.count(:conditions => ["taggable_type = 'Playlist' and tag_id = ?", tag_id])
  end
  
  def mark_as_deleted
    self.deleted_at = Time.now
    save(false)
  end
  
  def unmark_as_deleted
    self.deleted_at = nil
    save(false)
  end
  
  def self.site_ids
    all(:group => "site_id").map{|t| t.site_id}
  end  
  
  def self.all_deleted
    with_exclusive_scope do
      all :conditions => "deleted_at IS NOT NULL"
    end
  end  
  
  def self.find_with_deleted(id)
    with_exclusive_scope do
      find(id)
    end
  end  
  
  def self.all_with_deleted(*args)
    with_exclusive_scope do
      all(*args)
    end
  end
  
  def name
    self.promo.blank? ? self.tag.name : self.tag.name.upcase
  end  
private
  def find_and_update_tag_related
    self.tag ||= Tag.find_or_create_by_name(tag_name.downcase.capitalize)
  end
end
