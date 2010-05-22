class AddIndexesToPlaylistItems < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute "ALTER TABLE `playlist_items` ADD KEY `sort_index_for_playlist_items_on_position` (`playlist_id`, `position`, `song_id`)"
  end

  def self.down
    ActiveRecord::Base.connection.execute "ALTER TABLE `playlist_items` DROP KEY `sort_index_for_playlist_items_on_position`"
  end
end
