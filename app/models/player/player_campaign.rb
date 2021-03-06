# == Schema Information
#
# Table name: player_bases
#
#  name               :string
#  start              :datetime
#  end                :datetime
#  hexcolor           :string
#  code               :string
#  campaign_status_id :integer
#  locale             :string
#  header_logo_file   :string
#  footer_logo_file   :string
#  ad_zone_id         :string
#  promo_code         :string
#  google_profile_id  :string
#  name               :string
#  start              :datetime
#  end                :datetime
#  hexcolor           :string
#  code               :string
#  campaign_status_id :integer
#  locale             :string
#  header_logo_file   :string
#  footer_logo_file   :string
#  ad_zone_id         :string
#  promo_code         :string
#  google_profile_id  :string
#

class Player::PlayerCampaign < Player::Base

  column :name,                  :string
  column :start,                 :datetime
  column :end,                   :datetime
  column :hexcolor,              :string
  column :code,                  :string
  column :campaign_status_id,    :integer
  column :locale,                :string
  column :header_logo_file,      :string
  column :footer_logo_file,      :string
  column :ad_zone_id,            :string
  column :promo_code,            :string
  column :google_profile_id,     :string

  attr_accessor :header_logo_url, :footer_logo_url

  class << self
    def from_one(object, options = {})
      returning( super(object, options) ) do |campaign|
        campaign.header_logo_file = object.header_logo_url
        campaign.footer_logo_file = object.footer_logo_url
      end
    end
  end

end
