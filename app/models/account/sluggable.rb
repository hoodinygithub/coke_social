module Account::Sluggable

  def self.included(base)
    base.class_eval do
      validates_presence_of :slug
#      validates_uniqueness_of :slug, :scope => :deleted_at, :case_sensitive => false

      validate :uniqueness_of_slug

      validates_format_of :slug,
        :with => /\A[^_-]/,
        :allow_blank => true,
        :message => :cannot_start_with_punctuation
      validates_format_of :slug,
        :with => /[^_-]\z/,
        :allow_blank => true,
        :message => :cannot_end_with_punctuation
      validates_format_of :slug,
        :with => /\A[A-Za-z0-9_-]+\z/,
        :allow_blank => true,
        :message => :can_only_contain_letters_numbers_and_hyphens
      validate_on_create :verify_reserved_slugs
    end
  end  

  def to_param
    slug
  end

  def slug=( new_value )
    unless new_value.blank?
      self.write_attribute( :slug, new_value.downcase )
    end
  end

  def email=( new_value )
    unless new_value.blank?
      self.write_attribute( :email, new_value.downcase )
    end
  end

  protected

  def uniqueness_of_slug
    self.class.send(:with_exclusive_scope) do
      user_with_slug = User.find_by_slug_and_deleted_at(slug, nil)
      if !user_with_slug.nil? && user_with_slug.id != id
        self.errors.add(:slug, I18n.t("activerecord.errors.messages.taken"))
      end
    end
  end
  
  def verify_reserved_slugs
    found_items = ReservedSlug.all( :conditions => { :slug =>self.slug  } )
    found_items += AccountSlug.all( :conditions => { :slug => self.slug } )
    if found_items.size > 0
      self.errors.add(:slug, I18n.t("activerecord.errors.messages.exclusion"))
    end
  end
  
end
