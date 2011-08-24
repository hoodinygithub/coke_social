Base.Console = {
  current_artist: 0,
  previous_artist: 0,
  refreshing: false,
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
      if (!isNaN(Base.Console.currentArtist) && Base.Console.currentArtist != Base.Console.previousArtist && !Base.Console.refreshing) {
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
  }

}

$(document).ready(function() {
  // Tool tip binding
  $('.rec-artistas li').livequery(function() {
    $(this).mouseover(function() {
      $(this).find('.tip_aviso').css('display', 'block');
    }).mouseout(function() {
      $(this).find('.tip_aviso').css('display', 'none');
    });
  });

  $('#playlist_search_query').keyup(function(e) {
    var keyCode = e.keyCode || window.event.keyCode;
    var q = $(this).val();
    if (keyCode == 37 || keyCode == 38 || keyCode == 39 || keyCode == 40) return false;
    if (keyCode == 13 || keyCode == 27 || q.length <= 1) {
      $('.mix_columna.izq .boca').fadeOut('fast');
    }
    $('.cont-busquedas.izq').hide();
    setTimeout(function() {Base.Console.autoComplete(q);}, 500);
    return true;
  });
});
