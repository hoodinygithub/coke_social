class AddReceivesBadgesNotificationsToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :receives_badges_notifications, :boolean, :null => false, :default => 1
  end

  def self.down
    remove_column :accounts, :receives_badges_notifications
  end
end
