class AddTotalPlaylistsToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :total_playlists, :integer, :null => false, :default => 0
  end

  def self.down
    drop_column :accounts, :total_playlists
  end
end
