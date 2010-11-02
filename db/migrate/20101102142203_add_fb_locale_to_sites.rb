class AddFbLocaleToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :fb_locale, :string

    ActiveRecord::Base.connection.execute "UPDATE `sites` SET fb_locale = 'es_LA' WHERE name = 'Coke Argentina' OR name = 'Coke Mexico' OR name = 'Coke Latam'"
    ActiveRecord::Base.connection.execute "UPDATE `sites` SET fb_locale = 'pt_BR' WHERE name = 'Coke Brazil'"
  end

  def self.down
    remove_column :sites, :fb_locale
  end
end
