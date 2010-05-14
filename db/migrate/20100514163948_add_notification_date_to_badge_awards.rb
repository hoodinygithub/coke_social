class AddNotificationDateToBadgeAwards < ActiveRecord::Migration
  def self.up
    add_column :badge_awards, :notified_at, :datetime
    add_index :badge_awards, [:winner_id, :notified_at]
  end

  def self.down
    remove_index :badge_awards, :column => [:winner_id, :notified_at]
    remove_column :badge_awards, :notified_at
  end
end
