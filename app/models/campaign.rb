# == Schema Information
#
# Table name: campaigns
#
#  id                               :integer(4)      not null, primary key
#  name                             :string(255)
#  start                            :datetime
#  end                              :datetime
#  active                           :boolean(1)      default(FALSE)
#  hexcolor                         :string(255)
#  adcode                           :text
#  created_at                       :datetime
#  updated_at                       :datetime
#  site_id                          :integer(4)
#  player_id                        :integer(4)
#  code                             :string(255)
#  notes                            :text
#  main_image_file_name             :string(255)
#  main_image_content_type          :string(255)
#  main_image_file_size             :integer(4)
#  main_image_updated_at            :datetime
#  footer_logo_file_name            :string(255)
#  footer_logo_content_type         :string(255)
#  footer_logo_file_size            :integer(4)
#  footer_logo_updated_at           :datetime
#  header_hexcolor                  :string(6)
#  ad_size                          :string(255)
#  artistinfo_name_hexcolor         :string(6)
#  artistinfo_meta_hexcolor         :string(6)
#  progressbar_hexcolor             :string(255)
#  editorial_play_icon_file_name    :string(255)
#  editorial_play_icon_content_type :string(255)
#  editorial_play_icon_file_size    :integer(4)
#  editorial_play_icon_updated_at   :datetime
#

class Campaign < ActiveRecord::Base
  ALLOWED_IMAGE_CONTENT_TYPES = ["image/jpeg", "image/png", "image/gif", "image/pjpeg", "image/x-png", "image/jpg"]

  belongs_to :player
  belongs_to :campaign_status
  
  validates_presence_of :name, :hexcolor, :player_id, :start, :end
  validate :date_range, :if => Proc.new {|c| c.start and c.end}
  validate :unique_player_id_per_active_campaign

  named_scope :active, :conditions => { :campaign_status_id => 2 }

  has_attached_file :header_logo, :styles => { :original => '500x500>', :thumb => '80x80>' }
  validates_attachment_size :header_logo, :less_than => 2.megabytes
  validates_attachment_content_type :header_logo, :content_type => ALLOWED_IMAGE_CONTENT_TYPES
  
  has_attached_file :index_logo, :styles => { :original => '500x500>', :thumb => '80x80>' }
  validates_attachment_size :index_logo, :less_than => 2.megabytes
  validates_attachment_content_type :index_logo, :content_type => ALLOWED_IMAGE_CONTENT_TYPES
  
  has_attached_file :footer_logo, :styles => { :original => '500x500>', :thumb => '80x80>' }
  validates_attachment_size :footer_logo, :less_than => 2.megabytes
  validates_attachment_content_type :footer_logo, :content_type => ALLOWED_IMAGE_CONTENT_TYPES

  def header_logo_url
    self.header_logo.url[1, self.header_logo.url.size] rescue ""
  end

  def footer_logo_url
    self.footer_logo.url[1, self.footer_logo.url.size] rescue ""
  end
  
  def header_logo_dimensions
    if self.header_logo.file?
      Paperclip::Geometry.from_file(self.header_logo.path) rescue '0x0'
    else
      '0x0'
    end
  end
  
  def index_logo_dimensions
    if self.index_logo.file?
      Paperclip::Geometry.from_file(self.index_logo.path) rescue '0x0'
    else
      '0x0'
    end
  end
  
  def footer_logo_dimensions
    if self.footer_logo.file?
      Paperclip::Geometry.from_file(self.footer_logo.path) rescue '0x0'
    else
      '0x0'
    end
  end

  private
  def unique_player_id_per_active_campaign
    campaigns_using_player = Campaign.all(:conditions => ['player_id = ? AND id <> ?', self.player_id, self.id], :include => :campaign_status)
    statuses = campaigns_using_player.collect {|c| c.campaign_status.value == 'active'}.delete_if {|cc| !cc}
    if self.campaign_status and self.campaign_status.value == 'active' and statuses.size > 0
      errors.add(:player_id, I18n.t('campaigns.duplicated_active_campaigns_per_player'))
    end
  end
      
  def date_range
    errors.add(:start, I18n.t('campaigns.start_date_gt_end_date')) if self.start >= self.end
  end
end
