class AddRatingCacheToPlaylists < ActiveRecord::Migration
  def self.up
    add_column :playlists, :rating_cache, :float
  end

  def self.down
    remove_column :playlists, :rating_cache
  end
end
