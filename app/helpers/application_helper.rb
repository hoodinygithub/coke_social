module ApplicationHelper

  include PopupHelper
  include TagsHelper

  def redirect_owner(owner, path)
    path_to = if logged_in? && owner == current_user
      case path
        when "profile"
          "/my/dashboard"
        when "followers"
          "/my/followers"
        when "playlists"
          "/my/playlists"
      end
    else
      case path
        when "profile"
          user_path(owner)
        when "followers"
          user_followers_path(owner)
      when "playlists"
          user_playlists_path(owner)
      end
    end
  end

  # Look into caching for 24 hrs
  def top_playlists(count=50)
    current_site.top_playlists.all(:limit => count, :order => 'total_requests DESC')
  end

  def ssl_login_path
    if request.ssl?
      session_path
    elsif request.host =~ /localhost/ or request.port == 3000
      "http://#{request.host}:#{request.port}#{session_path}"
    else
      "#{ssl_site_url}#{session_path}"
    end
  end

  def host_with_port(uri=nil, options={})
    protocol = "#{request.ssl? ? 'https://' : 'http://'}"
    host     = options[:host] || request.host
    port     = options.has_key?(:host) ? nil : (request.port == nil ? nil : ":#{request.port}")
    "#{protocol}#{host}#{port}#{uri}"
  end

  def filter_link_by(link_label, options)
    type = options.delete(:type).to_s

    url = request.request_uri.split('?').first

    url << (url.include?('?') ? '&' : '?')
    url << "filter_by=#{type}"
    url = url.downcase

    options[:class] = 'active' if (type == 'all' && !@filter_type)

    if @filter_type.to_s == type
      options[:class] = 'active'
    end

    link_to link_label, url, options
  end

  def sort_link_to(type, options = {})
    type = type.to_s if type.is_a? Symbol

    raise ArgumentError unless type

    url = request.request_uri.split('?').first
    url << "?page=#{params[:page]}" if params.fetch(:page, nil)
    url << (url.include?('?') ? '&' : '?')
    url << "sort_by=#{type}"
    url = url.downcase

    if @sort_type.to_s == type
      options[:class] = 'active'
    end

    link_to t("sort.#{type}").mb_chars.upcase.to_s, url, options
  end
  
  def sort_form(klass, *types, &block)
    options = ""
    types.each do |type|
      options << "<option value='#{current_url(:sort_by => type.to_s)}' #{"selected" if (params[:sort_by].to_s == type.to_s)}>#{t("sort.#{type}", :user_name => (profile_user.name rescue t('basics.user'))).mb_chars.titleize}</option>"
    end
    
    if block_given?
      concat("<form class='#{klass}' action='return false;'>
         #{capture(&block)}
         <select onchange='Base.Util.xhr_call(this.value)'>#{options}</select>
       </form>")
    else
      "<form class='#{klass}' action='return false;'>
         <select onchange='Base.Util.xhr_call(this.value)'>#{options}</select>
       </form>"
    end
  end
  
  def current_url(overwrite={})
    url_for :only_path => true, :params => params.merge(overwrite)
  end

  def short_date(date)
    #I18n.localize(date, :format => :long) rescue ""
    if current_site.default_locale.to_s == "en"
      date.strftime("%m/%d/%Y")
    else
      date.strftime("%d/%m/%Y")
    end
  end
  
  def profile_owner?
    current_user == profile_account
  end

  def profile_user?
    profile_account.kind_of? User
  end

  def profile_artist?
    profile_account.kind_of? Artist
  end

  def main_content(content)
    if params[:controller] == 'pages'
      if params[:action] != 'home'
        content_tag(:div, content_tag(:div, content_tag(:div, content, :id => 'pages_internal'), :id => 'internal_content'), :id => 'pages')
      else
        content
      end
    else
      content_tag(:div, content, :id => 'internal_content')
    end
  end

  def special_button(type, button_label, options = {})
    options.merge!({
      :class => "#{options[:class]} #{type}",
      :onclick => options[:onclick].nil? ? "return false;" : "#{options[:onclick]}; return false;" 
    })

    options[:class] << " full_width" if options[:full_width]

    if options[:href]
      options.delete(:onclick)
    else
      options[:href] = '#' unless options[:href]
    end

    if options[:onclick].nil?
      options.delete(:onclick)
    end

    if options[:width]
      span_label = content_tag(:span, button_label, :style => "width: #{options.delete(:width)}")
    else
      span_label = content_tag(:span, button_label)
    end

    button = content_tag(:span, span_label)
    link_to button, options[:href], options
  end

  def blue_button(button_label, options = {})
    special_button(:blue_button, button_label, options)
  end
  
  def red_button(button_label, options = {})
    special_button(:red_button, button_label, options)
  end
  
  def red_button(button_label, options = {})
    special_button(:red_button, button_label, options)
  end  

  def grey_button(button_label, options = {})
    special_button(:grey_button_big, button_label, options)
  end

  def green_button(button_label, options = {})
    special_button(:green_button, button_label, options)
  end

  def yellow_button(button_label, options = {})
    special_button(:yellow_button, button_label, options)
  end
  
  def orange_button(button_label, options = {})
    special_button(:orange_button, button_label, options)
  end
  
  def follow_button(attrs = {})
    account = attrs.delete(:account)
    if current_user and account.follow_requests.collect(&:follower_id).include? current_user.id
      action       = nil
      key          = 'pending'
      button_color = 'orange'
    elsif current_user and current_user.follow_requests.collect(&:follower_id).include? account.id
      action       = 'approve'
      key          = 'pending'
      button_color = 'orange'
    elsif current_user and current_user.follows?(account)
      action       = 'unfollow'
      key          = 'unfollow'
      button_color = 'green'
    else
      action       = 'follow'
      key          = 'follow'
      button_color = 'red'
    end

    locale_key = "actions.#{key}"

    return_to = request.request_uri
    return_to = radio_path(:station_id => return_to.split('/')[3]) if return_to =~ /\/playlists\/info\/([0-9]+)/
    return_to = attrs[:return_to_ajax] if attrs.has_key?(:return_to_ajax)

    layer_path = send("follow_#{account.class.name.downcase}_registration_layers_path",
                      :return_to => return_to,
                      :account_id => account.id,
                      :follow_profile => account.id)

    remove_div = attrs.has_key?(:remove_div) ? attrs[:remove_div] : page_owner?

    # remove_div override when on the radio page to prevent slide
    remove_div = false if attrs[:radio] == true

    onclick_cb = "Base.community.#{action}('#{account.slug}', this, #{remove_div}, '#{layer_path}')" if action
    attrs.merge!({:onclick => onclick_cb, :class => 'follower_btn'})
    if account.is_a?(User) and (account.respond_to?(:blocks?) and !account.blocks?(current_user)) and account != current_user or account.is_a?(Artist)
      send("#{button_color}_button", t(locale_key), attrs)
    end
  end

  def create_radio_button(attrs = {})
    attrs.merge!({:href => radio_path})
    button = send("blue_button", t("home.create_radio"), attrs)
  end

  def follow_button2(user, options={})
    is_following    = options.fetch(:is_following, nil)
    skip_auto_width = options.fetch(:skip_auto_width, false)
    current_station = options.fetch(:current_station, session[:current_station])

    if logged_in?
      id = user.kind_of?(Account) ? user.id : user
      if is_following ||= current_user.follows?(id)
        unless is_following == true
          is_following.followee.private_profile??message = t("actions.awaiting_approval"): message = :unfollow
        else
          message = :unfollow
        end
        method = :post
      elsif current_user.awaiting_follow_approval?(id)
        message = t("actions.awaiting_approval")
        method = :post
      else
        message = :follow
        method = :put
      end
      right_follow_path = if skip_auto_width
        if method == :put
          special_followee_update_path(:id => id, :skip_auto_width => 1)
        else
          special_followee_destroy_path(:id => id, :skip_auto_width => 1)
        end
      else
        if method == :put
          my_following_path(id)
        else
          followee_destroy_path(id)
        end
      end
      follow_button_element = button_to(
        message,
        right_follow_path,
        {
          :method          => method,
          :title           => message,
          :class           => 'follow'
        }
      )
      content_tag(:div, follow_button_element)
    else
      user = Account.find(user) unless user.kind_of?(Account)
      id   = user.id
      return_to = request.request_uri
      if return_to =~ /\/radio\/info\/([0-9]+)/
        station   = Artist.find($1).station.station rescue nil

        return_to = if station.nil?
          if current_station.nil?
            '/radio'
          else
            radio_path(:station_id => current_station.id)
          end
        else
          radio_path(:station_id => station.id)
        end
      end
      layer_path = if user.kind_of?(User)
        follow_user_registration_layers_path(:return_to => return_to, :account_id => id, :follow_profile => id)
      else
        follow_artist_registration_layers_path(:return_to => return_to, :account_id => id, :follow_profile => id)
      end
      pill_link_to :follow, layer_path, :title => :follow, :class => "facebox follow"
    end
  end

  def tag_links(item, active_scope = :playlists, limit=3, include_text=true, link_options={})
    links = []
    link_options[:content_switch_enabled] = true unless (link_options.has_key? :content_switch_enabled)
    conditions = "valid_tags.site_id = #{current_site.id} and valid_tags.deleted_at IS NULL"
    joins      = "INNER JOIN valid_tags ON valid_tags.tag_id = #{Tag.table_name}.id"
    tags = item.tags.all(:limit => limit, :joins => joins, :conditions => conditions)
    count=0
    max_tags_len = 32
    tags=tags.map{ |tag|
        link_text=tag.name
        count=max_tags_len
        max_tags_len-=link_text.length
        if max_tags_len <= 0
          link_text = truncate(link_text, :length=>count) 
        end 
        link_to(link_text, main_search_path(:scope => active_scope.to_s, :q => tag.name), link_options)
    }
    unless tags.empty?
      if include_text
        "#{t('basics.tags')}: #{tags.join(", ")}"
      else
        "#{tags.join(", ")}..."
      end
    end
  end

  def station_contains(item, limit=3, include_text=true, link_options={}, options={})
    links = []
    name_concat = []
    station_artists = item.includes(limit)

    station_artists.each do |station_artist|
      name_concat << station_artist.artist.name unless station_artist.artist.nil?
      break if link_options[:limit] && name_concat.to_s.length > link_options[:limit].to_i
      links << link_to(station_artist.artist.name, main_search_path(:scope => 'playlists', :q => CGI::escape(station_artist.artist.name)), link_options) unless station_artist.artist.nil?
    end

    if options.has_key?(:make_list)
      "<li>#{links.join("</li><li>")}</li>"
    else
      "#{(t('basics.contains') + ": ") if include_text}#{links.join(", ")}#{station_artists.size > links.size ? "..." : "."}"
    end
  end

  def messenger_station_contains(item, limit=3, include_text=true, link_options={})
    links = []
    name_concat = []
    station_artists = item.includes(limit)

    station_artists.each do |station_artist|
      name_concat << station_artist.artist.name unless station_artist.artist.nil?
      break if link_options[:limit] && name_concat.to_s.length > link_options[:limit].to_i
      links << station_artist.artist.name unless station_artist.artist.nil?
    end

    if include_text
      "<strong>#{t('basics.contains')}:</strong> #{links.join(", ")}..."
    else
      "#{links.join(", ")}..."
    end
  end

  def render_flash_messages
    if flash[:success]
      message = flash[:success]
      stylesheet_class = 'confirmation_message'
    elsif flash[:error]
      message = flash[:error]
      stylesheet_class = 'error_message'
    end

    flash[:error] = flash[:success] = nil

    html = ""
    if defined? message and !message.blank?
      html = content_tag(:div, content_tag(:div, message, :class => stylesheet_class), :class => 'message')
    end

    html
  end

  def javascript_flash_messages(flash_message)
    message = stylesheet_class = ""
    flash_message.each do |key, value|
      stylesheet_class = key.to_s == "error" ? "error_message" : "confirmation_message"
      message = value.to_s
    end

    html = ""
    if defined? message and !message.blank?
      html = content_tag(:div, content_tag(:div, message, :class => stylesheet_class), :class => 'message')
    end

    html
  end

  def four_thumbs_to(station, options = {})
    station      = station.try(:playable)
    station_link = radio_path(:station_id => station.station.id)

    station_images_with_links = []

    # TODO: Handle this issue with DB showing a default image
    if options[:type].nil?
      station.includes(4).each do |artist|
        station_images_with_links << link_to(image_tag(AvatarsHelper.avatar_path(artist.album, :small), :class => 'avatar_four_thumbs'), station_link)
      end
      station_images_with_links << content_tag(:br, "&nbsp;", :class => 'clearer') if options[:clearer]
      html = content_tag(:div, station_images_with_links, :class => "four_thumbs #{options[:class]}")

    elsif options[:type] == :small
      station.includes(4).each do |artist|
        station_images_with_links << link_to(image_tag(AvatarsHelper.avatar_path(artist.album, :small), :class => 'avatar_four_thumbs_small'), station_link)
      end
      station_images_with_links << content_tag(:br, "&nbsp;", :class => 'clearer') if options[:clearer]
      html = content_tag(:div, station_images_with_links, :class => "four_thumbs_small #{options[:class]}")

    elsif options[:type] == :medium
      station.includes(4).each_with_index do |artist, index|
        avatar_class = "avatar_four_thumbs_medium avatar_#{index}" 
        station_images_with_links << link_to(image_tag(AvatarsHelper.avatar_path(artist.album, :small), :class => avatar_class), station_link)
      end
      station_images_with_links << content_tag(:br, "&nbsp;", :class => 'clearer') if options[:clearer]
      html = content_tag(:div, station_images_with_links, :class => "four_thumbs #{options[:class]}")

    elsif options[:type] == :big
      station.includes(4).each_with_index do |artist, index|
        avatar_class = "avatar_four_thumbs_big avatar_#{index}"         
        station_images_with_links << link_to(image_tag(AvatarsHelper.avatar_path(artist.album, :small), :class => avatar_class), station_link)
      end      
      station_images_with_links << content_tag(:br, "&nbsp;", :class => 'clearer') if options[:clearer]
      html = content_tag(:div, station_images_with_links, :class => "four_thumbs_big #{options[:class]}")
    end
  end


  def nav_aux_login_url
    if ((params[:controller] == "pages" and params[:action] == "home") or
        (params[:controller] == "users" and params[:action] == "new") or
        (params[:controller] == "sessions" and params[:action] == "new"))
      my_dashboard_path
    else
      request.request_uri
    end
  end

  def body_classes(aditional_classes=nil)
    all_classes = [
      "#{site_code}_#{controller.action_name}",
      "#{controller.controller_name}_#{controller.action_name}",
      controller.controller_name,
      controller.action_name,
      I18n.locale,
      site_code
    ]
    unless aditional_classes.nil?
      all_classes << " #{aditional_classes}"
    end
    all_classes.join(" ")
  end
  
  def html_attrs(lang = 'en-US')
    {:xmlns => "http://www.w3.org/1999/xhtml", 'xml:lang' => lang, :lang => lang}
  end  

  def application_html_attrs
    attrs =
      html_attrs.merge( 'xmlns:og' => 'http://opengraphprotocol.org/schema/', 'xmlns:fb' => 'http://www.facebook.com/2008/fbml' )
    attrs.map{|k,v| "#{k}='#{v}'"}.join(" ")
  end

  def twitter_date_activity(date)
    date = Time.at(date.to_i)
    output = date.to_date.to_s(:default)
    output << " | #{date.strftime('%I:%M%p')}"
  end

  def generic_URL_regexp
    @generic_URL_regexp ||= Regexp.new( '(^|[\n ])([\w]+?://[\w]+[^ \"\n\r\t<]*)', Regexp::MULTILINE | Regexp::IGNORECASE )
  end
  def starts_with_www_regexp
    @starts_with_www_regexp ||= Regexp.new( '(^|[\n ])((www)\.[^ \"\t\n\r<]*)', Regexp::MULTILINE | Regexp::IGNORECASE )
  end
  def starts_with_ftp_regexp
    @starts_with_ftp_regexp ||= Regexp.new( '(^|[\n ])((ftp)\.[^ \"\t\n\r<]*)', Regexp::MULTILINE | Regexp::IGNORECASE )
  end
  def email_regexp
    @email_regexp ||= Regexp.new( '(^|[\n ])([a-z0-9&\-_\.]+?)@([\w\-]+\.([\w\-\.]+\.)*[\w]+)', Regexp::IGNORECASE )
  end
  def linkify( text )
    s = text.to_s
    s.gsub!(generic_URL_regexp, '\1<a target="_blank" rel="nofollow" href="\2">\2</a>' )
    s.gsub!(starts_with_www_regexp, '\1<a target="_blank" rel="nofollow" href="http://\2">\2</a>' )
    s.gsub!(starts_with_ftp_regexp, '\1<a target="_blank" rel="nofollow" href="ftp://\2">\2</a>' )
    s.gsub!(email_regexp, '\1<a target="_blank" rel="nofollow" href="mailto:\2@\3">\2@\3</a>' )
    s
  end

  def gatracker_id
    case current_site.code
    when "cokelatam"
      "UA-19631092-12"
    when "cokebr"
      "UA-19631092-13"
    when "cokemx"
      "UA-19631092-10"
    when "cokear"
      "UA-19631092-11"
    end
  end

  def gadomain_name
    if ENV['RAILS_ENV'] =~ /production/
      ".cfm.cyloop.com"
    else
      ".hoodiny.com"
    end
  end
  
  def messenger_gatracker_id
    case current_site.code
    when "cokear"
      "UA-19631092-14"
    when "cokebr"
      "UA-19631092-15"
    when "cokelatam"
      "UA-19631092-17"
    when "cokemx"
      "UA-19631092-16"
    end
  end
  
  def messenger_player_gatracker_id
    case current_site.name
    when "MSN Brazil"
      "UA-410780-39"
    when "MSN Mexico"
      "UA-410780-40"
    when "MSN Latam"
      "UA-410780-41"
    when "MSN US Latin"
      "UA-410780-42"
    when "MSN Canada EN"
      "UA-410780-43"
    when "MSN Canada FR"
      "UA-410780-44"
    when "MSN Argentina"
      "UA-410780-45"
    end
  end

  def banner_options(id)

    if logged_in?
      if current_user.type.upcase == "USER"
        visitor = "CONSUMER"
      else
        visitor = "ARTIST"
      end
    else
      visitor = "ANON"
    end

    if profile_account == nil
      profile = ""
    else
      if profile_account.type.upcase == "USER"
        profile = "CONSUMER"
      else
        profile = "ARTIST"
      end
    end

    options = {}
    if action_name == "home"
      cat = "38"
    elsif controller_name == "radio"
      cat = "3b"
    elsif controller_name == "demographics"
      cat = "3e"
    elsif controller_name == "artist_recommendations"
      cat = "3e"
    elsif profile == "CONSUMER"
      cat = "3a"
      set_profile = true
    elsif profile == "ARTIST"
      cat = "39"
    elsif controller_name == "users" && action_name == "new"
      cat = "3e"
    elsif controller_name == "searches"
      cat = "3d"
    else
      cat = "3f"
    end


    host_id = if ENV['RAILS_ENV'] =~ /production/
      case current_site.code.to_s
      when 'msnbr'
        "hs0005830"
      when 'msnmx'
        "hs0005801"
      when 'msnlatam'
        "hs0005866"
      when 'msnlatino'
        "hs0005872"
      when 'msncaen'
        "hs0005878"
      when 'msncafr'
        "hs0005877"
      when 'cyloop', 'cyloopes'
        'hs0004280'
      else
        "hs0005803"
      end
    else
      "hs0005803"
    end

    options[:id] = id
    options[:host] = host_id
    options[:valuecategory] = cat
    options[:klang] = current_site.default_locale.to_s
    options[:kviewertype] = visitor
    options[:kprofiletype] = profile unless !set_profile

    if profile == "ARTIST"
      options[:kfolder] = profile_artist.slug
      options[:kartistlabel] = profile_artist.label_name
      options[:kartistgenre] = profile_artist.genre_name
    elsif profile == "CONSUMER" && profile_account.has_custom_profile?
      options[:kfolder] = profile_account.slug
    end

    if logged_in? && current_user.city != nil
      options[:kcountry] = current_user.city.country.code
      options[:kregion] = current_user.city.region.name
      options[:kcity] = current_user.city.name
      options[:kage] = current_user.age unless current_user.born_on == nil
      options[:kgender] = current_user.gender
    end

    if id == "top_banner"
      options[:width] = 728
      options[:height] = 90
    end

    if id == "square_banner"
      options[:width] = 300
      options[:height] = 250
    end

    if id == "pixel_banner"
      options[:width] = 1
      options[:height] = 1
    end

    if id == "top_artists_banner"
      options[:width] = 120
      options[:height] = 30
    end

    if id == "top_songs_banner"
      options[:width] = 120
      options[:height] = 30
    end

    if params[:song_id] != nil
      options["--ksonglabel"] = artist_song(params[:song_id]).artist.label_name.to_s + "--"
      options["--ksonggenre"] = artist_song(params[:song_id]).artist.genre_name.to_s + "--"
    end

    options

  end

  def banner_ad(id)
    options = banner_options(id)
    url_options = options.to_a.map{|e| e.join("=")}.join("&")
    render :partial => 'shared/banner', :locals => {:options => options, :url_options => url_options}
  end

  def full_url(url)
    return url if url =~ /http/
    "http://#{url}"
  end

  def fb_appid
    Rails.env.production? ? "160520280625515" : "182370788441621"
  end

  # For permalink, use to_param method on model instead (see song.rb)
  # def perma_link(options={})
  #   "#{options[:id]}-#{options[:name].gsub(/[^a-z0-9]+/i, '-')}"
  # end

  def perma_id(link)
    "#{link.split("-")[0]}"
  end

  def profile_public_home?
    profile_user.slug == request.env["REQUEST_URI"].gsub!(/\//,'')
  end

  def navigation_args_main
    args = []
    if page_owner?
      if(profile_public_home?)
        args.push({:home => my_dashboard_path})
      else
        args.push({:dashboard => my_dashboard_path})
      end
    else
      args.push({:home => user_path})
    end
    if profile_type?("Artist")
      args.push({:biography => biography_index_path}, {:music => albums_path})
      args.push({:community => followers_path}, :charts)
    end
    if profile_type?("User")
      args.push(:playlists, {:stations => (page_owner?)? my_stations_path : user_stations_path})
      args.push({:community => following_index_path}, :charts)
    end
    if page_owner?
      args.push({:settings => my_settings_path})
    end
    args
  end

  def filter_args_global
    args = []
    args.push({:all => "#"})
  end

  def filter_args_charts
    args = []
    args.push({:songs => charts_songs_path})
    if profile_type?("Artist")
      args.push({:albums => charts_albums_path})
    end
    if profile_type?("User")
      args.push({:artists => charts_artists_path})
    end
    args
  end

  def filter_args_activity
    args = []
    if page_owner?
      args.push({:songs => my_dashboard_path})
    else
      args.push({:songs => user_path})
    end
    args
  end

  def filter_args_playlists
    args = []
    args.push({:all => playlists_path})
    args
  end

  def filter_args_albums
    args = []
    args.push({:all => albums_path})
    args
  end

  def filter_args_stations
    args = []
    args.push({:stations => :stations})
    args
  end

  def filter_args_followings
    args = []
    args.push({:following => following_index_path})
    args.push({:followers => followers_path})
    args.push({:follow_requests => my_follow_requests_path}) if (profile_user==current_user && current_user.private?)
    args
  end

  def pagination_args
    {
      :class => "paginacion",
      :previous_label => "«",
      :next_label => "»",
      :renderer => MultitaskPaginationRenderer
    }
  end

  def msn_home_page_link
    if site_includes(:msnbr, :msnmx, :msnlatam, :msnlatino, :msncaen, :msncafr)
      link_to( 'MSN Music', msn_home_page_link_path )
    else
      ''
    end
  end

  def msn_home_page_link_path
    if site_includes(:msnbr)
      'http://br.msn.com/'
    elsif site_includes(:msnmx)
      'http://prodigy.msn.com/'
    elsif site_includes(:msnlatam)
      'http://latam.msn.com/'
    elsif site_includes(:msnlatino)
      'http://latino.msn.com/'
    elsif site_includes(:msncaen)
      'http://entertainment.ca.msn.com/music'
    elsif site_includes(:msncafr)
      'http://divertissement.ca.msn.com/musique'
    elsif site_includes(:msnar)
      'http://ar.msn.com/'
    else
      ''
    end
  end

  def pluralize(count, singular, plural=nil)
    "#{number_with_delimiter(count) || 0} " + ((count == 1 || count == '1') ? singular : (plural || singular.pluralize))
  end

  def os_type
    my_os = request.env["HTTP_USER_AGENT"]
    case my_os
    when /Windows NT 6.0/ then "Windows Vista"
    when /Windows NT 5.2/ then "Windows Server 2003/Windows x64"
    when /Windows NT 5.1/ then "Windows XP"
    when /Windows NT 5.0/ then "Windows 2000"
    when /Windows NT 4.0/ then "Windows NT 4"
    when /WindowsXP/      then "Windows XP"
    when /WindowsME/      then "Windows ME"
    when /Windows98/      then "Windows98"
    when /Windows95/      then "Windows95"
    when /Symbian/        then "Symbian OS"
    when /Fedora/         then "Fedora Core"
    when /FreeBSD/        then "FreeBSD"
    when /Red Hat/        then "Red Hat"
    when /SUSE/           then "SUSE"
    when /Mandriva/       then "Mandriva"
    when /Ubuntu/         then "Ubuntu"
    when /Debian/         then "Debian"
    when /ASPLinux/       then "ASP Linux"
    when /ALTLinux/       then "ALT Linux"
    when /PCLinuxOS/      then "PC Linux"
    when /Mandrake/       then "Mandrake"
    when /SunOS/          then "Sun OS"
    when /Intel Mac OS X/ then "Intel Mac OS X"
    when /PPC Mac OS X/   then "Mac OS X"
    when /AmigaOS/        then "Amiga OS"
    else                       "Other OS"
    end
  end

  def browser_type
    my_browser = request.env["HTTP_USER_AGENT"]
    case my_browser
    when /MSIE 8.0/    then "Internet Explorer V8.0"
    when /MSIE 7.0/    then "Internet Explorer V7.0"
    when /MSIE 6.0/    then "Internet Explorer V6.0"
    when /MSIE 5.5/    then "Internet Explorer V5.5"
    when /MSIE 5.22/   then "Internet Explorer V5.22"
    when /MSIE 5.0/    then "Internet Explorer V5.0"
    when /MSIE 4.0/    then "Internet Explorer V4.0"
    when /MSIE 3.0/    then "Internet Explorer V3.0"
    when /MSIE 2.0/    then "Internet Explorer V2.0"
    when /Firefox/     then "Mozilla Firefox"
    when /Camino/      then "Camino"
    when /Dillo/       then "Dillo"
    when /Epiphany/    then "Epiphany"
    when /Firebird/    then "Mozilla Firebird"
    when /Thunderbird/ then "Mozilla Thunderbird"
    when /Geleon/      then "Mozilla Galeon"
    when /IBrowse/     then "IBrowse"
    when /iCab/        then "iCab"
    when /K-Meleon/    then "K-Meleon"
    when /Konqueror/   then "Konqueror"
    when /SeaMonkey/   then "SeaMonkey"
    when /Netscape/    then "Netscape"
    when /OmniWeb/     then "OmniWeb"
    when /Opera/       then "Opera"
    when /Safari/      then "Safari"
    else                    "Other Browser"
    end
  end

  def options_for_contact_us_categories
    [[t("contact_us.form.category_account"),  "Account - #{t("contact_us.form.category_account")} "],
      [t("contact_us.form.category_profile"),  "Profile - #{t("contact_us.form.category_profile")}"],
      [t("contact_us.form.category_security"), "Security - #{t("contact_us.form.category_security")}"],
      ["----------------------------------------------", ''],
      [t("contact_us.form.category_music"),    "Music - #{t("contact_us.form.category_music")}"],
      [t("contact_us.form.category_photos"),   "Photos - #{t("contact_us.form.category_photos")}"],
      [t("contact_us.form.category_other_features"),    'Other Features - #{t("contact_us.form.category_other_features")}'],
      ["----------------------------------------------", ''],
      [t("contact_us.form.category_error"),    "Errors - #{t("contact_us.form.category_error")}"],
      ["----------------------------------------------", ''],
      [t("contact_us.form.category_feedback"),   "Feedback - #{t("contact_us.form.category_feedback")}"],
      ["----------------------------------------------", ''],
      [t("contact_us.form.category_business"),   "Business - #{t("contact_us.form.category_business")}"],
      [t("contact_us.form.category_other"),   "Other - #{t("contact_us.form.category_other")}"],
    ]
  end

  def minimum_width_for_chart(item)
    ratio = item.ratio.to_f
    ratio = ratio.nan? ? 0 : ratio
    length  = chart_length(t("basics.play"))
    ((ratio * 95).to_i < length ? "#{length}" : "#{(ratio * 95).to_i}")
  end

  def chart_length(text)
    case text.length
    when 0..8
      22
    else
      26
    end
  end

  def render_flash
    render 'shared/flash', :flash => flash
  end

  def error_class_for(model, method)
    model.errors.on(method) ? "has_errors" : ""
  end

  def custom_error_message_on(model, method, key=nil)
    key = :"#{model.class.to_s.downcase}.#{method}" if key.nil?
    error_message_on model, method, :prepend_text => (!key.to_s.empty? ? "#{t(key)} " : "")
  end

  def nice_elapsed_time(timestamp)
    time = Time.at(timestamp.to_i)
    distance_of_time_in_words_to_now(time, true)
  end

def cyloop_logo_path(sm=true)
    sufix = "_sm" if sm

    path = case site_code.to_s
    when 'msnbr'
      'br'
    when 'msnmx'
      'mx'
    when 'msncaen'
      'canada_en'
    when 'msncafr'
      'canada_fr'
    when 'msnlatam'
      'latam'
    when 'msnlatino'
      'latino'
    when 'msnar'
      'ar'
    else
      return '/images/cyloop_logo.png'
    end
    "/images/msn_#{path}_music#{sufix}.png"
  end

  def coke_logo_path
    logo_home = "/images/logo_home.png"
    path = (( controller_name == 'pages' && action_name == 'home' ) ||
           ( controller_name == 'radio' && action_name == 'index' && params[:station_id].nil? )) ? logo_home : "/images/logo_#{site_code.to_s}.png"
    return path
  end

  def market_logo
    image = image_tag(coke_logo_path, :id => 'logo', :class => 'png_fix', :alt => 'Coca-Cola', :title => 'Coca-Cola')
    content = link_to(image, home_path)
    if ( (controller_name == 'pages' && action_name == 'home') || (controller_name == 'radio' && action_name == 'index' && params[:station_id].nil?) )
      content << image_tag("/images/slogan_#{site_code.to_s}.png", :id => 'slogan', :class => 'png_fix')
    end
    return content
  end

  def artist_or_user_name(artist_or_user)
    if artist_or_user.is_a?(Artist)
      artist_or_user.name
    else
      artist_or_user.first_name
    end
  end

  def on_dashboard?
    request.request_uri.match(/\/my\//)
  end

  def action_for(item)
    if logged_in?
      current_user.blocks?(item) ? 'unblock' : 'block'
    else
      'block'
    end
  end
  
  #'Movin Out Anthony's Song Out Anthonys Songs Song'
  def escape_for_js(str)
    if str
      #str.gsub!(/'/, "&#39;")
      temp = "before: #{str}"
      str.gsub!(/'/, CGI::escape("'"))
      str.gsub!(/"/, CGI::escape('"'))
    end
    str
  end

  def rating(rateable, enabled = false, id=nil, rate_text=nil)
    ratings = ""
    disabled = true unless enabled
    rating = false
    rating_id = id ? id : "rating_#{rateable.id}"
    (1..5).each do |rate|
      checked = rate == rateable.rating_cache.floor ? true : false
      ratings << radio_button_tag(rating_id, rate, checked, :class => 'star', :disabled => disabled)
    end
    
    rate_text = "<strong>#{rate_text}</strong>" if rate_text

    "<span class=\"rating\">
       #{rate_text}
       #{ratings}
     </span>"
  end

  # Helper for coke messenger ratings
  def messenger_rating(rateable, bottles=5)
    rating = "<div class='punt_botellas'>"
    (1..bottles).each do |b|
      rating << "<span class=#{rateable.rating_cache.to_i.floor >= b ? 'llena' : 'vacia' }></span>"
    end
    rating << "</div>"
    rating
  end

  def multitask_rating(rateable, bottles=5, klass='rating', can_rate=false)
    rating = "<span class='#{klass}'><span class='star-rating-control' id='#{rateable.id}' type='#{rateable.class}'>"
    (1..bottles).each_with_index do |b, idx|
      rating << "<div class=\"star-rating star-rating-#{can_rate ? "rateable" : "readonly"} #{ 'star-rating-on' if rateable.rating_cache.to_i.floor >= b }\"><a onclick='#{"return Base.rating.rate(this);" if can_rate}' title='#{idx+1}'>#{idx+1}</a></div>"
    end
    rating << "</span></span>"
    rating
  end

  def ajax_pagination_for(url, collection, per_page)
    total_pages = collection.paginate(:per_page => 5, :page => 1).total_pages
    if total_pages > 1
      content = ""
      (2..total_pages).each do |x|
        content << "<a href=\"#\" class=\"page\">#{x}</a>"
      end

    "<div class=\"pagination ajax_pagination { url: '#{url}'}\" >
      <span class=\"page current\">1</span>
      #{content}
    </div>"
    end
  end


  def multitask_tag_bottle(tags, max_tags=60)
    # <div class="tags_botella">
    #   <a class="tag_tam2" href="#" title="Romantico">Romantico</a>
    # </div><!-- .tags_botella -->
    # <div class="tags_botella_trans">&nbsp;</div><!-- .tags_botella_trans -->
    # <div class="tags_botella outer">
    #   <a class="tag_tam2" href="#" title="Romantico">Romantico</a>
    # </div><!-- .tags_botella -->
    
    
    tag_links = []
    tag_cloud tags, %w(tag_tam1 tag_tam2 tag_tam3 tag_tam4, tag_tam5) do |tag, css_class, index| 
      if tag_links.length <= max_tags && tag.taggings_count > 0
        tag_links << link_to(tag.nickname, main_search_path(:scope => 'playlists', :q => CGI::escape(tag.name)), :title => tag.nickname, :class => "#{css_class}", :content_switch_enabled => true) rescue nil
      end
    end
    <<-EOF
    <div class="tags_botella">
      #{tag_links.compact.join(' ')}
    </div>
    <div class="tags_botella_trans">&nbsp;</div>
    <div class="tags_botella outer">
      #{tag_links.compact.join(' ')}
    </div>
    EOF
  end
  
  def tag_bottle(tags)
    outer_tag_links = []
    inner_tag_links = []
    tag_cloud tags, %w(tag_css1 tag_css2 tag_css3 tag_css4, tag_css5) do |tag, css_class, index| 
      if tag.taggings_count > 0
        outer_tag_links << link_to(tag.nickname, main_search_path(:scope => 'playlists', :q => CGI::escape(tag.name)), :class => "tag_outer red #{css_class}", :id => "tag_outer_#{index}") rescue nil
        inner_tag_links << link_to(tag.nickname, main_search_path(:scope => 'playlists', :q => CGI::escape(tag.name)), :class => "tag_inner red #{css_class}", :id => "tag_inner_#{index}") rescue nil
      end
    end
    <<-EOF
    <script type="text/javascript">
      jQuery(document).ready(function(){
        jQuery("a.tag_outer").mouseover(function(e){
          e.preventDefault();
          ord = this.id.match(/tag_outer_(\\d+)/)[1];
          jQuery("#tag_inner_" + ord).removeClass('red').addClass("black");
          jQuery("#tag_outer_" + ord).removeClass('red').addClass("black");
        });

        jQuery("a.tag_outer").mouseout(function(e){
          e.preventDefault();
          ord = this.id.match(/tag_outer_(\\d+)/)[1];
          jQuery("#tag_inner_" + ord).removeClass('black').addClass("red");
          jQuery("#tag_outer_" + ord).removeClass('black').addClass("red");
        })
      });
    </script>
    <div class="bottle_tags">
      <table width="100%" height="100%">
        <tr>
          <td valign="bottom" align="center">
            #{inner_tag_links.compact.join(' ')}
          </td>
        </tr>
      </table>
    </div>
    <div id="tag_bottle" class="png_fix #{market_class}"></div>
    <div class="bottle_tags outer">
      <table width="100%" height="100%">
        <tr>
          <td valign="bottom" align="center">    
            #{outer_tag_links.compact.join(' ')}
          </td>
        </tr>
      </table>
    </div>
    EOF
  end
  
  def poll_link
    site_code == 'cokebr' ? 'http://polldaddy.com/s/4E940675C45189A2' : 'http://polldaddy.com/s/158304F6B410FA6A'
  end

  def lang_mappings
    case current_site.default_locale
    when :coke_BR
      "pt_BR"
    when :coke_ES
      "es_LA"
    when :coke_MX
      "es_MX"
    when :coke_AR
      "es_AR"
    else
      current_site.default_locale
    end
  end
  
  def market_class
    case current_site.default_locale
    when :coke_ES
      "es"
    when :coke_MX
      "mx"      
    when :coke_AR
      "ar"
    else
      ""
    end  
  end
end

