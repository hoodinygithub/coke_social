namespace :db do
  namespace :populate do
    desc "Update accounts cached counts column with summarized data from song_listens, profile_visits and followings"
    task :profile_stats => :environment do
      include Timebox
      
      connection = ActiveRecord::Base.connection
      return unless connection.respond_to? :execute
      
      connection.execute 'DROP TABLE IF EXISTS `_cached_following_count_updates`'
      connection.execute 'DROP TABLE IF EXISTS `_cached_visit_count_updates`'

      timebox "Create temp table for followings count updates..." do
        query = <<-EOF
        CREATE TABLE `_cached_following_count_updates` (
          `id` int(11),
          `followee_count` int(11) DEFAULT 0,
          `follower_count` int(11) DEFAULT 0,
          PRIMARY KEY(`id`)          
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8
        EOF
        connection.execute query
      end

      timebox "Create temp table for visit count updates..." do
        query = <<-EOF
        CREATE TABLE `_cached_visit_count_updates` (
          `id` int(11),
          `visit_count` int(11) DEFAULT 0,
          PRIMARY KEY(`id`)          
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8
        EOF
        connection.execute query
      end

      timebox "Update badge counts for users..." do
        query = <<-EOF
        UPDATE accounts a 
        INNER JOIN (
          SELECT b.winner_id, count(*) AS total_badge_awards 
          FROM badge_awards b
          INNER JOIN accounts a ON b.winner_id = a.id 
          WHERE a.deleted_at IS NULL
          AND a.network_id = 2
          GROUP BY 1
        ) AS q ON a.id = q.winner_id 
        SET a.total_badges= q.total_badge_awards
        EOF
        connection.execute query
      end

      timebox "Update playlist counts for users..." do
        query = <<-EOF
        UPDATE accounts a 
        INNER JOIN (
          SELECT p.owner_id, count(*) AS total_playlists
          FROM playlists p 
          INNER JOIN accounts a ON p.owner_id = a.id 
          WHERE a.deleted_at IS NULL 
          AND p.deleted_at IS NULL 
          AND a.network_id = 2
          GROUP BY 1
        ) AS q ON a.id = q.owner_id 
        SET a.total_playlists = q.total_playlists
        EOF
        connection.execute query
      end


      timebox "Calculate and insert followings counts into temp table..." do
        query = <<-EOF
        INSERT INTO `_cached_following_count_updates`(`id`, `follower_count`, `followee_count`)
        SELECT a.id, (SELECT count(*) FROM followings INNER JOIN accounts a2 ON follower_id = a2.id WHERE followee_id = a.id and approved_at IS NOT NULL AND a2.network_id = 2 AND a2.deleted_at IS NULL) AS follower_count, (SELECT count(*) FROM followings INNER JOIN accounts a2 ON followee_id = a2.id WHERE follower_id = a.id and approved_at IS NOT NULL AND a2.network_id = 2 AND a2.deleted_at IS NULL) AS followee_count FROM `accounts` a
        WHERE a.type = 'User' 
        EOF
        connection.execute query
      end

      timebox "Calculate and insert visit counts into temp table..." do
        query = <<-EOF
        INSERT INTO `_cached_visit_count_updates`(`id`, `visit_count`)
        SELECT p.owner_id, sum(total_visits) AS visit_count 
        FROM `profile_visits` p
        INNER JOIN accounts a ON p.owner_id = a.id 
        WHERE a.network_id = 2
        GROUP BY 1
        EOF
        connection.execute query
      end

      timebox "Update followings counts in accounts..." do
        query = <<-EOF
        UPDATE `accounts` a
        INNER JOIN `_cached_following_count_updates` t ON a.id = t.id 
        SET a.follower_count = t.follower_count, a.followee_count = t.followee_count
        EOF
        connection.execute query
      end

      timebox "Update visit counts in accounts..." do
        query = <<-EOF
        UPDATE `accounts` a
        INNER JOIN `_cached_visit_count_updates` t ON a.id = t.id 
        SET a.visit_count = t.visit_count
        EOF
        connection.execute query
      end

      timebox "Cleanup..." do
        connection.execute 'DROP TABLE IF EXISTS `_cached_following_count_updates`'
        connection.execute 'DROP TABLE IF EXISTS `_cached_visit_count_updates`'
      end
    end
  end
end
