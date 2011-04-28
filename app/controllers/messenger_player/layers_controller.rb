class MessengerPlayer::LayersController < ApplicationController
  before_filter :login_required, :only => [:messenger_copy]
  layout 'messenger/layer'

  def alert_layer
    alert_type = (params[:alert_type] =~ /(max_plays|share_mix|copy_mix|follow_user|my_friends|my_mixes|max_skips|login_layer|license_message|opt_layer|authentication_layer|registration_layer|error|opt_layer_locked)/i) ? params[:alert_type].to_s : "generic"

    @orig_msg = true
    @ga_tracking_id = case alert_type
    when "max_plays"
      "/auth/maxplays/"
    when "share_mix"
      "/auth/sharemixlayer/"
    when "copy_mix"
      "/auth/copymixlayer/"
    when "max_skips"
      @orig_msg = false
      @msg="max_skips"
      "/layer/max_skips"
    when "login_layer"
      @orig_msg = false
      @msg="login_layer"
      @error_msgs = params[:errors].blank? ? nil : "show error msgs"
      "/auth/login"
    when "license_message"
      @orig_msg = false
      @msg="license_message"
      "/layer/license"
    when "opt_layer"
      @orig_msg = false
      @msg="opt_layer"
      @error_msgs = params[:errors].blank? ? nil : "show error msgs"
      "/auth/option"
    when "opt_layer_locked"
      @orig_msg = false
      @msg="opt_layer"
      @error_msgs = params[:errors].blank? ? nil : "show error msgs"
      "/auth/option"
      
      alert_type = "opt_layer"
      @locked = true
    when "authentication_layer"
      @orig_msg = false
      @msg="authentication_layer"
      "/layer/forgotpwd"
    when "registration_layer"
      @user = @user || User.new
      ActionView::Base.field_error_proc = proc { |input, instance| input } 
      
      @orig_msg = false
      @msg="registration_layer"
      @error_msgs = params[:errors].blank? ? nil : "show error msgs"
      "/auth/registration"
    when "follow_user"
      if params[:slug] && params[:gender]
        @alert_text = t('coke_messenger.registration.layers.follow_user_details', :slug => params[:slug], :gender => t('gender.' + params[:gender]))
      end
      "/auth/followuserlayer/"
    when "my_friends"
      "/auth/myfriendslayer/"
    when "my_mixes"
      "/auth/mymixeslayer/"
    when "share_mix_layer"
      @station_id = params[:station_id]  
      @orig_msg = false
      @msg="share_mix_layer"
    end
    
    @alert_text = t('coke_messenger.registration.layers.' + alert_type) unless @alert_text
  end
  
  def messenger_copy
    @orig_msg = false
    @playlist = Playlist.find(params[:id])
  end


end