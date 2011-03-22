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
    Base.Player.service().vol(ui.position.left/33);
  }

  $('.volumen .puntero').draggable({
    axis:'x',
    containment:'parent',
    drag:slider.ondrag});

  $('a[content_switch_enabled=true]').bind('click', function() {
    Base.Util.XHR($(this).attr('href'), 'text', Base.UI.contentswp);
    return false;
  });

  //Base.Player.player('coke');
  //Base.UI.setControlUI(Base.Player._player);
  //Base.Player.random(true);
});


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
    Base.Util.XHR(req, type, func);
  },

  // Callback
  stationCollection: function(data) 
  {
    var _station = new StationBean(data.responseXML);
    Base.Player.playlist(_station.songs);
  }

};

Base.Player = {

  ready: function()
  {
    //Base.Station.request(pl[Math.round(Math.random() * (pl.length - 1))], 'xml', Base.Station.stationCollection);
  },

  _player: "",
  player: function(p)
  {
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

  playPause: function()
  {
    this.service().pauseStream(this.isPlaying());
  },

  isPlaying: function() 
  {
   return this.service().isStreaming();
  },

  streamFinished: function() 
  {
    this.next();
  },

  next: function() 
  {
    if(index < (_playlist.length - 1))
    {
      this.stream(_playlist[++index]);
    }
    else
    {
      index = 0;
      if (this._randomized)
      {
        Base.Station.request(pl[Math.round(Math.random() * (pl.length - 1))], 'xml', Base.Station.stationCollection);
      }
      else
      {
        this.stream(_playlist[0]);
      }
    }
  },

  stream: function(song)
  {
    this.service().stream(song.songfile, 'mp3', Number(song.duration));
    Base.UI.reset();
    Base.UI.render(song);
  },

  _playlist: {},
  playlist: function(bean)
  {
    index = 0;
    _playlist = bean;
    this.stream(_playlist[index]);
  }
};

Base.UI = {

  _control:'',
  controlUI: function()
  {
    return $('#' + _control + '_ui');
  },
  setControlUI: function(ctl)
  {
    $('#' + ctl + '_ui').show();
    _control = ctl;
  },

  reset: function()
  {
    this.controlUI().find('.cancion li').empty();
  },

  render: function(s)
  {
    this.controlUI().find('.caratula img').attr('src', s.album_avatar);
    if ($('div').hasClass('tickercontainer')) $('.tickercontainer').remove();
    var tickr  = "<ul>";
        tickr += "<li class='nombre_mix'>" + s.playlist_name + "</li>";
        tickr += "<li>" + s.title + "</li>";
        tickr += "<li>" + s.band + "</li>";
        tickr += "</ul>";
    this.controlUI().find('.mascara').after(tickr);
    $('.cancion ul').liScroll({travelocity: 0.05});
  },

  random: function(b)
  {
    if (b)
      this.controlUI().find('.r_random').addClass('active');
    else
      this.controlUI().find('.controles .r_random').removeClass('active');
  },

  contentswp: function(data)
  {
    $('#content').empty().html(data.responseText);
  }

};

// Collection classes
function StationBean(data)
{
  var _xmlRoot = $(data).find('player');
  var _songs = [];

  this.owner = _xmlRoot.attr('owner');

  this.songCount = _xmlRoot.attr('numResults');

  this.getSongs = function(s)
  {
    $(s).each(function() {
      _songs.push({
        id: $(this).find('idsong').text(),
        playlist_name: $(this).find('playlist_name').text(),
        album_id: $(this).find('album_id').text(),
        idpl: $(this).find('idpl').text(),
        idband: $(this).find('idband').text(),
        songfile: $(this).find('songfile').text(),
        album_avatar: $(this).find('fotofile').text(),
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

/* TEMP LOCATION */
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
