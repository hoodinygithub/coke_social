class PagesController < ApplicationController
  #caches_page :home, :if => Proc.new { |c| !c.request.format.js? }
  before_filter :authenticate, :only => [:x46b]
  # before_filter :login_required, :only => [:home]
  skip_before_filter :login_required, :except => [:home]

  layout "logged_out"

  def home
    @latest_badges = BadgeAward.latest(5)
    @top_djs_limit = 5
    @top_djs = current_site.top_djs.all(:limit => @top_djs_limit)
    @top_playlists_limit = 5
    @top_playlists = current_site.top_playlists.all(:limit => @top_playlists_limit)
    @drupal_feed = drupal_feed("http://cm-#{site_code}.cyloop.com/feeds/#{site_code}/coke_home_featured.xml", 6, true) if ["cokemx"].include? site_code
  end

  def messenger_home
    @recent_playlists = Rails.cache.fetch("modules/#{current_site.code}/last_playlists_played",
                                          :expires_delta => EXPIRATION_TIMES['sites_latest_playlists_played']) do
      # This request is very heavy and needs to be aggressively cached.  The :include is a big part of the problem.
      #
      # The songs.albums relations are included to display playlist coverart.  This should be a cache column in playlists.  Remove when that's done.
      # 
      # The owner is for dj owner details.
      #
      # Sometimes this result is too big to fit in MemCached (1MB per key limit), which is bad.  Might need to reduce the limit.
      current_site.playlists.all(:limit => 50, :order => 'last_played_at DESC', :include => [:owner, {:songs => :album}] ).sortable(
        :mixes,
        [:popularity, :total_plays],
        [:rating, :rating_cache],
        [:most_recent, :updated_at],
        [:alpha, :name]
      )
    end
    @title = t('coke_messenger.default_messenger_title')+t('coke_messenger.messenger_home.title')
    render 'coke_messenger/home', :layout => layout_unless_xhr('messenger')
  end

  def messenger_djs
    @title = t('messenger_player.dj.title')
    @djs = current_site.top_djs.paginate(:page => params[:page], :per_page => 5)
    @total_pages = @djs.total_pages
    if params.has_key? :page
      render :partial => 'coke_messenger/djs', :collection => @djs
    else
      @djs = @djs.sortable(
            :djs,
            [:popularity, :default], # Can use :default if this is the default sort order
            [:most_followers, :follower_count],
            [:alpha, :name]
      )
      render 'coke_messenger/djs', :layout => layout_unless_xhr('messenger')
    end
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
  
  def about_coke
    @title = t 'site.about_coke'
    render "pages/#{site_code}/about_coke"
  end

  def faq
    @title = t 'site.faq'
    render "pages/#{site_code}/faq"
  end

  def bases_del_concurso
    render "pages/#{site_code}/bases_del_concurso", :layout => "support_page"
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
    render "pages/#{site_code}/privacy_policy", :layout => "support_page"
  end

  def safety_tips
    @title = t 'site.safety_tips'
    render "pages/#{site_code}/safety_tips"
  end

  def terms_and_conditions
    @title = t 'site.terms_and_conditions'
    render "pages/#{site_code}/terms_and_conditions", :layout => "support_page"
  end

  def block_alert
    render :layout => false
  end

  def profile_not_found
    render :layout => "support_page"
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
  
  def error_pages
    render '/error_pages/errors'
  end

  def downloads
    if current_site.code == "cokemx"
      render :layout => "support_page"
    else
      render :profile_not_found, :status => 404
    end
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
