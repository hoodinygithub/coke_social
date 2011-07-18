var SoundEngines = {
  APIMappings: {
    coke: {
      vol:'vol',
      kill:'kill',
      isstreaming:'isStreaming'
    },
    goom: {
      vol:'setVolume',
      kill:'stopRadio',
      isstreaming:'isRadioPaused'
    }
  }
};

Base.Station = {

  _initial: true,
  request: function(req, type, func)
  {
    if (!this._initial) Base.Player._init = false;
    if (Base.Player._player == 'goom')
    {
      Base.Player.player('coke');
      Base.UI.setControlUI(Base.Player._player);
    }
    Base.Util.XHR(req, type, func);
    this._initial = false;
  },

  random: function()
  {
    if (Base.Player._player == 'goom') 
    {
      Base.Player.player('coke');
      Base.UI.setControlUI(Base.Player._player);
    }
    Base.Player.random(true);
    this.request(pl[Math.round(Math.random() * (pl.length - 1))], 'xml', Base.Station.stationCollection);
  },

  // Callback
  _station: null,
  stationCollection: function(data)
  {
    Base.Station._station = new StationBean(data.responseXML);
    Base.Player.playlist(Base.Station._station.songs);

    // NEED TO DRY THIS UP!!!
    $('.play').remove();
    $('ul.ult_mixes li.sonando, ul.mis_mixes li.sonando, ul.mixes li.sonando, ul.djs li.sonando, ul.amigos li.sonando, ul.busquedas li.sonando').toggleClass('sonando');
    if (Base.Station._station) $('ul.ult_mixes, ul.mis_mixes, ul.mixes, ul.djs, ul.amigos, ul.busquedas').find('#' + Base.Station._station.pid).parent().toggleClass('sonando').prepend("<span class='play'>Sonando</span>");
  }

};

// Collection classes
function StationBean(data)
{
  var _xmlRoot = $(data).find('player');
  var _songs = [];

  this.owner = _xmlRoot.attr('owner');

  this.ownerName = _xmlRoot.attr('ownerName');

  this.ownerProfile = _xmlRoot.attr('ownerProfile');

  this.songCount = _xmlRoot.attr('numResults');

  this.rating = _xmlRoot.attr('rating');

  this.sid = _xmlRoot.attr('station_id');

  this.pid = _xmlRoot.attr('playlist_id');

  this.playlistName = _xmlRoot.attr('playlist_name');

  this.playlistAvatar = _xmlRoot.attr('playlist_avatar');

  this.getSongs = function(s)
  {
    $(s).each(function() {
      _songs.push({
        id: $(this).find('idsong').text(),
        playlistName: $(this).find('playlist_name').text(),
        albumId: $(this).find('album_id').text(),
        plId: $(this).find('idpl').text(),
        idband: $(this).find('idband').text(),
        songfile: $(this).find('songfile').text(),
        albumAvatar: $(this).find('fotofile').text(),
        title: $(this).find('title').text(),
        band: $(this).find('band').text(),
        profile: $(this).find('profile').text(),
        rating: $(this).find('rating_total').text(),
        duration: $(this).find('duration').text()
      });
    });
    return _songs;
  };

  this.songs = this.getSongs(_xmlRoot.find('song'));
}

Base.Player = {

  _init:true,
  STATE: "NOT_READY",
  ready: function()
  {
    this.STATE = "READY";
    if (pl.length > 0 && this._player == "coke") Base.Station.request(pl[Math.round(Math.random() * (pl.length - 1))], 'xml', Base.Station.stationCollection);
  },

  _player: "",
  player: function(p)
  {
    if (this._player != '')
    {
      if (this._player == 'coke' && this.isPlaying()) this.streaming(false);
      Base.Player.service()[SoundEngines.APIMappings[this._player].kill]();
    }
    this._player = p;
  },

  index: 0,

  _poll: null,

  service: function() 
  {
   return $('#' + this._player + '_engine')[0];
  },

  streaming: function(b) 
  {
    if (b)
    {
      if (this._poll) clearInterval(this._poll);
      this._poll = Base.Util.poller(function(){
        var st = Base.Player.service().time();
        Base.UI.controlUI().find('.tiempo .barra .relleno').css('width', (String((st.time/st.duration) * 100) + '%'));
        Base.UI.controlUI().find('.minuto').html('-' + Base.Util.time(st.time, st.duration));
        Base.UI.controlUI().find('.controles .r_play').addClass('activo');
      }, 500);
    }
    else
    {
      if (this._poll) clearInterval(this._poll);
      Base.UI.controlUI().find('.controles .r_play').removeClass('activo');
    }
  },

  _randomized: false,
  random: function(b)
  {
    Base.UI.random(b);
    this._randomized =  b;
  },

  pause: function()
  {
    if(this.isPlaying()) this.service().pauseStream(true);
  },

  playPause: function()
  {
    if (this._player == 'coke')
    {
    // if (pl.length > 0) 
      if (this._init)
      {
        this.stream(this._playlist[this.index]);
        this._init = false;
      }
      else
      {
        this.service().pauseStream(this.isPlaying());
      }
    }
    else if (this._player == 'goom')
    {
      /*
       * !NOTE add new method just for goom
       * Logic here is a bit strange.
       * Coke checks if player isPlaying to see whether to play/pause
       * Goom checks if player isPaused to figure out the same logic
       * verbiage doesn't really represent it's meaning here
       */
      if (!this.isPlaying())
      {
        this.service().pauseRadio();
        Base.UI.controlUI().find('.controles .r_play').removeClass('activo');
      }
      else
      {
        this.service().resumeRadio();
        Base.UI.controlUI().find('.controles .r_play').addClass('activo');
      }
    }
  },

  isPlaying: function() 
  {
    return this.service()[SoundEngines.APIMappings[Base.Player._player].isstreaming]();
  },

  streamFinished: function() 
  {
    this.next();
  },

  next: function()
  {
    if (this.index < (this._playlist.length - 1))
    {
      this.stream(this._playlist[this.index]);
    }
    else
    {
      //this.index = 0;
      if (this._randomized)
      {
        Base.Station.request(pl[Math.round(Math.random() * (pl.length - 1))], 'xml', Base.Station.stationCollection);
      }
      //else
      //{
      //  this.stream(this._playlist[0]);
      //}
    }
  },

  stream: function(song)
  {
    /* KEEP EYE ON LOGIC BELOW */
    var valid = this.service().stream({id: song.id, url: song.songfile}, 'mp3', Number(song.duration), Number(song.plId));
    if (valid) ++this.index;
    /***************************/

    /*****************************************/
    _gaq.push(['_trackPageview', cFlashVars.player]); // Virtual Pageview
    /*****************************************/
  },

  _playlist: {},
  playlist: function(bean)
  {
    this.index = 0;
    this._playlist = bean;
    this.service().setStation({sid: Base.Station._station.sid, owner: Base.Station._station.owner, songCount: Base.Station._station.songCount});
    if (this._init)
      Base.UI.render(this._playlist[this.index]);
    else
      this.stream(this._playlist[this.index]);
  }

};

$(document).ready(function() {
  Base.Player.player(typeof set_player != "undefined" ? set_player : 'coke');
  Base.UI.setControlUI(Base.Player._player);
  if (typeof set_player != "undefined" && set_player == "goom")
    Base.Player.random(false);
  else
    Base.Player.random(true);

  window.onunload = function() {
    Base.Player.service()[SoundEngines.APIMappings[Base.Player._player].kill]();
  };
});
