class AddEmailSentToBadgeAwards < ActiveRecord::Migration
  def self.up
    add_column :badge_awards, :email_sent, :boolean, :null => false, :default => 0
  end

  def self.down
    remove_column :badge_awards, :email_sent
  end
end
