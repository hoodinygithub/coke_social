class Badge < ActiveRecord::Base
  has_many :badge_awards
  has_many :winners, :through => :badge_awards, :class_name => 'User' do
    def other_than_user_and_followees(user, limit=40)
      followee_cache = [user.id].concat(user.read_attribute(:followee_cache) || [])
      all(:conditions => ["accounts.id NOT IN (?)", followee_cache], :order => 'badge_awards.created_at DESC', :limit => limit)
    end
  end

  def image(type = :small)
    "#{type.to_s}_#{image_path}"
  end
end