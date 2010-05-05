class AddNetworksAndNetworkSites < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      create_table :networks do |t|
        t.string :name
        t.timestamps
      end
    
      ActiveRecord::Base.connection.execute "INSERT INTO networks SELECT 1, 'Cyloop', now(), now()"
      ActiveRecord::Base.connection.execute "INSERT INTO networks SELECT 2, 'Coke', now(), now()"

      create_table :network_sites do |t|
        t.references :network
        t.references :site
        t.timestamps
      end
      add_index :network_sites, [:network_id, :site_id] 
      add_index :network_sites, :site_id

      ActiveRecord::Base.connection.execute "INSERT INTO network_sites(network_id, site_id, created_at, updated_at) SELECT 1, id, now(), now() FROM sites WHERE id < 21"
      ActiveRecord::Base.connection.execute "INSERT INTO network_sites(network_id, site_id, created_at, updated_at) SELECT 2, 21, now(), now()"
      ActiveRecord::Base.connection.execute "INSERT INTO network_sites(network_id, site_id, created_at, updated_at) SELECT 2, 22, now(), now()"
    end
  end

  def self.down
    drop_table :network_sites
    drop_table :networks
  end
end
