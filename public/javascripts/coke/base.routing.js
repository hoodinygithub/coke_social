Base.Routing = {

  route: function(url)
  {
    if (String(url).match(/mixes/) ||
        String(url).match(/home/) ||
        String(url).match(/\//)) this.call['channel'](url);

    else if (String(url).match(/search/)) this.call['search'](url);
    else if (String(url).match(/playlists/)) this.call['playlists'](url);
    else if (String(url).match(/my/)) this.call['dashboard'](url);
    else if (String(url).match(/index-bands/) ||
             String(url).match(/index-music/) ||
             String(url).match(/badges-dj/) ||
             String(url).match(/terms_and_conditions/) ||
             String(url).match(/privacy_policy/)) this.call['consolidated'](url);
    else this.call['default'](url);
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
    default: function(url) {
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
