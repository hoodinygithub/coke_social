class PagesController < ApplicationController
  caches_page :home, :if => Proc.new { |c| !c.request.format.js? }
  before_filter :authenticate, :only => [:x46b]
  before_filter :login_required, :only => [:home]

  layout "logged_out"
  
  def home
    @latest_badges = {} 
    @top_djs = current_site.top_djs.all(:limit => 6)
    @top_playlists = current_site.top_playlists.all(:limit => 6)
  end

  def flash_callback
    respond_to do |format|
      format.js { render :template => 'pages/flash.js.erb', :layout => false }
    end
  end

  def about
    @title = t 'site.about_cyloop'
    render "pages/#{site_code}/about"
  end

  def faq
    @title = t 'site.faq'
    render "pages/#{site_code}/faq"
  end

  def feedback
    render :layout => false if request.xhr?
    if request.post?
      mailto = "#{request.host}@hoodiny.com"
      UserNotification.send_feedback_message( :site_id => current_site.code, :mailto => mailto, :address => params[:address], :country  => params[:country], :os => params[:os], :browser => params[:browser], :feedback => params[:feedback])
      redirect_to(root_url) unless request.xhr?
    end
  end

  def privacy_policy
    @title = t 'site.privacy_policy'
    render "pages/#{site_code}/privacy_policy"
  end

  def safety_tips
    @title = t 'site.safety_tips'
    render "pages/#{site_code}/safety_tips"
  end

  def terms_and_conditions
    @title = t 'site.terms_and_conditions'
    render "pages/#{site_code}/terms_and_conditions"
  end

  def block_alert
    render :layout => false
  end

  def profile_not_found
  end

  def profile_not_available
  end

  def sample_flag_desc
    render :layout => false
  end

  def contact_us
    if request.post?
      @contact_us = ContactUs.new
      @contact_us.attributes = params[:contact_us]
      if @contact_us.save
        data=params[:contact_us]
        profile = logged_in? ? "http://#{request.host}/#{current_user.slug}" : "User Not Logged"
        mailto = "#{request.host}@hoodiny.com"
        UserNotification.send_contact_us_message( :site_id => current_site.code, :mailto => mailto, :address => data[:address], :country  => data[:country], :os => data[:os], :browser => data[:browser], :feedback => data[:message], :category => data[:category], :host => request.host, :profile => profile)
        render 'pages/contact_us_confirmation' unless request.xhr?
      end

    else
       @contact_us = ContactUs.new(:address => logged_in? ? current_user.email : "User Not Logged",
                                :os      => os_type,
                                :browser => browser_type,
                                :country => current_country,
                                :message => t("contact_us.form.feedback_default"))
      if params[:only_form] == true
        render :layout => true, :params => { "only_form" => true }
      else
        render :layout => true, :params => { "only_form" => false }
      end

    end
  end

  def x46b
    @geo = { :remote_ip => remote_ip, :current_country => current_country }
    render "pages/x46b"
  end

  private
    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        username == "hoodiny" && password == "3057227000"
      end
    end

    def drupal_feed(url, size, full = true)
      FeedManager.new(site_code, url, full).get_drupal_feed( size )
    end

    def single_msn_feed( url, size, full = true )
      FeedManager.new(site_code, url, full).get_single_msn_feed(size)
    end

    def featured_feed( url, size, full = true )
      FeedManager.new(site_code, url, full).get_featured_feed(size)
    end

    def video_feed( url, size, full = true )
      FeedManager.new(site_code, url, full).get_video_feed(size)
    end

    def photos_msn_feed( url, size, full = true )
      FeedManager.new(site_code, url, full).get_photos_msn_feed(size)
    end

    def reviews_msn_feed(url, size, full = true)
      FeedManager.new(site_code, url, full).get_reviews_msn_feed(size)
    end

    def blog_feed( url, size, full = true )
      FeedManager.new(site_code, url, full).get_blog_feed(size)
    end

end

