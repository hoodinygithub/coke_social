class AddTopPlaylistsAndDjs < ActiveRecord::Migration
  def self.up
    create_table :top_djs do |t|
      t.references :dj
      t.references :site
      t.integer :total_requests
      t.timestamps
    end
    add_index :top_djs, [:site_id, :total_requests]
    add_index :top_djs, :dj_id

    create_table :top_playlists do |t|
      t.references :playlist
      t.references :site
      t.integer :total_requests
      t.timestamps
    end
    add_index :top_playlists, [:site_id, :total_requests]
    add_index :top_playlists, :playlist_id

  end

  def self.down
    drop_table :top_djs
    drop_table :top_playlists
  end
end
