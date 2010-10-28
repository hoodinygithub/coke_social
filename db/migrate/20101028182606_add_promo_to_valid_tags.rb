class AddPromoToValidTags < ActiveRecord::Migration
  def self.up
    add_column :valid_tags, :promo, :string
  end

  def self.down
    remove_column :valid_tags, :promo
  end
end
