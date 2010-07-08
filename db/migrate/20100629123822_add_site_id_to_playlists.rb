class AddSiteIdToPlaylists < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute <<-EOF
    ALTER TABLE playlists
    ADD site_id int(11),
    ADD KEY index_playlists_on_site_id_for_latest_sort (site_id, updated_at),
    ADD KEY index_playlists_on_site_id_for_popular_sort (site_id, total_plays)
    EOF
  end

  def self.down
    ActiveRecord::Base.connection.execute <<-EOF
    ALTER TABLE playlists
    DROP KEY index_playlists_on_site_id_for_latest_sort,
    DROP KEY index_playlists_on_site_id_for_popular_sort,
    DROP COLUMN site_id
    EOF
  end
end
