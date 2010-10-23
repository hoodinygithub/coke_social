class AddStatusToBadges < ActiveRecord::Migration
  def self.up
    add_column :badges, :status, :string, :default => "active"
  end

  def self.down
    remove_column :badges, :status
  end
end
