ActionController::Routing::Routes.draw do |map|
  map.root  :controller => 'pages', :action => 'home'
  map.resources :valid_tags
  map.home "/home", :controller => "pages", :action => 'home'
  map.login  'login',  :controller => 'sessions', :action => 'new'
  map.logout 'logout', :controller => 'sessions', :action => 'destroy'  
  map.resource :session    

  # Ads - OpenX
  map.messenger_ads '/messenger_ads', :controller => 'ads', :action => 'show', :position => 'messenger', :iframe => 1, :no_padding_and_margin => 1
  map.cyloop_ads '/cyloop/ads', :controller => 'ads', :action => 'show'

  map.messenger_analytics 'messenger_analytics', :controller => 'messenger_radio', :action => 'analytics'
  map.radio_analytics 'radio_analytics', :controller => 'radio', :action => 'analytics'
  map.fitter_happier 'fitter_happier', :controller => 'fitter_happier'
  map.site_check 'fitter_happier/site_check', :controller => 'fitter_happier', :action => "site_check"
  map.site_and_database_check 'fitter_happier/site_and_database_check', :controller => 'fitter_happier' , :action => "site_and_database_check"
  map.process_with_silence 'fitter_happier/process_with_silence', :controller => 'fitter_happier', :action => "process_with_silence"

  map.home_recommendations_callback '/home.js', :controller => 'pages', :action => 'home', :format => 'js'
  map.home_flash_callback '/flash.js', :controller => 'pages', :action => 'flash_callback', :format => 'js'
  map.header_state_callback '/header.js', :controller => 'pages', :action => 'header_callback', :format => 'js'

  map.resources :users,
                :only => [ :new, :create ],
                :member => { :resend_confirmation_email => :get },
                :collection => { :errors_on => :get, :msn_registration_redirect => :get,
                :msn_login_redirect => :get,
                :follow => :post, :unfollow => :post, :approve => :post, :deny => :post,
                :block => :post, :unblock => :post }

  map.resources :registration_layers, :collection => {
     :follow_artist   => :any,
     :follow_user     => :any,
     :add_song        => :any,
     :radio_add_song  => :any,
     :add_mixer       => :any,
     :max_song        => :any,
     :max_radio       => :any,
     :create_playlist => :any,
     :review_playlist => :any
  }

  map.signup 'signup', :controller => 'users', :action => 'new'
  map.forgot 'forgot', :controller => 'users', :action => 'forgot'
  map.reset 'reset/:reset_code', :controller => 'users', :action => 'reset'
  map.confirmation 'users/confirm/:code', :controller => 'users', :action => 'confirm'
  map.share_with_friend 'share/share_with_friend/:media.:format', :controller => 'share', :action => 'share_with_friend'
  map.share 'share/:media/:id.:format', :controller => 'share', :action => 'show'
  map.share_mix 'email_share_mix/:id.:format', :controller => 'share', :action => 'email_share_mix'

  map.x45b 'x45b', :controller => 'application', :action => 'x45b'
  map.x46b 'x46b', :controller => 'pages', :action => 'x46b'

  map.resources :artists, :only => [ :index ], :member => {:recent_listeners => :get, :similar_artists => :get}
  map.artist_list 'artists/list/:q', :controller => 'artists', :action => 'list'

  map.resources :players, :only => :show

  map.resource :search
  #map.friendly_empty_search '/search', :controller => 'searches', :action => 'index'
  #map.friendly_empty_search_with_page '/search/empty/:mkt/:scope/:page', :controller => 'searches', :action => 'show'
  map.content_local_search '/search/content_local/:scope/:q', :controller => 'searches', :action => 'content', :local => true, :requirements => { :q => /.*/ }
  map.content_search '/search/content/:scope/:q', :controller => 'searches', :action => 'content', :requirements => { :q => /.*/ }
  map.main_search '/search/:scope/:q', :controller => 'searches', :action => 'show', :requirements => { :q => /.*/ }
  map.empty_search '/search/:scope', :controller => 'searches', :action => 'show'

  #map.friendly_search_with_page '/search/:scope/:q/', :controller => 'searches', :action => 'show'
  #map.autocomplete_search '/search/auto/:scope/:q', :controller => 'searches', :action => 'autocomplete'

  map.resources :stations, :collection => {:top => :get, :top_station_html => :get}
  map.delete_station_confirmation '/stations/:id/delete_confirmation', :controller => 'stations', :action => 'delete_confirmation'
  map.delete_station '/stations/:id/delete', :controller => 'stations', :action => 'delete'

  map.resource :activity
  map.resource :artist_recommendations
  map.resource :demographics, :member => {:cities => :get}

  map.resources :album_buylinks, :only => :show
  map.resources :song_buylinks, :only => :show
  map.resources :sites_stations, :only => [:index, :show]

  map.resources :reviews, :member => { :confirm_remove => :get,
                                       :duplicate_warning => :get,
                                       :show => :get
                                     }

  map.about 'support/about_cyloop', :controller => 'pages', :action => 'about'
  map.about_coke 'support/about_coca-cola', :controller => 'pages', :action => 'about_coke'
  map.terms_and_conditions 'support/terms_and_conditions', :controller => 'pages', :action => 'terms_and_conditions'
  map.privacy_policy 'support/privacy_policy', :controller => 'pages', :action => 'privacy_policy'
  map.safety_tips 'support/safety_tips', :controller => 'pages', :action => 'safety_tips'
  map.faq 'support/faq', :controller => 'pages', :action => 'faq'
  map.feedback 'support/feedback', :controller => 'pages', :action => 'feedback'
  map.contact 'support/contact', :controller => 'pages', :action => 'contact'
  map.contact_us 'support/contact_us', :controller => 'pages', :action => 'contact_us', :collection => [:only_form]
  #map.contest 'support/bases_del_concurso', :controller => 'pages', :action => 'bases_del_concurso'
  #map.send_mail 'support/contact/send_mail', :controller => 'pages', :action => 'send_mail'
  map.banner_ads 'pages/banner_ads', :controller => 'pages', :action => 'banner'
  map.block_alert 'support/block_alert', :controller => 'pages', :action => 'block_alert'
  map.profile_not_found ':profile/profile_not_found', :controller => 'pages', :action => 'profile_not_found'
  map.profile_not_available ':profile/profile_not_available', :controller => 'pages', :action => 'profile_not_available'
  map.sample_flag_desc 'support/sample_flag_desc', :controller => 'pages', :action => 'sample_flag_desc'
  map.playlist_not_found ':profile/playlist_not_found', :controller => 'pages', :action => 'playlist_not_found'  
  map.downloads "downloads", :controller => "pages", :action => "downloads"

#  unless RAILS_ENV =~ /production/
  map.with_options(:controller => 'radio') do |url|
    url.radio 'playlists', :action => 'index'
    url.search_radio 'playlists/search.:format', :action => 'search'
    url.artist_info 'playlists/info/:playlist_id/:artist_id', :action => 'artist_info'
    url.station_info 'playlists/info/:station_id', :action => 'station_info'
    url.radio_artist_info 'radio/info/:playlist_id/:artist_id', :action => 'artist_info'
  end

  map.playlists_widget 'playlists/widget', :controller => 'playlists', :action => 'widget'
  map.social_playlist  'playlists/:id.:format', :controller => 'playlists', :action => 'show'

#  end

  # map.namespace :discover do |discover|
  #   discover.resources :artists, :only => [:index, :show]
  #   discover.resources :songs, :only => [:index, :show]
  #   discover.resources :stations, :only => [:index, :show]
  # end
  #map.discover 'discover', :controller => 'discover', :action => 'index'

  # support for in-browser translation in non-production environments
  map.with_options(:path_prefix => 'admin') do |admin|
    Translate::Routes.translation_ui(admin) if RAILS_ENV != "production"
  end

  map.with_options(:controller => 'activities') do |url|
    url.listen_activity 'activity/activity/:type/:song_id', :action => 'song'
    url.get_activity 'activity/activity/:type', :action => 'get_activity'
    url.push_activity 'activity/update/:type', :action => 'update'
    url.get_latest    'activity/latest', :action => 'latest'
    url.get_load_activities    'activity/load_activities', :action => 'load_activities'
    url.get_latest_tweet 'activity/latest_tweet', :action => 'latest_tweet'
  end

  # map.messenger_player '/messengerplayer', :controller => 'messenger_player/player', :action => 'index'
  # map.connect '/messenger_player', :controller => 'messenger_player/player', :action => 'index'
  # map.connect '/messenger_player/player/stats.:format', :controller => 'messenger_player/player', :action => 'stats'
  # map.messenger_player_sign_in '/messenger_player/msn_sign_in', :controller => 'messenger_player/player', :action => 'msn_sign_in'
  # map.namespace :messenger_player do |player|
  #   player.resources :stations
  #   player.resources :translations
  #   player.resources :users, :collection => { :status => :get }
  # end

  map.with_options(:path_prefix => 'messenger_player') do |player|
    player.messenger '/', :controller => 'pages', :action => 'messenger_home'
    player.messenger_home '/home', :controller => 'pages', :action => 'messenger_home'
    player.mixes '/mixes', :controller => 'playlists', :action => 'messenger_mixes'
    player.djs '/djs', :controller => 'pages', :action => 'messenger_djs'
    player.djs_details '/dj_mix_details/:id', :controller => 'playlists', :action => 'messenger_dj_mix_details'
    player.my_mixes '/my_mixes', :controller => 'playlists', :action => 'messenger_my_mixes'
    player.messenger_search '/search', :controller => 'searches', :action => 'messenger_searchresults'
    player.messenger_search_emotions '/search_emotions/:q', :controller => 'searches', :action => 'messenger_search_emotion_results'
    player.max_skips '/max_skips', :controller => 'messenger_player/player', :action => 'max_skips'
    player.alert_layer '/alert_layer/:alert_type', :controller => 'messenger_player/layers', :action => 'alert_layer'
    player.copy_mix_layer '/copy_mix_layer/:id', :controller => 'messenger_player/layers', :action => 'messenger_copy'
    player.friends '/my_friends', :controller => 'playlists', :action => 'messenger_my_friends'
  end

  map.resources :campaigns, :member => {:activate => :post, :deactivate => :post}
  
  map.playlist_create '/playlist/create', :controller => 'playlists', :action => 'create'
  map.playlist_edit '/playlist/edit/:id', :controller => 'playlists', :action => 'edit'
  map.playlist_recommended_artists '/playlist/recommended_artists/:artist_id', :controller => 'playlists', :action => 'recommended_artists'
  map.playlist_save_state '/playlist/save_state', :controller => 'playlists', :action => 'save_state'
  map.playlist_clear_state '/playlist/clear_state', :controller => 'playlists', :action => 'clear_state'
  map.playlist_comment '/playlist/comment/:id', :controller => 'playlists', :action => 'comment'
  map.playlist_avatar_update '/playlist/avatar_update/:id', :controller => 'playlists', :action => 'avatar_update'
  map.playlist_avatar_delete '/playlist/avatar_delete/:id', :controller => 'playlists', :action => 'avatar_delete'
  map.playlist_auto_fill '/playlist/autofill/:abstract_station_id.:format', :controller => 'playlists', :action => 'autofill'
  
  map.playlist_reviews         '/playlist/:playlist_id/reviews/list', :controller => 'reviews', :action => 'list'
  map.playlist_reviews_items   '/playlist/:playlist_id/reviews/items', :controller => 'reviews', :action => 'items'

  map.resources :playlists, :has_many => [:reviews]
  map.list_badges '/badges-dj', :controller => 'badges', :action => 'list'
  map.index_of_music '/index-music', :controller => 'site_genres', :action => 'list'
  profile_routes = lambda do |profile|
    profile.resources :comments
    profile.resources :follow_requests
    profile.resources :badges
    map.with_options(:controller => 'badges') do |url|
      url.badges_set_notified '/:slug/badges/set_notified', :action => 'set_notified'
    end
    profile.resources :playlists, :member => {:delete_confirmation => :get, :copy => :get, :duplicate => :post,:messenger_copy => :get  }
    profile.resources :playlist_items,:member => {:delete_confirmation => :get}, :only => [:new, :create]
    profile.resources :playlists do |playlist|
      playlist.resources :items, :controller => 'playlist_items', :only => [:show, :update, :destroy]
    end
    profile.queue_my_station '/stations/:station_id/queue', :controller => 'user_stations', :action => "queue"
    profile.resources :albums, :controller => 'albums', :only => [:index, :show]

    map.with_options(:controller => 'albums') do |url|
      url.queue_song ':slug/albums/:id/:song_id', :action => 'show'
    end

    profile.resources :stations, :controller => 'user_stations'

    profile.resources :biography, :only => :index
    profile.resources :following, :controller => 'followees'
    profile.resources :followers
    profile.resources :activities, :only => :index

    profile.resources :subscriptions
    profile.resources :reviews

    profile.resources :charts, :only => :index
    #profile.charts 'charts', :controller => 'charts', :action => 'index'
    profile.namespace :charts do |charts|
      charts.resources :songs, :only => :index
      charts.resources :artists, :only => :index
      charts.resources :albums, :only => :index
    end
  end
  
  map.namespace :my do |me|
    me.with_options :namespace => '' do |my|
      my.root :controller => 'pages', :action => 'redirect_home'
      map.with_options(:controller => 'badges') do |url|
        url.my_badges_set_notified '/my/badges/set_notified', :action => 'set_notified'
      end
      profile_routes.call(my)
      my.resource :dashboard, :only => :show

      my.resources :blocks, :only => [:create]
      my.resource :cancellation, :controller => :users, :only => [:destroy, :feedback] do |cancellation|
        cancellation.confirm 'confirm', :controller => 'users', :action => 'confirm_cancellation'
        cancellation.feedback 'feedback', :controller => 'users', :action => 'feedback'
      end
      my.resource :settings, :controller => :users, :only => [:show, :edit, :update], :collection => [:remove_avatar]
      my.resource :customizations, :collection => { :restore_defaults => :get, :remove_background_image => :get }, :path_prefix => 'my/settings'
    end
  end
  
  map.msn_refresh '/msn/refresh', :controller => 'msn/refresh', :action => 'index'
  map.msn_channel '/msn/refresh/channel', :controller => 'msn/refresh', :action => 'channel'

  map.resources :messages, :only => [:index, :new, :create], :path_prefix => 'chat'
  map.justin_tv_chat '/chat/:id/justin_tv', :controller => 'chats', :action => 'justin_tv'
  map.namespace :admin do |admin|
    admin.resources :chats, :member => {:messages => :any, :confirm_remove => :any}
    admin.resources :valid_tags, :member => {:restore => :any}
    admin.resources :messages, :only => [:approve, :unapprove, :next, :back, :more, :more_interviewee], :member => {:approve => :any, :unapprove =>:any, :next =>:any, :back =>:any, :more =>:any, :more_interviewee=>:any}
    admin.moderator 'moderator/:id',  :controller => 'messages', :action => 'moderator'
    admin.interviewee 'interviewee/:id', :controller => 'messages', :action => 'interviewee'
  end

  # Need to avoid that auto width from button_to helper
  map.special_followee_update '/my/following/:id/update/:skip_auto_width', :controller => 'followees', :action => 'update'
  map.special_followee_destroy '/my/following/:id/destroy/:skip_auto_width', :controller => 'followees', :action => 'destroy'
  map.followee_destroy '/my/following/:id/destroy', :controller => 'followees', :action => 'destroy'

  # Mapping javascript locale file
  map.javascript_locale '/utils/locale.js', :controller => :javascripts, :action => :locale

  # Widget
  map.widget 'widget/:station_id', :controller => 'popups'
  #map.resources :popups, :collection => {:widget => :any}
  
  # Keep slug routes at the bottom
  map.user ':slug', :controller => 'accounts', :action => 'show'
  map.user_without_slug ':id', :controller => 'accounts', :action => 'show'
  map.namespace :user do |u|
    u.with_options :namespace => '', :path_prefix => ':slug', &profile_routes
  end

  map.artist ':slug', :controller => 'accounts', :action => 'show'
  map.account_rss ':slug.:format', :controller => 'accounts', :action => 'show'

  map.namespace :artist do |a|
    a.with_options :namespace => '', :path_prefix => ':slug' do |artist|
      profile_routes.call(artist)
      artist.resources :songs, :member => {:queue => :post}, :has_many => :playlist_items
    end
  end

  map.connect ':controller/:action.:format'
end
