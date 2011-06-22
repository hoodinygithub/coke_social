class AddSsoWindowsIdToAccount < ActiveRecord::Migration
  def self.up
    #add_column :accounts, :sso_windows, :string
    #add_index :accounts, [:sso_windows, :deleted_at], :unique => true
  end

  def self.down
    remove_index :accounts, [:sso_windows, :deleted_at]
    remove_column :accounts, :sso_windows
  end
end
