class AddPlayableAndAvatarFieldsToPlaylists < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute <<-EOF
    ALTER TABLE playlists 
    ADD `avatar_file_name` varchar(255), 
    ADD `avatar_file_size` int(11), 
    ADD `avatar_content_type` varchar(255),
    ADD `avatar_updated_at` datetime,
    ADD `total_plays` int(11) unsigned NOT NULL DEFAULT 0,
    ADD `deleted_at` datetime AFTER updated_at,
    ADD `locked` tinyint(1) NOT NULL DEFAULT 1,
    CHANGE comments_count reviews_count int(11) NOT NULL DEFAULT 0
    EOF
  end

  def self.down
    ActiveRecord::Base.connection.execute <<-EOF
    ALTER TABLE playlists 
    DROP COLUMN `avatar_file_name`, 
    DROP COLUMN `avatar_file_size`, 
    DROP COLUMN `avatar_content_type`,
    DROP COLUMN `avatar_updated_at`,
    DROP COLUMN `total_plays`,
    DROP COLUMN `deleted_at`,
    DROP COLUMN `locked`,
    CHANGE reviews_count comments_count int(11)
    EOF
  end
end
