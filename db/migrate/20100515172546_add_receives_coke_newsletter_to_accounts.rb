class AddReceivesCokeNewsletterToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :receives_coke_newsletter, :boolean, :null => false, :default => 1
  end

  def self.down
    remove_column :accounts, :receives_coke_newsletter
  end
end
