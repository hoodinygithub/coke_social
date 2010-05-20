class AddEncryptedFieldsToAccounts < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute "ALTER TABLE accounts ADD encrypted_born_on_string varchar(255), ADD encrypted_name varchar(255), ADD encrypted_gender varchar(255), ADD encrypted_email varchar(255), ADD KEY `index_accounts_on_encrypted_email` (encrypted_email)"
  end

  def self.down
    ActiveRecord::Base.connection.execute "ALTER TABLE accounts DROP KEY `index_accounts_on_encrypted_email`, DROP COLUMN encrypted_born_on_string, DROP COLUMN encrypted_name, DROP COLUMN encrypted_gender, DROP COLUMN encrypted_email"
  end
end
