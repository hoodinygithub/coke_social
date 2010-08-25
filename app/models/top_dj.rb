# == Schema Information
#
# Table name: top_djs
#
#  id             :integer(4)      not null, primary key
#  dj_id          :integer(4)
#  site_id        :integer(4)
#  total_requests :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#

class TopDj < ActiveRecord::Base
  include Db::Predicates::LimitedTo
  include Summary::Predicates
  belongs_to :site
  belongs_to :user, :foreign_key => 'dj_id'
end
