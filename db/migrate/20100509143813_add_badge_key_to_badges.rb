class AddBadgeKeyToBadges < ActiveRecord::Migration
  def self.up
    add_column :badges, :badge_key, :string, :null => false
    add_index :badges, :badge_key
    add_index :badge_awards, :created_at
    add_index :badge_awards, :badge_id
    add_index :badge_awards, [:winner_id, :created_at]

  end

  def self.down
    remove_index :badges, :column => :badge_key
    remove_column :badges, :badge_key
    remove_index :badge_awards, :column => :created_at
    remove_index :badge_awards, :column => :badge_id
    remove_index :badge_awards, :column => [:winner_id, :created_at]
  end
end
