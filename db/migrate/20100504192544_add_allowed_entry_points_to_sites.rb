class AddAllowedEntryPointsToSites < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute "ALTER TABLE `sites` ADD `allowed_entry_points` varchar(512)"
      ActiveRecord::Base.connection.execute "UPDATE `sites` set `allowed_entry_points` = '---\\n- 1\\n- 10\\n- 11\\n- 12\\n- 13\\n- 14\\n- 15\\n- 16\\n- 17\\n- 18\\n- 19\\n- 20'"  
      ActiveRecord::Base.connection.execute "INSERT INTO `sites` SELECT 21, 'Coke Social ES', now(), now(), '--- :es', 'cokees', NULL, 1, 'es.coke.fm', '---\\n[]'"  
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute "DELETE FROM `sites` WHERE `id` = 21"
      ActiveRecord::Base.connection.execute "ALTER TABLE `sites` DROP COLUMN `allowed_entry_points`"
    end
  end
end
