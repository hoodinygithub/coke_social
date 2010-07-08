class AddPlaylistCopyings < ActiveRecord::Migration
  def self.up
    create_table :playlist_copyings do |t|
      t.integer :original_playlist_id
      t.integer :new_playlist_id
      t.timestamps
    end
    add_index :playlist_copyings, [:original_playlist_id, :new_playlist_id], :name => 'index_playlist_copyings_on_playlists'
    add_column :playlists, :playlist_copyings_count, :integer, :null => false, :default => 0
  end

  def self.down
    drop_table :playlist_copyings
    remove_column :playlists, :playlist_copyings_count
  end
end
