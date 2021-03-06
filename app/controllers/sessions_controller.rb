class SessionsController < ApplicationController
  before_filter :set_return_to, :only => :new
  skip_before_filter :login_required
  skip_before_filter :auto_follow_profile
  before_filter :go_home_or_return_if_logged_in, :except => [:destroy, :status]
  ssl_required_with_diff_domain :edit, :update, :create

  # Show header links on login page.
  # layout :compute_layout

  # GET /session/new
  def new
    if params[:code]
      # Faceboook Connect through full page login
      # FacebookConnect.parse_facebook_code(params[:code], current_site.domain)
      user = FacebookConnect.parse_code(params[:code], request.url[/^.*\//])
      # puts user.inspect
      handle_facebook_sso_user(user);
    elsif params[:access_token]
      # Facebook Connect through popup login
      user = FacebookConnect.parse_access_token(params[:access_token], params[:expires])
      handle_facebook_sso_user(user)

      # Called by the Facebook popup before closing.
      # render :nothing => true
    elsif params[:wrap_verification_code]
      # Windows Connect through popup login
      callback = Rails.env.staging? ? 'http://staging.login.hoodiny.com:8081/coke' : 'http://login.cyloop.com:8081/coke'
      callback += new_session_path
      user = WindowsConnect.parse_verification_code(params[:wrap_verification_code], callback, cookies, params[:wrap_client_state], params[:exp])
      
      handle_windows_sso_user(user)

      # Close the Windows Connect login popup.  Facebook does this for us.
      respond_to do |format|
        format.html { render 'shared/_close_popup.html.erb', :layout => false }
      end
    elsif cookies[:wl_internalState]
      # Clear the Windows Connect session on login page load
      # This might cause trouble in the future if we decide to use WindowsConnect widgets on the page.
      # Right now, this is the only way to cancel a bad, currently logged-in WC session.
      #Rails.logger.info cookies
      #Rails.logger.info session
      WindowsConnect.clear_cookie_session(cookies)
    else
      # WindowsConnect refreshes the page with a page param.  If it's registration, redirect to the reg page.
      # This looks like a potential redirect loop if params[:page] = login
      redirect_to_page_param if params[:page]

      # Cyloop Login
      #render :new, :layout => false
    end
  end

  alias :show :new

  # POST /session
  def create
    # Cyloop Login
    # unless wlid_web_login?
    email = params[:email].downcase if params[:email]
    account = User.authenticate(email, params[:password], current_site)
    do_login(account, params[:remember_me])
    # end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete(:auth_token, :domain => ".#{request.domain}") unless cookies[:auth_token].nil?
    reset_session

    #if wlid_web_login?
    #  redirect_to(msn_logout_url)
    if params.has_key? :redirect_to
      redirect_to params[:redirect_to]
    else
      redirect_back_or_default('/')
    end
  end

  def status
    result = nil
    if logged_in?
      # Don't expose encrypted data fields here (email, name, gender, dob).
      result = { :logged_in => true, :id => current_user.id, :slug => current_user.slug, :opted_in => current_user.part_of_network?(ApplicationController::CYLOOP_NETWORK) }
    else
      result = { :logged_in => false }
    end

    # sso_user
    #  => true means the user exists
    #  => false means the user exists, but it's just to prefill reg fields.  It's not a saved user record.
    #  => nil means the user doesn't exist
    result[:sso_user] = if session.has_key?(:sso_user)
                          !session[:sso_user].new_record?
                        else
                          nil
                        end

    respond_to do |format|
      format.xml { render :xml => result }
      format.json { render :json => result }
    end
  end

private
  #
  # Gets around a domain issue for WLID
  #
  def corrected_registration_host
    session[:registered_from] || request.host
  end

  #
  # Login
  #
  def do_login(account, remember_me, p_render=true)
    if account.nil?
      flash[:error] = t("registration.login_failed")
      
      if request.xhr?
        @msg = "login_layer"
        @error_msgs = "show error msgs"
        login_layer = render_to_string '/messenger_player/layers/alert_layer'
        render(:json => {:status => 'redirect', :html => login_layer}, :layout => false)
      else
        # redirect_to login_path
        render :new
      end
      
      false
    elsif account.kind_of?(Artist)
      flash[:error] = t("registration.artist_login_denied")
      render :new
      false
    else
      self.current_user = account
      AccountLogin.create!( :account_id => account.id, :site_id => current_site.id )
      
      if remember_me == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value   => self.current_user.remember_token, 
                                 :expires => self.current_user.remember_token_expires_at,
                                 :domain  => ".#{request.domain}" }
      end

      # Attach current FB session to upcoming user session.
      sso_facebook_id = (session[:sso_user] and session[:sso_user]['sso_facebook']) ? session[:sso_user]['sso_facebook'] : nil
      account.update_attribute(:sso_facebook, sso_facebook_id) if sso_facebook_id
      
      # Attach current WindowsConnect session to upcoming user session.
      sso_windows_id = (session[:sso_user] and session[:sso_user]['sso_windows']) ? session[:sso_user]['sso_windows'] : nil
      account.update_attribute(:sso_windows, sso_windows_id) if sso_windows_id

      session[:sso_user] = nil
      session[:sso_type] = nil

      session[:registered_from] = nil
      flash[:google_code] = 'loginOK'

      if account.part_of_network? ApplicationController::CYLOOP_NETWORK
        flash.discard(:error)

        if p_render
          if request.xhr?
            js = "_gaq.push(['_trackPageview', '/auth/login/confirm']);"
            js << "$.alert_layer.showOverlay(true);"
            js << "window.location.reload();"
            render :js => js
          else
            redirect_back_or_default(my_dashboard_path(:host => corrected_registration_host))
          end
        end
      else
        # cross-network login
        if p_render
          if request.xhr?
            @msg = "login_layer"
            @error_msgs = "show error msgs"
            login_layer = render_to_string '/messenger_player/layers/alert_layer'
            render(:json => {:status => 'redirect', :html => login_layer}, :layout => false)
          else
            redirect_to({:controller=>:users, :action=>:cross_network}) 
          end
        end
      end
      true
    end
  end

  # 
  # Facebook SSO login
  #
  def handle_facebook_sso_user(p_user)
    return nil if p_user.nil?

    # TODO: account unification search
    same_sso_user = User.find_by_sso_facebook_and_deleted_at p_user.sso_facebook, nil
    unless same_sso_user.nil?
      do_login(same_sso_user, nil)
      return
    end

    # AccountUni search
    ## Rails validation enforces global email uniqueness
    same_email_user = User.find_by_email_with_exclusive_scope(p_user.email, :first, :select => "id, slug, gender, encrypted_gender, email, encrypted_email, name, encrypted_name, born_on, encrypted_born_on_string")
    unless same_email_user.nil?
      # logger.info "Found same email user."
      same_email_user.sso_facebook = p_user.sso_facebook
      unless same_email_user.part_of_network?
        same_email_user.encrypt_demographics
      end
      session[:sso_user] = same_email_user
      session[:sso_type] = "Facebook"
      redirect_to login_path
      return
    end

    session[:sso_user] = p_user
    session[:sso_type] = "Facebook"

    redirect_to_page_param
  end
  
  # 
  # Windows SSO login
  #
  def handle_windows_sso_user(p_user)
    return nil if p_user.nil?

    # AccountUni search
    ## db enforces uniqueness of sso_windows, deleted_at, so pick first
    same_sso_user = User.find_with_exclusive_scope(:first, :conditions => { :sso_windows => p_user.sso_windows, :deleted_at => nil })
    unless same_sso_user.nil?
      do_login(same_sso_user, nil, false)
      return
    end

    # AccountUni search
    ## db doesn't enforce uniqueness of msn_live_id, deleted_at, so just pick the most recent one
    ## This case isn't going to work because the appid doesn't match.
    same_wlid_user = User.find_with_exclusive_scope(:first, :conditions => { :msn_live_id => p_user.msn_live_id, :deleted_at => nil }, :order => "created_at DESC")
    unless same_wlid_user.nil?
      # Upgrade LiveID user to ConnectID user
      same_wlid_user.update_attribute(:sso_windows, p_user.sso_windows)
      do_login(same_wlid_user, nil, false)
      return
    end

    # AccountUni search
    ## Rails validation enforces global email uniqueness
    same_email_user = User.find_by_email_with_exclusive_scope(p_user.email, :first, :select => "id, slug, gender, encrypted_gender, email, encrypted_email, name, encrypted_name, born_on, encrypted_born_on_string, network_id, country_id, ip_address")
    unless same_email_user.nil?
      # logger.info "Found same email user."
      same_email_user.sso_windows = p_user.sso_windows
      unless same_email_user.part_of_network?
        same_email_user.encrypt_demographics
      end
      session[:sso_user] = same_email_user
      session[:sso_type] = "Windows"
      return
    end

    session[:sso_user] = p_user
    session[:sso_type] = 'Windows'
  end

  def redirect_to_page_param
    # If user was on reg page, redirect to pre-filled reg page.
    # If user was on login page, redirect to link page.
    if params[:page]
      if params[:page] == 'registration'
        redirect_to new_user_path
      else
        redirect_to login_path
      end
    else
      redirect_to new_user_path
    end
  end

end

