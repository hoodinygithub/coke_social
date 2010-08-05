class AddSslDomainToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :ssl_domain, :string
  end

  def self.down
    remove_column :sites, :ssl_domain
  end
end