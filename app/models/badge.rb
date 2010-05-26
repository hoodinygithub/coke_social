class Badge < ActiveRecord::Base
  has_many :badge_awards
  has_many :winners, :through => :badge_awards, :class_name => 'User' do
    def other_than_user_and_followees(user)
      all(:conditions => ["accounts.id NOT IN (?)", [user.id].concat(user.read_attribute(:followee_cache)])
    end
  end

  def image(type = :small)
    "#{type.to_s}_#{image_path}"
  end
end