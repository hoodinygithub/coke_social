Base.Routing = {

  route: function(url)
  {
    if (url == document.location.href.replace(document.location.origin, '')) return true;
    else if (String(url).match(/mixes/) ||
             String(url).match(/home/) ||
             String(url).match(/^\/$/)) this.call['channel'](url);
    else if (String(url).match(/search/)) this.call['search'](url);
    else if (String(url).match(/playlist\/create/) &&
             !logged_in) this.call['playlist_create']();
    else if (String(url).match(/playlists/)) this.call['playlists'](url);
    else if (String(url).match(/my\/settings/)) this.call['pipe']('/my/settings/edit');
    else if (String(url).match(/my/)) this.call['dashboard'](url);
    else if (String(url).match(/index-bands/) ||
             String(url).match(/index-music/) ||
             String(url).match(/badges-dj/) ||
             String(url).match(/terms_and_conditions/) ||
             String(url).match(/privacy_policy/)) this.call['consolidated'](url);
    else if (String(url).match(/comments_top/) ||
             String(url).match(/^\/session$/) ||
             String(url).match(/^\/users$/)) return true;
    else this.call['pipe'](url);
  },

  call: {
    channel: function(url)
    {
      Base.Routing.request(url, Base.UI.contentswp, {afterComplete: function() {
        $('body').attr('id', url == "/" ? "home" : String(url).slice(1));
      }});
    },
    search: function(url)
    {
      Base.Routing.request(url, Base.UI.contentswp, {afterComplete: function() {
        $('body').attr('id', 'busqueda');
      }});
    },
    playlists: function(url)
    {
      Base.Routing.request(url, Base.UI.contentswp, {afterComplete: function() {
        $('body').attr('id', '');
      }});
    },
    playlist_create: function() {
      Base.Routing.request('/', Base.UI.contentswp, {afterComplete: function() {
        Base.utils.showRegistrationLayer('http://cfm.cyloop.com:3000/playlist/create', 'create_playlist');
        $('body').attr('id', "home");
      }});
    },
    dashboard: function(url)
    {
      Base.Routing.request(url, Base.UI.contentswp, {afterComplete: function() {
        $('body').attr('id', 'usuario');
      }});
    },
    consolidated: function(url)
    {
      Base.Routing.request(url, Base.UI.contentswp, {afterComplete: function() {
        $('body').attr('id', 'list');
      }});
    },
    pipe: function(url) {
      Base.Routing.request(url, Base.UI.contentswp);
    }
  },
  request: function(url, callback, options)
  {
    if (Base.UI.contentswp === callback)
    {
      Base.Util.XHR(url, 'text', callback, Base.UI.xhrerror, options);
    }
  }
};

$(document).ready(function() {
    $.history.init(function(url) {
      Base.Routing.route(url != "" ? url : document.location.href.replace(document.location.origin, ''));
    }, {unescape:true});
});
