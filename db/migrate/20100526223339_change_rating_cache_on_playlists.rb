class ChangeRatingCacheOnPlaylists < ActiveRecord::Migration
  def self.up
    change_column :playlists, :rating_cache, :float, :default => 0, :null => false
  end

  def self.down
    change_column :playlists, :rating_cache, :float
  end
end
