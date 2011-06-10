# Some Rails initialization nonsense to allow monkeypatching of plugin models
ActionController::Dispatcher.to_prepare do
  Tag.class_eval do

    has_many :valid_tags, :conditions => { :site_id => ApplicationController.current_site.id }

    def nickname
      #ValidTag.find_by_tag_id(self.id).try(:promo_id).blank? ? name : name.try(:upcase).try(:gsub, 'ñ', 'Ñ').try(:gsub, 'á', 'Á')
      # use the monkey-patched association to take advantage of includes caching
      valid_tags.first.promo_id.blank? ? name : name.upcase.gsub('ñ', 'Ñ').gsub('á', 'Á')
    end

    def to_s
      nickname
    end

  end
end

