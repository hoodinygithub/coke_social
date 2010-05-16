class AddTranslatedNameFieldsToBadgesTable < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute "ALTER TABLE badges ADD name_coke_es varchar(255), ADD name_coke_br varchar(255)"
    ActiveRecord::Base.connection.execute "ALTER TABLE badge_awards ADD name varchar(255), ADD name_coke_es varchar(255), ADD name_coke_br varchar(255), ADD KEY ix_sort_by_name(winner_id, name, badge_id), ADD KEY ix_sort_by_name_coke_es(winner_id, name_coke_es, badge_id), ADD KEY ix_sort_by_name_coke_br(winner_id, name_coke_br, badge_id)"
  end

  def self.down
    ActiveRecord::Base.connection.execute "ALTER TABLE badges DROP COLUMN name_coke_es, DROP COLUMN name_coke_br"
    ActiveRecord::Base.connection.execute "ALTER TABLE badge_awards DROP KEY ix_sort_by_name, DROP KEY ix_sort_by_name_coke_es, DROP KEY ix_sort_by_name_coke_br, DROP COLUMN name, DROP COLUMN name_coke_es, DROP COLUMN name_coke_br"
  end
end
