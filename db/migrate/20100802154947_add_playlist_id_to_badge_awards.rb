class AddPlaylistIdToBadgeAwards < ActiveRecord::Migration
  def self.up
    add_column :badge_awards, :playlist_id, :integer
  end
  
  def self.down
    remove_column :badge_awards, :playlist_id
  end
end
