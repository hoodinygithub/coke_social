$(document).ready(function() {

  // global tool tip helper
  $('a.tooltip').mouseover(function() {
    $(this).attr('title', '');
    idtip = "#" + $(this).attr('rel');
    left = $(this).position().left;
    ancho = $(idtip).width() / 2;
    left = left - ancho + 15;
    $(idtip).show().css({'top':34,'left':left});
    $(this).addClass('activo');
  }).mouseout(function() {
    $(idtip).hide();
    $(this).removeClass('active');
  });

  $('.volumen .puntero').css('left', 19);

  var slider = {};
  slider.ondrag = function(event, ui) 
  {
    Base.Player.service()[SoundEngines.APIMappings[Base.Player._player].vol](Base.Player._player == 'coke' ? (ui.position.left/33) : (ui.position.left/33 * 100));
  }

  $('.volumen .puntero').draggable({
    axis:'x',
    containment:'parent',
    drag:slider.ondrag});

  $('a[content_switch_enabled=true]').bind('click', function() {
    Base.Util.XHR($(this).attr('href'), 'text', Base.UI.contentswp);
    return false;
  });

  Base.Player.player('coke');
  Base.UI.setControlUI(Base.Player._player);
  Base.Player.random(true);
});

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
}

var Base = {};

// Helpers
Base.Util = {
  XHR: function(req, type, func)
  {
    $.ajax({
      url: req,
      dataType: type,
      complete: func
    });
  },

  poller: function(func, interval)
  {
    return setInterval(func, interval);
  },

  time: function(time, duration)
  {
    var c = duration - time;
    var mm = Math.floor(c / 60);
    mm = (mm < 10 ? '0' + String(mm) : String(mm));
    var ss = c % 60;
    ss = (ss < 10 ? '0' + String(ss) : String(ss));
    return mm + ":" + ss;
  },

  log: function(l)
  {
    if (typeof console != "undefined") console.log(l);
  }
}

Base.Station = {

  request: function(req, type, func)
  {
    if (Base.Player._player == 'goom') 
    {
      Base.Player.player('coke');
      Base.UI.setControlUI(Base.Player._player);
    }
    Base.Util.XHR(req, type, func);
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
  }

};

Base.Player = {

  ready: function()
  {
    Base.Station.request(pl[Math.round(Math.random() * (pl.length - 1))], 'xml', Base.Station.stationCollection);
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
      this.service().pauseStream(this.isPlaying());
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
      this.stream(this._playlist[this.index + 1]);
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
    var valid = this.service().stream(song.songfile, 'mp3', Number(song.duration), Number(song.plId));
    if (valid) this.index++;
    /***************************/
  },

  _playlist: {},
  playlist: function(bean)
  {
    this.index = 0;
    this._playlist = bean;
    this.stream(this._playlist[this.index]);
  },

};

Base.UI = {

  _control:'',
  controlUI: function()
  {
    return $('#' + this._control + '_ui');
  },
  setControlUI: function(ctl)
  {
    if (this._control != '') {
      this.controlUI().hide();
    }
    this.switchui(ctl);
    this._control = ctl;
  },

  reset: function()
  {
    this.controlUI().find('.cancion li').empty();
    if (Base.Player._player == 'coke')
    {
      this.controlUI().find('a.punt_botellas').empty();
    }
  },

  render: function()
  {
    this.reset();
    var s = arguments.length > 0 ? arguments[0] : Base.Player._playlist[Base.Player.index];
    if ($('div').hasClass('tickercontainer')) $('.tickercontainer').remove();
    var tickr  = "<ul>";
    if (Base.Player._player == 'coke')
    {
      this.controlUI().find('.caratula img').attr('src', s.albumAvatar);
      tickr += "<li class='nombre_mix'>" + s.playlistName + "</li>";
      tickr += "<li>" + s.title + "</li>";
      tickr += "<li>" + s.band + "</li>";
    }
    else
    {
      if (s.artist) tickr += "<li class='nombre_mix'>" + s.artist + "</li>";
      tickr += "<li>" + s.title + "</li>";
    }
    tickr += "</ul>";
    this.controlUI().find('.mascara').after(tickr);
    this.controlUI().find('.cancion ul').liScroll({travelocity: 0.05});

    if (Base.Player._player == 'coke')
    {
      var rate = "";
      var rating = Number(Math.floor(Base.Station._station.rating));
      for(var r = 0; r < 5; r++)
      {
        if (r < rating)
          rate += "<span class='llena'></span>"
        else
          rate += "<span class='vacia'></span>"
      }
      this.controlUI().find('a.punt_botellas, a.r_info').attr('href', ('/playlists?station_id=' + Base.Station._station.sid));
      this.controlUI().find('a.punt_botellas').append(rate);
    }
  },

  random: function(b)
  {
    if (b)
    {
      this.controlUI().find('.controles .r_random').addClass('active').css('cursor', 'default').unbind('click');
    }
    else
    {
      this.controlUI().find('.controles .r_random').removeClass('active').css('cursor', 'pointer').bind('click', function() {
        Base.Station.random();
      });
    }
  },

  contentswp: function(data)
  {
    $('#content').empty().html(data.responseText);
  },

  switchui: function(ui)
  {
    $('#' + ui + '_ui').show();
    if (ui == 'coke')
    {
      $('.btn_envivo').removeClass('activo');
      $('.btn_envivo').bind('click', function(e) {
        Base.Player.player('goom');
        Base.UI.setControlUI(Base.Player._player);
        if (!Base.UI.controlUI().find('.controles .r_play').hasClass('activo')) 
          Base.UI.controlUI().find('.controles .r_play').addClass('activo');
      });
    }
    else if (ui == 'goom')
    {
      $('.btn_envivo').addClass('activo');
      $('.btn_envivo').unbind('click');
      Base.Player.service().playStream(4242705);
    }
  }

};

// Collection classes
function StationBean(data)
{
  var _xmlRoot = $(data).find('player');
  var _songs = [];

  this.owner = _xmlRoot.attr('owner');

  this.songCount = _xmlRoot.attr('numResults');

  this.rating = _xmlRoot.attr('rating');

  this.sid = _xmlRoot.attr('station_id');

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

/* TEMPORARY PLACEMENT OF JS BLOCK */
var clearInput = function(value, input) {
 if(input.value == value) {
   input.value = '';
 }
}

var restoreInput = function(value, input) {
 if(input.value == '') {
   input.value = value;
 }
}
