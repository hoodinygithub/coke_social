class AddOptimizationsToPlaylistItems < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute <<-EOF
    ALTER TABLE playlist_items
    ADD artist_id int(11),
    ADD KEY `index_playlists_items_on_updated_at_for_latest_sort_for_artists` (`artist_id`,`playlist_id`,`updated_at`)
    EOF
  end

  def self.down
    ActiveRecord::Base.connection.execute <<-EOF
    ALTER TABLE playlist_items
    DROP COLUMN artist_id,
    DROP KEY `index_playlists_items_on_updated_at_for_latest_sort_for_artists`
    EOF
  end
end
