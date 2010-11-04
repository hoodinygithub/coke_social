class AddPromoIdToValidTags < ActiveRecord::Migration
  def self.up
    add_column :valid_tags, :promo_id, :integer
    ValidTag.update_all({:promo_id => 1}, {:promo => 'xmas'})
  end
  
  def self.down
    remove_column :valid_tags, :promo_id
  end
end
