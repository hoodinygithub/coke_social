class RemoveValidTagsPromoColumn < ActiveRecord::Migration
  def self.up
    remove_column :valid_tags, :promo
  end

  def self.down
    add_column :valid_tags, :promo
    ValidTag.update_all("promo = 'xmas'", "promo_id = 1")
  end
end

