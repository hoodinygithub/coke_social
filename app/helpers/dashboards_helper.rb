module DashboardsHelper
  def menu_items(links)
    items = [{:menu => :home,          :label => "#{t('profile.navigation.home')}",     :url => links[:home]},
     {:menu => :playlists,     :label => "#{t('profile.navigation.playlists')}",        :url => links[:playlists]},
     {:menu => :badges,        :label => "#{t('profile.navigation.badges')}",           :url => links[:badges]},
     {:menu => :reviews,       :label => "#{t('profile.navigation.reviews')}",          :url => links[:reviews]},
     {:menu => :subscriptions, :label => "#{t('profile.navigation.subscriptions')}",    :url => links[:subscriptions]},
     {:menu => :activity,      :label => "#{t('profile.navigation.activity')}",         :url => links[:activities]},
     {:menu => :followers,     :label => "#{t('profile.navigation.followers')}",        :url => links[:followers]},
     {:menu => :following,     :label => "#{t('profile.navigation.following')}",        :url => links[:following]},
     ]
     
     if links[:settings]
       items << {:menu => :settings,      :label => "#{t('profile.navigation.account_settings')}", :url => links[:settings]}
     end
     
     if links[:logout]
       items << {:menu => :logout,        :label => "Logout", :url => links[:logout]}
     end
     
     items
  end
  
  def user_nav_links
    links = {
      :home          => user_path,
      :playlists     => user_playlists_path,
      :badges        => badges_path,
      :reviews       => user_reviews_path,
      :subscriptions => subscriptions_path,
      :activities    => activities_path,
      :followers     => followers_path,
      :following     => following_index_path
    }    
    menu_items(links)
  end
  
  def my_nav_links(options = {})
    links = {
      :home          => my_dashboard_path,
      :playlists     => my_playlists_path,
      :badges        => my_badges_path,
      :reviews       => my_reviews_path,
      :subscriptions => my_subscriptions_path,
      :activities    => my_activities_path,
      :followers     => my_followers_path,
      :following     => my_following_index_path,
      :logout        => logout_path,
      :settings      => my_settings_path
    }
    
    if options[:simple]
      links.delete(:logout)
      links.delete(:settings)
    end
    
    menu_items(links)
  end
  
  #These nav methods need to be refactored! 
  def user_top_navegation
    ul_list_to('links', 'current', my_nav_links)
  end

  #These nav methods need to be refactored!
  def user_navigation
    return unless ['accounts',
                   'dashboards',
                   'activities',
                   'followers',
                   'followees',
                   'badges',
                   'subscriptions',
                   'playlists',
                   'reviews',
                   'users'].include? params[:controller]

    # HACK for Playlist Create page
    return if params[:controller] == 'playlists' && (params[:action] == 'create' || params[:action] == 'edit')

    # HACK for Registration page
    return if params[:controller] == 'users' && params[:action] == 'new'
    # HACK for User create
    return if params[:controller] == 'users' && params[:action] == 'create'

    
    links = if profile_account and current_user and profile_account == current_user
      my_nav_links(:simple => true)
    else
      user_nav_links
    end

    html_links = []
    links.each do |link|
      css_class = ""
      css_class << " active" if (request.request_uri == link[:url] or params[:controller] == link[:menu].to_s)
      css_class << " last"   if links.last == link
      html_links << link_to(link[:label], link[:url], :class => css_class)
    end
    
    content_tag(:div, html_links.join("\n"), :class => 'top_nav w_spacer upriv_page')
  end
  
  #These nav methods need to be refactored!
  def ul_list_to(ul_class, active_class, nav_links)
    items = []
    nav_links.each do |item|
      link_classes = ""
      li_classes = ""
      link_classes = active_class if @dashboard_menu == item[:menu] and (!item[:url].match(/my/) or request.request_uri.match(/\/my\//))
      li_classes << 'last' if nav_links.last == item
      items << content_tag(:li, link_to(item[:label], item[:url], :class => link_classes), :class => li_classes)
    end
    content_tag(:ul, items.join("\n"), :class => ul_class)
  end
end
