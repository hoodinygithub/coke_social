class BadgeAward < ActiveRecord::Base
  belongs_to :badge
  belongs_to :winner, :foreign_key => 'winner_id', :class_name => 'User'
  delegate :badge_key, :name, :image, :to => :badge

  before_save :increment_badge_counts
  named_scope :latest, lambda { |*num| { :limit => num.flatten.first || 6, :order => 'badge_awards.created_at DESC', :include => [:winner, :badge], :conditions => 'accounts.deleted_at IS NULL' } }
  
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