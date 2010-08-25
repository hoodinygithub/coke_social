# == Schema Information
#
# Table name: network_sites
#
#  id         :integer(4)      not null, primary key
#  network_id :integer(4)
#  site_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class NetworkSite < ActiveRecord::Base
  belongs_to :network
  belongs_to :site
end
