require File.dirname(__FILE__) + '/lib/acts_as_taggable'

Tag.class_eval do

  has_many :valid_tags #, :conditions => { :site_id => ApplicationController.current_site.id }
  # ApplicationController.current_site isn't defined yet

  def nickname
    #ValidTag.find_by_tag_id(self.id).try(:promo_id).blank? ? name : name.try(:upcase).try(:gsub, 'ñ', 'Ñ').try(:gsub, 'á', 'Á')
    # use select instead of find conditions to take advantage of include caching
    valid_tags.select{|t| t.site_id == ApplicationController.current_site.id}.first.promo_id.blank? ? name : name.upcase.gsub('ñ', 'Ñ').gsub('á', 'Á')
  end
  
  def to_s
    nickname
  end
  
end
