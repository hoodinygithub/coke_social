# == Schema Information
#
# Table name: badge_awards
#
#  id           :integer(4)      not null, primary key
#  badge_id     :integer(4)
#  winner_id    :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#  notified_at  :datetime
#  name         :string(255)
#  name_coke_es :string(255)
#  name_coke_br :string(255)
#  playlist_id  :integer(4)
#  email_sent   :boolean(1)      default(FALSE), not null
#

class BadgeAward < ActiveRecord::Base
  belongs_to :badge
  belongs_to :playlist
  belongs_to :winner, :foreign_key => 'winner_id', :class_name => 'User'
  delegate :badge_key, :name, :image, :to => :badge
  delegate :name, :to => :playlist, :prefix => true, :allow_nil => true

  before_create :increment_badge_counts
  named_scope :latest, lambda { |*num| {
     :limit => num.flatten.first || 6,
     :order => 'badge_awards.created_at DESC',
     :include => [:winner, :badge],
     # Upate this when promo table is finalized.
     # include :promo, condition "promos.site_id = #{current_site.id}"
     :conditions => "accounts.deleted_at IS NULL #{ApplicationController.current_site.id == 22 ? ' AND badges.promo_id IS NULL' : ''}"
  }}

  def new?
    is_new = false
    if notified_at.nil? or (notified_at and (Time.now >= notified_at and Time.now <= notified_at + 24.hours))
      is_new = true
    end
    is_new
  end
  
  def increment_badge_counts
    self.winner.increment!(:total_badges)
    self.badge.increment!(:badge_awards_count)
  end
end
