class BadgeAward < ActiveRecord::Base
  belongs_to :badge, :counter_cache => true
  belongs_to :winner, :foreign_key => 'winner_id', :class_name => 'User'
end