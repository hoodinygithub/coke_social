class ShareController < ApplicationController

  def show
    @item = params[:media].capitalize.constantize.find(params[:id].to_i)
    render :template => "share/#{params[:media]}"
  end

  def share_with_friend
    errors = []
    
    sender_avatar = nil
    account_id = nil
    user_email = params[:user_email]
    sender_slug = nil
    sender_name = params[:user_name]

    if logged_in?
      sender_name = current_user.name
      sender_slug = current_user.slug
      account_id = current_user.id
      user_email ||= current_user.email
      sender_avatar = current_user.avatar_file_name
      unless sender_avatar.nil?
        sender_avatar = sender_avatar.sub('www', 'assets')
        unless sender_avatar.index('/.elhood.com').nil?
          sender_avatar = sender_avatar.sub(%r{/hires/}, '/thumbnail/')
          sender_avatar = sender_avatar
        else
          sender_avatar = File.join("http://", request.host, "/system/avatars/", PartitionedPath.path_for(current_user.id), "small", sender_avatar)
        end
      else
        if current_user.gender=='Male'
          sender_avatar = "avatars/missing/male.gif"
        else
          sender_avatar = "avatars/missing/female.gif"
        end
      end
    end
    
    if request.xhr? && params[:multitask]
      recipients = []
      errors << [:name, t('coke_messenger.layers.share_mix_layer.name_blank')] if params[:name].blank?
      errors << [:email, t('coke_messenger.layers.share_mix_layer.email_blank')] if params[:email].blank?
      errors << [:email, t('coke_messenger.layers.share_mix_layer.invalid_email')] unless valid_email?(params[:email])
      errors << [:message, t('coke_messenger.layers.share_mix_layer.msg_blank')] if params[:message].blank?
      errors << [:message, t('coke_messenger.layers.share_mix_layer.invalid_msg')] unless valid_msg?(params[:message])
      if errors.empty?
        recipients << params[:email]
      else
        render :json => { :success => false, :errors => errors.to_json }
        return false
      end
    else
      recipients = params[:email].split(',')
      recipients.map { |i| i.strip! }
      recipients.reject! { |i| !valid_email?(i) }
    end

    unless params[:item_id].blank?
      if params[:media] == "song"
        @song = Song.find( params[:item_id] )
        share_link = "http://www.cyloop.com#{queue_song_path(:slug => @song.artist.slug, :id => @song.album, :song_id => @song)}"
        params[:item_title] ||= @song.title
        params[:item_author] ||= @song.artist.name
      elsif params[:media] == "station"
        station = Station.find(params[:item_id])
        share_link = "http://#{global_url}/playlists?station_id=#{params[:item_id]}"
        station_author = nil
        station_author = station.playable.owner.name unless station.playable.kind_of? AbstractStation
        station_name = station.playable.name
        station_images = []
        station_includes = []
        station.playable.includes(4).each do |artist|
          station_images << AvatarsHelper.avatar_path(artist.album, :small)
          station_includes << {:artist => artist.artist.name, :slug => artist.artist.slug} unless artist.artist.nil?
        end
      end
    end

    if params[:media] == "song"
      subject_line = t('share.song.subject', :user => sender_name)
    elsif params[:media] == "station"
      if request.xhr? && params[:multitask]
        subject_line = t('coke_messenger.email_share.subject', :user => sender_name)
      else
        subject_line = t('share.station.subject', :user => sender_name)
      end
    end

    recipients.each do |email|
      if params[:media] == "song"
        UserNotification.send_share_song(
          :locale => current_site.default_locale,
          :mailto => email,
          :subject_line => subject_line,
          :sender => user_email,
          :sender_name => sender_name,
          :sender_avatar => sender_avatar,
          :sender_slug => sender_slug,
          :share_link => params[:share_link],
          :item_author => params[:item_author],
          :item_title => params[:item_title],
          :message => params[:message],
          :global_url => global_url)
      elsif params[:media] == "station"
        if request.xhr? && params[:multitask]
          UserNotification.send_share_multitask_station(
            :locale => current_site.default_locale,
            :mailto => email,
            :name => params[:name],
            :subject_line => subject_line,
            :sender => user_email,
            :sender_name => sender_name,
            :sender_avatar => sender_avatar,
            :sender_slug => sender_slug,
            :share_link => share_link,
            :item_author => station_author,
            :item_title => station_name,
            :item_includes => station_includes,
            :item_images => station_images,
            :is_msn => current_site.is_msn?,
            :message => params[:message],
            :global_url => global_url)
        else
          UserNotification.send_share_station(
            :locale => current_site.default_locale,
            :mailto => email,
            :subject_line => subject_line,
            :sender => user_email,
            :sender_name => sender_name,
            :sender_avatar => sender_avatar,
            :sender_slug => sender_slug,
            :share_link => share_link,
            :item_author => station_author,
            :item_title => station_name,
            :item_includes => station_includes,
            :item_images => station_images,
            :is_msn => current_site.is_msn?,
            :message => params[:message],
            :global_url => global_url)
        end
      end
    end

    if params[:media] == "song"
      SharedSong.create(
        :account_id => account_id,
        :sender_email => user_email,
        :recipient_email => params[:email],
        :song_id => params[:item_id])
    end

    if request.xhr? && params[:multitask]
      render :json => { :success => true }
    else
      respond_to do |format|
        format.html do
          render :action => "confirmation"
        end
        format.xml { render :xml => Player::Message.new( :message => t('basics.message_sent') ) }
      end
    end
    
  end

  def confirmation
  end
  
  def email_share_mix
    user_email = params[:user_email]
    email_arr = params[:email].split(',')
    begin
      if logged_in?
        sender_name = current_user.name
        subject_line = t('coke_messenger.email_share.subject', :user => sender_name)
        share_link = "http://#{current_site.domain}/playlists?station_id=#{params[:id]}"  
        UserNotification.deliver_send_email_share_mix(
            :locale => current_site.default_locale,
            :subject_line => subject_line,
            :sender => user_email,
            :sender_name => sender_name,
            :recipient_name => params[:name], 
            :recipient_mail => email_arr,
            :link => share_link,
            :message => params[:msg])
        status = {:status => 'success'}
      else
        status = {:status => 'failed'}
      end 
    rescue Timeout::Error
      status = {:status => 'failed'}
    end  
    render :json => status
  end
  
  private
    def valid_email?(email)
      return (email =~ /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/)
    end

    def valid_msg?(msg)
      return !(msg =~ /(<script|script>|<sc|ipt>)/)
    end
end
