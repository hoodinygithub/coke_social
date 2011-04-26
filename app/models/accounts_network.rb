class AccountsNetwork < ActiveRecord::Base
  belongs_to :network
  belongs_to :account
end
