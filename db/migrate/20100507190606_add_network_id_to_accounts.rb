class AddNetworkIdToAccounts < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute "ALTER TABLE `accounts` ADD network_id int(11), ADD KEY `index_accounts_on_network_id_type_and_deleted_at` (network_id, type, deleted_at)"
    ActiveRecord::Base.connection.execute "UPDATE `accounts` a INNER JOIN `network_sites` ns ON a.entry_point_id = ns.site_id SET a.network_id = ns.network_id"
  end

  def self.down
    ActiveRecord::Base.connection.execute "ALTER TABLE `accounts` DROP KEY `index_accounts_on_network_id_type_and_deleted_at`, DROP COLUMN network_id"
  end
end
