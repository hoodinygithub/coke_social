class AddCokeSitesToSites < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute "INSERT INTO `sites`(id, name, created_at, updated_at, default_locale, code, login_type_id, domain ) SELECT 21, 'Coke Latam', now(), now(), '--- :es', 'cokelatam', 1, 'latam.coke.fm'"
    ActiveRecord::Base.connection.execute "INSERT INTO `sites`(id, name, created_at, updated_at, default_locale, code, login_type_id, domain ) SELECT 22, 'Coke Brazil', now(), now(), '--- :es', 'cokebr', 1, 'br.coke.fm'"
  end

  def self.down
    ActiveRecord::Base.connection.execute "DELETE FROM `sites` WHERE `id` IN (21, 22)"
  end
end
