Base.Console = {
  validator: new PlaylistValidator(10, 3, 3, 100, 60),
  current_artist: 0,
  previous_artist: 0,
  refreshing: false,
  elemRef: null,
  get_song_list: function(id, scope, page, order_by, order_dir, artist_id) {
    $('.cont-busquedas.izq').hide();
    if (typeof(page) == "undefined") page = 1;
    if (typeof(order_by) == "undefined") page = 1;
    q = (isNaN(parseInt(id, 10)) && typeof(id) == "string") ? ("term=" + id) : ("item_id=" + id);
    q += "&scope=" + scope
      + "&page=" + (page > 0 ? page : 1)
      + ( (order_by == '') ? "" : "&order_by=" + order_by + "&order_dir=" + ( typeof(order_dir) == "" ? "" : order_dir ) );

    // Fade out content. Make request.  Fade In.
    $('.mix_columna.centro').fadeOut('slow', function() {
      $(this).empty();
      Base.Util.XHR('/playlist/get_songs?' + q, 'text', function(data) {
        $('.mix_columna.centro').html(data.responseText).fadeIn('slow');
        Base.Console.refresh_similar_artists(id);
      });
    });
  },

  refresh_similar_artists: function(id) {
    $('.rec-artistas').fadeOut('slow', function() {
      $(this).empty();
      Base.Console.currentArtist = parseInt(id, 10);
      if (!isNaN(Base.Console.currentArtist) && 
          Base.Console.currentArtist != Base.Console.previousArtist &&
          !Base.Console.refreshing)
      {
        Base.Console.refreshing = true;
        Base.Util.XHR('/playlist/get_similar/' + id, 'text', function(data) {
          $('.rec-artistas').html(data.responseText).fadeIn('slow');
          Base.Console.refreshing = false;
          Base.Console.previousArtist = id;
        });
      }
    });
  },

  autoComplete: function(v) {
    var q = $('#playlist_search_query').val();
    if (v != q || q == '')
    {
      // remove previous content
      return false;
    }
    Base.Util.XHR(Base.currentSiteUrl() + '/search/content_local/all/' + q, 'text', function(data){
      $('.cont-busquedas.izq').html(data.responseText).show();
    });
  },

  addItem: function(iObj) {
    // iObj == Item Object
    if (!this.validator.contains(iObj.songID) && (this.validator.item_count < this.validator.max_items))
    {
      if ($('.boca.inst').is(':visible')) {
        $('.boca.inst').hide();
        $('.maximo').addClass('green');
      }
      if (!$('.personalizar_mix').is(':visible')) $('.personalizar_mix').show();
      var itemElement = "<div id='" + iObj.songID + "' class='def-song'>"
        + "<a href='#' class='flecha_volver' title='arrastrar'>volver</a>"
        + "<img alt='musica' class='avatar large' src='" + iObj.image + "' title='musica'>"
        + "<h5>" + unescape(iObj.songTitle) + "</h5>"
        + "<p>" + unescape(iObj.albumName) + "</p>"
        + "<p>" + unescape(iObj.artistName) + "</p>"
        + "</div>";
       $('.contenedor-derecha').append(itemElement);
       this.validator.add_item(iObj);
       this.removeItemFromSearch(iObj.songID);
    }
  },

  removeItemFromSearch: function(id) {
    Base.Console.elemRef = $('ul#item-' + id);
    setTimeout(function(elem) { Base.Console.elemRef.remove(); }, 500);
  }
};

$(document).ready(function() {
  // Binding: Tool tip
  $('.rec-artistas li').livequery(function() {
    $(this).mouseover(function() {
      $(this).find('.tip_aviso').css('display', 'block');
    }).mouseout(function() {
      $(this).find('.tip_aviso').css('display', 'none');
    });
  });

  // Binding: Search form
  $('#playlist_search_query').livequery('keyup', function(e) {
    var keyCode = e.keyCode || window.event.keyCode;
    var q = $(this).val();
    if (keyCode == 37 || keyCode == 38 || keyCode == 39 || keyCode == 40) return false;
    if (keyCode == 13 || keyCode == 27 || q.length <= 1) {
      $('.mix_columna.izq .boca').fadeOut('fast');
    }
    $('.cont-busquedas.izq').hide();
    setTimeout(function() { Base.Console.autoComplete(q); }, 500);
    return true;
  });

  // Binding: Drag and Drop
  $('.draggable_item').livequery('mouseover', function() {
    if (!$(this).data('init'))
    {
      $(this).data('init', true);
      $(this).draggable({
        scroll:            false,
        helper:            'clone',
        appendTo:          'body',
        connectToSortable: true,
        cursorAt:          { left: 5, top: 10 },
        drag:              function(event, ui) { if (typeof document.getSelection != "undefined" && typeof document.getSelection().collapse != "undefined") document.getSelection().collapse(); }
      });
    }

    $('.contenedor-derecha').droppable({
      accept: '.draggable_item',
      drop: function(event, ui) {
        $(ui.draggable).find("li.fin_list a").click();
      }
    });
  });

});

// Validation Utility: by Sherv
function PlaylistValidator(items_req, max_artist, max_album, max_items, min_full)
{
  // Rules
  this.max_artist = max_artist;
  this.max_album  = max_album;
  this.max_items  = max_items;
  this.min_full   = min_full;
  this.items_req  = items_req;

  // Attributes
  this.valid       = false;
  this.item_count = 0;
  this.item_ids    = [];

  // Collections
  this.items         = new ValidationList();
  this.artists       = new ValidationList();
  this.albums        = new ValidationList();
  this.artist_errors = new ValidationList();
  this.album_errors  = new ValidationList();

  // Methods
  /*
  this.autofill_validate = function() {
    this.clear_errors();
    this.valid = true;

    var artists = this.artists.hasCountGreater(this.max_artist);
    if (artists.length) this.valid = false;
    if (!this.valid)
    {
      var albums = this.albums.hasCountGreater(this.max_album);
      if (albums.length) this.valid = false;
    }
  };
  */

  this.validate = function() {
    this.clear_errors();
    this.valid = true;

    // Song Count
    if (this.item_count < this.items_req)
    {
      add_playlist_errors();
      this.valid = false;
    }

    // Artist Count
    var artists = this.artists.hasCountGreater(this.max_artist);
    if (artists.length > 0)
    {
      for (var i = 0; i < artists.length; i++)
      {
        if (!i)
          this.add_artist_error(artists[i], this.artists.getItem(artists[i]));
        else
          this.add_artist_error(artists[i], this.artists.getItem(artists[i]), true);
        this.valid = false;
      }
    }

    // Album Count
    var albums = this.albums.hasCountGreater(this.max_album);
    if (albums.length > 0)
    {
      for (var i = 0; i < albums.length; i++)
      {
        if (!i)
          this.add_album_error(albums[i], this.albums.getItem(albums[i]));
        else
          this.add_album_error(albums[i], this.albums.getItem(albums[i]), true);
        this.valid = false;
      }
    }

    // Full Play Requirement
    //if (this.item_count >= this.min_full)
    //else

    // Lucky 10

    // Errors
    this.add_errors_to_list();
  };

  this.clear_errors = function() {
    clear_list_errors();
    this.artist_errors.clear();
    this.album_errors.clear();
  };

  this.add_artist_error = function(artist, songs, suppress) {
    if (suppress)
      add_artist_error(artist);
    else
      add_artist_error(artist, songs);

    var i = this.items.getItem(songs[0]);
    var text = "";
    this.artist_errors.setItem(artist, text);
  };

  this.add_album_error = function(album, songs, suppress) {
    if (suppress)
      add_album_error(album);
    else
      add_album_error(album, songs);

    var i = this.items.getItem(songs[0]);
    var text = "";
    this.album_errors.setItem(album, text);
  };

  this.add_errors_to_list = function() {
  };

  this.fill_station_ids = function() {
    var stationIDs = [];
    var station    = 0;
    // Loop
    // stationIDs.push(station);
    this.station_ids = stationIDs;
  };

  this.add_item = function(iObj) {
    // iObj == Item Object
    this.items.setItem(iObj.songID, new PlaylistItem(iObj));
    this.item_ids.push(iObj.songID);
    this.item_count = this.item_ids.length;
    this.fill_station_ids();
    this.add_artist(iObj.artistID, iObj.songID);
    this.add_album(iObj.albumID, iObj.songID);
    if (!iObj.suppressValidation) this.validate();
  };

  this.remove_item = function(song_id) {
    var i = this.items.getItem(song_id);
    artist_id = i.artist_id;
    album_id  = i.album_id;

    this.items.removeItem(song_id);
    this.item_ids.remove(song_id);
    this.item_count = this.item_ids.length;
    this.fill_station_ids();
    this.remove_artist(artist_id, song_id);
    this.remove_album(album_id, song_id);
    this.validate();
  };

  this.add_artist = function(artist_id, song_id) {
    this.artists.pushItem(artist_id, song_id);
  };
  this.remove_artist = function(artist_id, song_id) {
    this.artists.pullItem(artist_id, song_id);
  };

  this.add_album = function(album_id, song_id) {
    this.albums.pushItem(album_id, song_id);
  };
  this.remove_album = function(album_id, song_id) {
    this.albums.pullItem(album_id, song_id);
  };

  this.contains = function(id) {
    return this.items.hasItem(id);
  };

  this.get_remaining = function() {
    return (this.item_count > this.items_req) ? 0 : (this.items_req - this.item_count);
  };

  this.reorder_items = function() {

  };
}

function PlaylistItem(iObj)
{
  // iObj == Item Object
  this.item_id     = iObj.itemID;
  this.song_id     = iObj.songID;
  this.song        = iObj.songTitle;
  this.artist_id   = iObj.artistID;
  this.artist_name = iObj.artistName;
  this.album_id    = iObj.albumID;
  this.album_name  = iObj.albumName;
  this.image_src   = iObj.image;
  this.station     = iObj.stationID;
}

function ValidationList()
{
  this.length = 0;
  this.items  = [];

  for (var i = 0; i < arguments.length; i += 2)
  {
    if (typeof arguments[i + 1] != "undefined")
    {
      this.items[arguments[i]] = arguments[i + 1];
      this.length++;
    }
  }

  this.hasCountGreater = function(n) {
    var results = [];
    for (var i in this.items)
    {
      if (this.items[i].length > n)
        results.push(i);
    }
    return results;
  };

  this.getItemCount = function(k) {
  };

  this.removeItem = function(k) {
    var tmp_previous;
    if (typeof this.items[k] != "undefined")
    {
      this.length--;
      tmp_previous = this.items[k];
      delete this.items[k];
    }
    return tmp_previous;
  };

  this.getItem = function(k) {
    return this.items[k];
  };

  this.pushItem = function(k, v) {
    if (this.hasItem(k))
    {
      var r = this.getItem(k);
      r.push(v);
      this.items[k] = r;
    }
    else
    {
      this.setItem(k, [v]);
    }
  };

  this.pullItem = function(k, v) {
    if(this.hasItem(k))
    {
      var r = this.getItem(k);
      r.remove(in_value);
      this.items[k] = r;
      this.length--;
    }
  };

  this.setItem = function(k, v) {
    var tmp_previous;
    if (typeof v != "undefined")
    {
      if (typeof this.items[k] == "undefined") this.length++;
      else tmp_previous = this.items[k];
      this.items[k] = v;
    }
    return tmp_previous;
  };

  this.hasItem = function(k) {
    return typeof this.items[k] != "undefined";
  };

  this.clear = function() {
    for (var i in this.items)
    {
      delete this.items[i];
    }
    this.length = 0;
  };
}

function add_playlist_errors()
{
  // console.log('add playlist error');
}

function add_artist_error(artistID, songs)
{
  $('.maximo:eq(0)').addClass('red');
  if (songs)
  {
    for (var s = 0; s < songs.length; s++)
    {
      $('#' + songs[s]).addClass('fail');
    }
  }
}

function add_album_error(artistID, songs)
{
  $('.maximo:eq(1)').addClass('red');
  if (songs)
  {
    for (var s = 0; s < songs.length; s++)
    {
      $('#' + songs[s]).addClass('fail');
    }
  }
}

function clear_list_errors()
{
  $('.maximo').removeClass('red');
}
