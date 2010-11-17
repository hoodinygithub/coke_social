require File.dirname(__FILE__) + '/lib/acts_as_taggable'

Tag.class_eval do

  def nickname
    ValidTag.find_by_tag_id(self.id).try(:promo_id).blank? ? name : name.try(:upcase).try(:gsub, 'ñ', 'Ñ').try(:gsub, 'á', 'Á')
  end
  
  def to_s
    nickname
  end
  
end
