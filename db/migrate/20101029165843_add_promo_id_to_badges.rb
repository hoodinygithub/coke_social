class AddPromoIdToBadges < ActiveRecord::Migration
  def self.up
    add_column :badges, :promo_id, :integer
    Badge.all(:conditions => ["created_at > ?", "2010-10-01"]).map {|x| x.update_attribute(:promo_id, 1) } 
  end

  def self.down
    remove_column :badges, :promo_id
  end
end

