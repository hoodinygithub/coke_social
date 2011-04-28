class AccountsNetworks < ActiveRecord::Migration
  def self.up
    create_table :accounts_networks, :id => false do |t|
      t.references :account, :null => false
      t.references :network, :null => false
      t.timestamp :created_at, :null => false
    end
    execute <<-SQL
      -- User joined the network when the account was created.
      INSERT INTO accounts_networks(account_id, network_id, created_at)
      SELECT id, network_id, created_at FROM accounts
      WHERE type = 'User'
    SQL
    execute <<-SQL
      ALTER TABLE accounts_networks ADD FOREIGN KEY (account_id) REFERENCES accounts(id)
    SQL
    execute <<-SQL
      ALTER TABLE accounts_networks ADD FOREIGN KEY (network_id) REFERENCES networks(id)
    SQL

    add_index :accounts_networks, [:account_id, :network_id], :unique => true

    add_column :networks, :is_secure, :boolean
    execute <<-SQL
      UPDATE networks SET is_secure = 1 WHERE id = 2
    SQL
    execute <<-SQL
      UPDATE networks SET is_secure = 0 WHERE id = 1
    SQL
    execute <<-SQL
      ALTER TABLE networks MODIFY is_secure tinyint(1) NOT NULL
    SQL

  end

  def self.down
    remove_column :networks, :is_secure
    #remove_index :accounts_networks, :network_id
    #remove_index :accounts_networks, :account_id
    drop_table :accounts_networks
  end
end

