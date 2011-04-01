class MessengerPlayer::LayersController < ApplicationController
  before_filter :login_required, :only => [:messenger_copy]
  layout 'messenger/layer'

  def alert_layer
    alert_type = (params[:alert_type] =~ /(max_plays|share_mix|copy_mix|follow_user|my_friends|my_mixes|max_skips|login_layer|license_message|opt_layer|authentication_layer|registration_layer)/i) ? params[:alert_type].to_s : "generic"
    
    @ga_tracking_id = case alert_type
  when "max_plays"
      "/auth/maxplayslayer/"
    when "share_mix"
      "/auth/sharemixlayer/"
    when "copy_mix"
      "/auth/copymixlayer/"
    when "max_skips"
      @msg="max_skips"
    when "login_layer"
      @msg="login_layer"
    when "license_message"
      @msg="license_message"
    when "opt_layer"
      @msg="opt_layer"
    when "authentication_layer"
      @msg="authentication_layer"
    when "registration_layer"
      @msg="registration_layer"
    when "follow_user"
    
      if params[:slug] && params[:gender]
        @alert_text = t('coke_messenger.registration.layers.follow_user_details', :slug => params[:slug], :gender => t('gender.' + params[:gender]))
      end
      "/auth/followuserlayer/"
    when "my_friends"
      "/auth/myfriendslayer/"
    when "my_mixes"
      "/auth/mymixeslayer/"
    end
    
    @alert_text = t('coke_messenger.registration.layers.' + alert_type) unless @alert_text
  end
  
  def messenger_copy
    @playlist = Playlist.find(params[:id])
  end
end