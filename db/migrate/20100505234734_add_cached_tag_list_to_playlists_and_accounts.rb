class AddCachedTagListToPlaylistsAndAccounts < ActiveRecord::Migration
  def self.up
    add_column :playlists, :cached_tag_list, :text
    add_column :accounts, :cached_tag_list, :text
  end

  def self.down
    remove_column :playlists, :cached_tag_list
    remove_column :accounts, :cached_tag_list
  end
end
