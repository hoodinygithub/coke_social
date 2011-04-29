class RemoveNetworkIdFromAccounts < ActiveRecord::Migration
  def self.up
    # This constraint doesn't exist in production.
    execute <<-SQL
      ALTER TABLE accounts DROP FOREIGN KEY accounts_ibfk_4;
    SQL
    #remove_index :accounts, [:network_id, :type, :deleted_at]
    execute <<-SQL
      DROP INDEX index_accounts_on_network_id_and_type_and_deleted_at ON accounts;
    SQL
    remove_column :accounts, :network_id
    add_index :accounts, [:type, :deleted_at]
  end

  def self.down
    add_column :accounts, :network_id, :integer
    execute <<-SQL
      UPDATE accounts a
      INNER JOIN accounts_networks an ON an.account_id = a.id
      SET a.network_id = an.network_id
      WHERE a.network_id IS NULL;
    SQL
    remove_index :accounts, [:type, :deleted_at]
    add_index :accounts, [:network_id, :type, :deleted_at]
    # This constraint shouldn't exist in production.
    execute <<-SQL
      ALTER TABLE accounts ADD FOREIGN KEY (network_id) REFERENCES networks(id);
    SQL
  end
end
