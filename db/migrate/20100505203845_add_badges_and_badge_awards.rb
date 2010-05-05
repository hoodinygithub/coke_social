class AddBadgesAndBadgeAwards < ActiveRecord::Migration
  def self.up
    create_table :badges do |t|
      t.string :name
      t.string :image_path
      t.integer :badge_awards_count
      t.timestamps
      t.deleted_at :datetime
    end

    create_table :badge_awards do |t|
      t.references :badge
      t.references :winner
      t.timestamps
      t.deleted_at :datetime
    end
  end

  def self.down
    drop_table :badge_awards
    drop_table :badges
  end
end
