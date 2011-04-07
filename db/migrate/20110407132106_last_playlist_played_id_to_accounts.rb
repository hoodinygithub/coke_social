class LastPlaylistPlayedIdToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :last_playlist_played_id, :integer
  end

  def self.down
    remove_column :accounts, :last_playlist_played_id
  end
end
