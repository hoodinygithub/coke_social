require 'cgi'
class SessionsController < ApplicationController
  before_filter :set_return_to, :only => :new
  skip_before_filter :login_required  
  before_filter :go_home_if_logged_in, :except => :destroy
  ssl_required_with_diff_domain :edit, :update, :create

  # Show header links on login page.
  # layout :compute_layout

  # GET /session/new
  def new
    #if wlid_web_login?
    #  token = params[:stoken] || nil
    #  wll.setDebug(true) if Rails.env.development?

    #  if(token)
    #    msn_live_id = wll.processLogin(params) || nil

    #    if msn_live_id
    #      session[:msn_live_id] = msn_live_id
    #      account = User.find_by_msn_live_id_and_deleted_at(msn_live_id, nil)
    #      if account
    #        do_login(account, 1, false)
    #      elsif session[:return_to] == '/messenger_player'
    #        redirect_to( session.delete(:return_to) )
    #      else
    #        redirect_to(new_user_path)
    #      end
    #    else
    #      flash[:error] = t("registration.msn_login_error")
    #      redirect_to "/"
    #    end
    #  else
    #    redirect_to msn_login_url
    #  end
    if !params[:code].nil?
      # Faceboook Connect through full page login
      # FacebookConnect.parse_facebook_code(params[:code], current_site.domain)
      user = FacebookConnect.parse_code(params[:code], request.url[/^.*\//])
      # puts user.inspect

      handle_facebook_sso_user(user);
    elsif !params[:access_token].nil?
      # Facebook Connect through popup login
      user = FacebookConnect.parse_access_token(params[:access_token], params[:expires])
      handle_facebook_sso_user(user);
    else
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

    if wlid_web_login?
      redirect_to(msn_logout_url)
    else
      redirect_back_or_default('/')
    end
  end

private
  # This is to get around a domain issue for WLID
  def corrected_registration_host
    session[:registered_from] || request.host
  end

  def do_login(account, remember_me, save_wlid=false)
    if account.nil?
      flash[:error] = t("registration.login_failed")
      render :new
      return false
    elsif account.kind_of?(Artist)
      flash[:error] = t("registration.artist_login_denied")
      #redirect_to(new_user_path)
      render :new
      return false;
    elsif account.part_of_network?
      self.current_user = account
      AccountLogin.create!( :account_id => account.id, :site_id => current_site.id )
      
      if remember_me == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value   => self.current_user.remember_token, 
                                 :expires => self.current_user.remember_token_expires_at,
                                 :domain  => ".#{request.domain}" }
      end
      
      #if save_wlid && wlid_web_login?
      #  account.update_attribute(:msn_live_id, session[:msn_live_id].to_s)
      #  session[:msn_live_id] = nil
      #end
      
      # Attach current FB session to upcoming user session.
      account.update_attribute(:sso_facebook, session[:sso_facebook].to_s) if session[:sso_facebook]
      session[:sso_facebook] = nil
      
      session[:registered_from] = nil
      flash[:google_code] = 'loginOK'
      flash.discard(:error)

      redirect_back_or_default(home_path(:host => corrected_registration_host))      
      return nil
    else
      # TODO: cross network-login
      flash[:error] = t("registration.cross_network_failed")
      render :new, :layout => false
      return false
    end
  end

  def handle_facebook_sso_user(p_user)
    return nil if p_user.nil?
    
    same_sso_user = User.find_by_sso_facebook p_user.sso_facebook
    unless same_sso_user.nil?
      do_login(same_sso_user, nil)
      return
    end
    
    same_email_user = User.find_by_email p_user.email
    unless same_email_user.nil?
      logger.info "Found same email user."
      flash[:error] = t("registration.link_sso_account")
      session[:sso_facebook] = p_user.sso_facebook
      redirect_to login_path
      return
    end
    
    session[:sso_user] = p_user
    redirect_to new_user_path
  end

  protected
  def compute_layout
    [:new, :create].include?(action_name.to_sym) ? "no_search_form" : "application" 
  end

end
