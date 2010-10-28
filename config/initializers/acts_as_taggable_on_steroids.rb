class Tag < ActiveRecord::Base
  has_one :valid_tag
  def name
    self.valid_tag.try(:promo).blank? ? super : super.upcase.try(:gsub, 'ñ', 'Ñ').try(:gsub, 'á', 'Á')
  end
end