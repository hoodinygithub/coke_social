class MessengerPlayer::LayersController < ApplicationController
  
  layout 'messenger/layer'

  def alert_layer
    alert_type = (params[:alert_type] =~ /(max_plays|share_mix|copy_mix|follow_user|my_friends|my_mixes)/i) ? params[:alert_type].to_s : "generic"
    
    @ga_tracking_id = case alert_type
    when "max_plays"
      "/auth/maxplayslayer/"
    when "share_mix"
      "/auth/sharemixlayer/"
    when "copy_mix"
      "/auth/copymixlayer/"
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
  
end