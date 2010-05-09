class BadgeAward < ActiveRecord::Base
  belongs_to :badge, :counter_cache => true
  belongs_to :winner, :foreign_key => 'winner_id', :class_name => 'User'
  delegate :badge_key, :to => :badge
  
  named_scope :latest, lambda { |*num| { :limit => num.flatten.first || 6, :order => 'created_at DESC' } }
end