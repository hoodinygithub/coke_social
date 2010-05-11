class AddTotalBadgesToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :total_badges, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :accounts, :total_badges
  end
end
