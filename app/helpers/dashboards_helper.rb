module DashboardsHelper
  def user_nav_links
    links = {
      :home     => user_path,
      :stations => user_stations_path,
      :activities => activities_path,
      :followers  => followers_path,
      :following  => following_index_path
    }    
    
    [{:menu => :home,          :label => "#{t('profile.navigation.home')}",       :url => links[:home]      },
     {:menu => :stations,      :label => "#{t('profile.navigation.stations')}",   :url => links[:stations]  },
     {:menu => :activity,      :label => "#{t('profile.navigation.activity')}",   :url => links[:activities]},
     {:menu => :followers,     :label => "#{t('profile.navigation.followers')}",  :url => links[:followers] },
     {:menu => :following,     :label => "#{t('profile.navigation.following')}",  :url => links[:following] }]
  end
  
  def my_nav_links
    links = {
      :home          => my_dashboard_path,
      :playlists     => '#',
      :badges        => '#',
      :reviews       => '#',
      :subscriptions => '#',
      :activities    => my_activities_path,
      :followers     => my_followers_path,
      :following     => my_following_index_path,
      :logout        => logout_path,
      :settings      => my_settings_path
    }

    [{:menu => :home,          :label => "#{t('profile.navigation.home')}",             :url => links[:home]},
     {:menu => :playlists,     :label => "Playlists",                                   :url => links[:stations]},
     {:menu => :badges,        :label => "Badges",                                      :url => links[:badges]},
     {:menu => :reviews,       :label => "Reviews",                                     :url => links[:reviews]},
     {:menu => :subscriptions, :label => "Subscription",                                :url => links[:subscriptions]},
     {:menu => :activity,      :label => "#{t('profile.navigation.activity')}",         :url => links[:activities]},
     {:menu => :followers,     :label => "#{t('profile.navigation.followers')}",        :url => links[:followers]},
     {:menu => :following,     :label => "#{t('profile.navigation.following')}",        :url => links[:following]},
     {:menu => :settings,      :label => "#{t('profile.navigation.account_settings')}", :url => links[:settings]},
     {:menu => :logout,        :label => "Logout", :url => links[:logout]}
     ]
  end
  
  def user_top_navegation
    ul_list_to('links', 'current', my_nav_links)
  end

  def user_sidebar_links
    ul_list_to('side_links', 'active', user_nav_links)
  end
  
  def artist_sidebar_links
    ul_list_to('side_links', 'active', artist_nav_links)
  end

  def account_sidebar_links
     ul_list_to('side_links', 'active', my_nav_links)
  end

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
