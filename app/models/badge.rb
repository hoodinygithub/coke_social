# == Schema Information
#
# Table name: badges
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)
#  image_path         :string(255)
#  badge_awards_count :integer(4)
#  created_at         :datetime
#  updated_at         :datetime
#  badge_key          :string(255)     not null
#  name_coke_es       :string(255)
#  name_coke_br       :string(255)
#

class Badge < ActiveRecord::Base
  has_many :badge_awards
  has_many :winners, :through => :badge_awards, :class_name => 'User' do

    def other_than_user_and_followees(user, limit=40)
      followee_cache = [user.id].concat(user.read_attribute(:followee_cache) || [])
      all(:conditions => ["accounts.deleted_at IS NULL AND accounts.id NOT IN (?)", followee_cache], :order => 'badge_awards.created_at DESC', :limit => limit)
    end

    def with_playlist(p_playlist_id)
      all(:conditions => ["badge_awards.playlist_id = ?", p_playlist_id])
    end
  end

  def image(type = :small)
    "#{type.to_s}_#{image_path}"
  end
end
