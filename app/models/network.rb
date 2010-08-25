# == Schema Information
#
# Table name: networks
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Network < ActiveRecord::Base
end
