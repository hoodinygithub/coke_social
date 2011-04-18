class LastPlayedAtToPlaylist < ActiveRecord::Migration
  def self.up
    add_column :playlists, :last_played_at, :timestamp
  end

  def self.down
    remove_column :playlists, :last_played_at
  end
end
