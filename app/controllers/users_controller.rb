class UsersController < ApplicationController

  include Application::MsnRedirection

  before_filter :find_account_by_slug, :only => [:follow, :unfollow, :block, :unblock, :approve, :deny]
  before_filter :xhr_login_required, :only => [:follow]
  
  # before_filter :login_required, :only => [:edit, :update, :destroy, :confirm_cancellation, :remove_avatar]
  skip_before_filter :login_required, :only => [:new, :create, :errors_on, :feedback, :confirm_cancellation, :forgot]
  
  before_filter :go_home_or_return_if_logged_in, :only => [:new, :forgot]
  #before_filter :set_dashboard_menu, :only => [:edit, :update]

  ssl_required_with_diff_domain :new, :errors_on, :forgot#, :feedback, :edit, :destroy, :confirm_cancellation
  ssl_allowed_with_diff_domain :update, :create
  
  current_tab :settings
  disable_sanitize_params
  strip_tags_from_params
  
  # Show links buttons on reg page.
  # layout :compute_layout
  
  # GET /users/id
  def show
    @user = current_user
    if params[:ajax]
    #   render :text => my_settings_path(:iframe => true), :layout => 'iframe'
    # elsif params[:iframe]
      render :action => :edit, :layout => false
    else
      redirect_to :action => :edit
    end
  end

  # GET /users/id/edit
  def edit
    @user = current_user
    render :layout => false if params[:ajax]
  end

  # POST /users/id
  def update
    @user                    = User.find(current_user.id)
    params[:user]            = trim_attributes_for_paperclip(params[:user], :avatar)
    born_on_year             = params[:user].delete("born_on(1i)")
    born_on_month            = params[:user].delete("born_on(2i)")
    born_on_day              = params[:user].delete("born_on(3i)")
    email                    = params[:user].delete("email")
    @user.attributes         = params[:user]    
    
    if born_on_day && born_on_month && born_on_year
      @user.born_on_string = "#{born_on_year}-#{born_on_month}-#{born_on_day}"
    end
    
    @user.email = email.downcase if email

    twitter_username_changed = @user.twitter_username_changed?
    
    if @user.save
      Resque.enqueue(TwitterJob, {:user_id => @user.id, :twitter_username => @user.twitter_username}) if twitter_username_changed
      flash[:success] = t('settings.saved')
      #return redirect_to(edit_my_settings_path)
      render :action => :edit
    else
      flash[:error] = t('settings.not_saved')
    end
    render :action => :edit

  end

  # GET /users/new
  # This is a temp fix for the flash player to handle registration.
  # Temp as of 8/17/09
  def new
    # pre-populate user object with sso fields
    @user = session[:sso_user].nil? ? User.new : session[:sso_user]
  end

  # Cross-network opt-in action
  def cross_network
    if params[:opt_in] and params[:opt_in] == "1"
      u = current_user
      # u.encrypt_demographics
      u.networks << ApplicationController::CYLOOP_NETWORK
      u.save!
      send_registration_notification u
      
      if request.xhr?
        js = "_gaq.push(['_trackPageview', '/auth/optin/confirm']);"
        js << "$.alert_layer.showOverlay(true);"
        js << "window.location.reload();"
        render :js => js
      else
        redirect_back_or_default(home_path)
      end
    else 
      @user = current_user
      flash[:error] = t('registration.cross_network.error') if request.referrer =~ /cross_network/
      if request.xhr?
        @msg = "opt_layer"
        @error_msgs = "show error msgs"
        @locked = true
        unless params.has_key? :app and params[:app] == "multitask"
          layer_html = render_to_string '/messenger_player/layers/alert_layer'
          render(:json => {:status => 'redirect', :html => layer_html}, :layout => false)
        end
      end
    end
  end

  # POST /users
  def create
    params[:user] = trim_attributes_for_paperclip(params[:user], :avatar)
    born_on_year = params[:user].delete("born_on(1i)")
    born_on_month = params[:user].delete("born_on(2i)")
    born_on_day = params[:user].delete("born_on(3i)")
    email = params[:user].delete("email")

    @user = User.new(params[:user])
    @user.entry_point = current_site
    @user.ip_address  = remote_ip
    @user.msn_live_id = session[:msn_live_id] if session[:msn_live_id] # wlid_web_login?
    @user.born_on_string = "#{born_on_year}-#{born_on_month}-#{born_on_day}"
    # You accepted the Cyloop terms.
    # Just logging into Coke means you're in the Coke network.
    @user.networks = [ApplicationController::CYLOOP_NETWORK, ApplicationController::COKE_NETWORK]

    @user.email = email.downcase if email

    if @user.save
      cookies.delete(:auth_token) if cookies.include?(:auth_token)
      session[:msn_live_id] = nil #if wlid_web_login?
      session[:registration_layer] = true
      session[:sso_user] = nil
      session[:sso_type] = nil
      self.current_user = @user

      send_registration_notification @user

      # Background validation to twitter username
      Resque.enqueue(TwitterJob, {
        :user_id => @user.id, :twitter_username => @user.twitter_username
      }) if @user.twitter_username_changed?

      if request.xhr?
        js = "_gaq.push(['_trackPageview', '/auth/registration/confirm']);"
        js << "$.alert_layer.showOverlay(true);"
        js << "window.location.reload();"
        render :js => js
      else
        respond_to do |format|
          #format.html { redirect_back_or_default(my_dashboard_path) }
          format.html { redirect_to home_path }
          format.xml  { render :xml => Player::Message.new( :message => t('messenger_player.registration.success') ) }
        end
      end
    else
      if request.xhr?
        @msg = "registration_layer"
        @error_msgs = "show error msgs"
        layer_html = render_to_string '/messenger_player/layers/alert_layer'
        render(:json => {:status => 'redirect', :html => layer_html}, :layout => false)
      else
        respond_to do |format|
          format.html { render :action => :new }
          # format.html { redirect_to :action => :new }
          format.xml  { render_xml_errors( @user.errors ) }
        end
      end
    end
  end

  def forgot
    if request.post?
      @user = User.forgot(params[:user])

      if @user.nil? or !@user.errors.empty?
        # Email not found.
        # ...or...
        # Validation errors exist.
        #
        # We're pretending that everything was ok b/c of Coke security policies.
        # Don't want to reveal a valid email address.
        flash[:success] = t('forgot.reset_message_sent')
        render_forgot_xhr(false, "show error msgs", t('coke_messenger.layers.forgot_password_layer.error_msg')) if request.xhr?
      elsif (@user.msn_live_id || @user.sso_windows)
        # Can't change pw here.  Must go to MSN.
        flash.now[:error] = t('reset.msn_account')
        render_forgot_xhr(false, "show error msgs", t('reset.msn_account')) if request.xhr?
      elsif @user.sso_facebook
        # Can't change pw here.  Must go to Facebook.
        flash.now[:error] = t('reset.facebook_account')
        render_forgot_xhr(false, "show error msgs", t('reset.facebook_account')) if request.xhr?
      else
        # Everything checks out.
        UserNotification.send_reset_notification(
          :user_id => @user.id,
          :password => @user.reset_password,
          :locale => current_site.default_locale
          ) unless Rails.env.development?

        flash[:success] = t('forgot.reset_message_sent')

        render_forgot_xhr(true, nil, nil) if request.xhr?
      end

    elsif !request.referer.blank? && request.referer !=~ /forgot|session/
      session[:return_to] = request.referer
    end
  end

  def render_forgot_xhr(p_success, p_error_msgs, p_error_msg)
    @msg = "forgot_password"
    @success = p_success
    @error_msgs = p_error_msgs
    @error_msg = p_error_msg
    layer = render_to_string '/messenger_player/layers/alert_layer'
    render(:json => {:status => 'redirect', :html => layer}, :layout => false)
  end

  # GET /users/errors_on?field=slug&value=foo
  def errors_on
    field = params[:field].to_sym
    params[:value] = params[:value].downcase if field.equal? :email
    user  = User.new(field => params[:value], :ip_address => remote_ip)

    field_name  = params[:field] == 'slug' ? t("registration.your_profile_name") : t("registration.email_address")
    exclamation = params[:field] == 'slug' ? t('registration.slug_available_exclamation') : t('registration.is_available_exclamation')

    user.valid?
    if user.errors.on(field)
      render :json => ["#{User.human_attribute_name(field)} #{user.errors.on(field).to_a.first}", 'error'].to_json
    else
      message = "#{exclamation}"
      render :json => [message, 'info'].to_json
    end
  end

  def confirm_cancellation
    user = current_user
    result = { :user_id => user.id }
    unless params[:delete_info_accepted]
      result[:errors] = { :delete_password => I18n.t('account_settings.password_required') }
      render :json => result.to_json
    else
      render :layout => false
    end
  end

  def feedback
    @address = params[:address]
    feedback = params[:feedback]
    if feedback && !feedback.empty?
      options = {
        :site_id      => current_site.code,
        :mailto       => feedback_recipient,
        :address      => params[:address],
        :country      => params[:country],
        :os           => params[:os],
        :browser      => params[:browser],
        :feedback     => params[:feedback],
        :cancellation => true
      }
      UserNotification.send_feedback_message( options )
    end
    if params[:redirect_to]
      redirect_to params[:redirect_to] 
    else
      render :layout => false
    end
  end

  def destroy
    user = current_user
    result = { :user_id => user.id }
    if params[:delete_info_accepted]
      options = {
        :user_id => user.id,
        :site_id => request.host
      }
      if current_user.cancel_account!
        UserNotification.send_cancellation(options)
        cookies.delete(:auth_token) if cookies.include?(:auth_token)
        result[:success] = true
        #if wlid_web_login?
        #  result[:redirect_to] = msn_logout_url
        #else
        result[:redirect_to] = root_url
        #end
        result[:email] = user.email
      end
    else
      result[:errors] = { :delete_password => I18n.t('account_settings.password_required') }
    end
    render :json => result.to_json
  end

  def remove_avatar
    @user = current_user
    if @user.remove_avatar
      flash[:success] = t('settings.saved')
      redirect_to :action => :edit
    else
      flash[:error] = t('settings.not_saved')
      render :action => :edit
    end
  end
  
  def follow
    current_user.follow(@account) unless current_user.follows?(@account)
    if @account.private_profile?
      follow_status = {:status => 'pending'}
    else
      follow_status = {:status => 'following'}  
    end
    deliver_friend_request_email(@account) if @account.receives_following_notifications?
    render :json => follow_status
  end
  
  def unfollow
    if current_user.follows?(@account)
      current_user.unfollow(@account) 
    elsif @account.follow_requests.collect(&:follower_id).include? current_user.id
      @account.follow_requests.find_by_follower_id(current_user.id).destroy
    end
    render :layout => false, :text => ''
  end
  
  def approve
    f = current_user.follow_requests.select {|f| f.follower_id == @account.id}.first

    if f and f.approve!
      render :layout => false, :partial => 'shared/network_collection_info', :locals => { :item => f.follower }
    else
      render :text => ""
    end
  end
  
  def deny
    f = current_user.follow_requests.select {|f| f.follower_id == @account.id}.first
    f.destroy if f
    render :nothing => true
  end
  
  def block
    current_user.block(@account)
    render :nothing => true
  end
  
  def unblock
    current_user.unblock(@account) if current_user.blocks?(@account)
    render :nothing => true
  end

  def tiny_box_html
    @user = Account.find(params[:user_id])
    @last_box = true if params[:last_box]
    render :layout => false
  end
  
  
  private
  def xhr_login_required
    unless current_user
      return render(:json => {:status => 'redirect', :url => login_path})
    end
  end
  
  def find_account_by_slug
    account_slug = AccountSlug.find_by_slug(params[:user_slug])
    @account = account_slug.account
  end

  # For the old user_data header partial with the drop-down menu
  #def set_dashboard_menu
  #  @dashboard_menu = :settings
  #end

  protected
  def compute_layout
    [:new, :create, :forgot].include?(action_name.to_sym) ? "no_search_form" : "application" 
  end

  def send_registration_notification(p_user)
    UserNotification.send_registration( :user_id => p_user.id, :subject => t("registration.email.subject"), :host_url => request.host, :site_id => current_site.code, :global_url => global_url, :locale => current_site.default_locale) unless Rails.env.development?
  end  
end

