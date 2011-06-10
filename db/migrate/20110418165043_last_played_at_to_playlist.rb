class LastPlayedAtToPlaylist < ActiveRecord::Migration
  def self.up
    add_column :playlists, :last_played_at, :timestamp
    add_index :playlists, [:site_id, :last_played_at]
  end

  def self.down
    remove_index :playlists, [:site_id, :last_played_at]
    remove_column :playlists, :last_played_at
  end
end
