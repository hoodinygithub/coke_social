class AddCachedArtistListToPlaylists < ActiveRecord::Migration
  def self.up
    add_column :playlists, :cached_artist_list, :text
  end

  def self.down
    remove_column :playlists, :cached_artist_list
  end
end
