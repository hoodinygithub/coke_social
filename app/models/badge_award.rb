class BadgeAward < ActiveRecord::Base
  belongs_to :badge
  belongs_to :winner, :foreign_key => 'winner_id', :class_name => 'User'
  delegate :badge_key, :name, :image, :to => :badge

  before_save :increment_badge_counts
  named_scope :latest, lambda { |*num| { :limit => num.flatten.first || 6, :order => 'created_at DESC' } }
  
  def new?
    true
  end
  
  def increment_badge_counts
    self.winner.increment!(:total_badges)
    self.badge.increment!(:badge_awards_count)
  end
end