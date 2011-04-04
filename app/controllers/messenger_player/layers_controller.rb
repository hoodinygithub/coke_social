class MessengerPlayer::LayersController < ApplicationController
  before_filter :xhr_login_required, :only => [:messenger_copy]
  layout 'messenger/layer'

  def alert_layer
    alert_type = (params[:alert_type] =~ /(max_plays|share_mix|copy_mix|follow_user|my_friends|my_mixes|max_skips|login_layer|license_message|opt_layer|authentication_layer|registration_layer)/i) ? params[:alert_type].to_s : "generic"
    
    @ga_tracking_id = case alert_type
  when "max_plays"
     @orig_msg = true
      "/auth/maxplayslayer/"
    when "share_mix"
      @orig_msg = true
      "/auth/sharemixlayer/"
    when "copy_mix"
      @orig_msg = true
      "/auth/copymixlayer/"
    when "max_skips"
      @orig_msg = false
      @msg="max_skips"
    when "login_layer"
      @orig_msg = false
      @msg="login_layer"
    when "license_message"
      @orig_msg = false
      @msg="license_message"
    when "opt_layer"
      @orig_msg = false
      @msg="opt_layer"
    when "authentication_layer"
      @orig_msg = false
      @msg="authentication_layer"
    when "registration_layer"
      @orig_msg = false
      @msg="registration_layer"
    when "follow_user"
      @orig_msg = true
      if params[:slug] && params[:gender]
        @alert_text = t('coke_messenger.registration.layers.follow_user_details', :slug => params[:slug], :gender => t('gender.' + params[:gender]))
      end
      "/auth/followuserlayer/"
    when "my_friends"
      @orig_msg = true
      "/auth/myfriendslayer/"
    when "my_mixes"
      @orig_msg = true
      "/auth/mymixeslayer/"
    end
    
    @alert_text = t('coke_messenger.registration.layers.' + alert_type) unless @alert_text
  end
  
  def messenger_copy
    @orig_msg = false
    @playlist = Playlist.find(params[:id])
  end
  
  def xhr_login_required
    # session[:return_to] = request.referer
    session[:return_to] = request.referer.gsub("http://#{request.host}", '')
    unless current_user
       render :partial =>"/messenger_player/layers/login_layer"
    end
  end

end