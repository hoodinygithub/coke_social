# == Schema Information
#
# Table name: player_bases
#
#  id            :integer         primary key
#  player_key    :string
#  license       :string
#  max_plays     :integer
#  site_id       :integer
#  partner_id    :integer
#  max_skips     :integer
#  skip_duration :integer
#  id            :integer         primary key
#  player_key    :string
#  license       :string
#  max_plays     :integer
#  site_id       :integer
#  partner_id    :integer
#  max_skips     :integer
#  skip_duration :integer
#

class Player::Player < Player::Base

  column :id,         :integer
  column :player_key, :string
  column :license,    :string
  column :max_plays,  :integer
  column :site_id,    :integer
  column :partner_id, :integer
  column :max_skips,  :integer
  column :skip_duration, :integer

  attr_accessor :active_campaign

  has_one :campaign, :class_name => "Player::PlayerCampaign"

  def to_xml(options = {})
    options[:include] = :campaign
    super(options)
  end

  class << self

    def from_one( object, options = {} )
      returning( super(object, options) ) do |player|
        player.campaign = Player::PlayerCampaign.from(object.active_campaign) unless object.active_campaign.nil?
      end
    end

  end

end
