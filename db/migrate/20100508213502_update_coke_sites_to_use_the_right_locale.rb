class UpdateCokeSitesToUseTheRightLocale < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute "UPDATE `sites` set default_locale = '--- :coke_ES' WHERE id = 21"
    ActiveRecord::Base.connection.execute "UPDATE `sites` set default_locale = '--- :coke_BR' WHERE id = 22"
  end

  def self.down
    # NO UNDO HERE :-)
  end
end
