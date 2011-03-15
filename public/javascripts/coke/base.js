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

  // song slider
  $('.cancion ul').liScroll({travelocity: 0.05});

});


var Base = {};

// Helpers
Base.XHR = function(req, type, func)
{
  $.ajax({
    url: req,
    dataType: type,
    complete: func
  });
};

Base.Station = {

  request: function(req, type, func)
  {
    Base.XHR(req, type, func);
  },

  // Callback
  stationCollection: function(data) {
    var _station = new StationBean(data.responseXML);
    Base.Player.playlist(_station.songs);
  }

};

Base.Player = {

  player: 'coke',

  index: 0,
  
  service: function() {
   return $('#' + this.player + '_player')[0];
  },

  is_playing: function() {
   return this.service.isPlaying;
  },

  streamFinished: function() {
    this.playNext();
  },

  playNext: function() {
    if(this.index < _playlist.length)
    {
      this.service().stream(_playlist[++this.index].songfile);
    }
    else
    {
      this.index = 0;
      this.service().stream(_playlist[0].songfile);
    }
  },

  _playlist: {},
  playlist: function(bean)
  {
    this.index = 0;
    _playlist = bean;
    this.service().stream(_playlist[this.index].songfile);
  }
}

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
        album_id: $(this).find('album_id').text(),
        idpl: $(this).find('idpl').text(),
        idband: $(this).find('idband').text(),
        songfile: $(this).find('songfile').text(),
        album_avatar: $(this).find('fotofile').text(),
        title: $(this).find('title').text(),
        band: $(this).find('band').text(),
        profile: $(this).find('profile').text(),
        rating: $(this).find('rating_total').text()
      });
    });
    return _songs;
  };

  this.songs = this.getSongs(_xmlRoot.find('song'));
}
