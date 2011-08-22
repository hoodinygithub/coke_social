Base.Console = {
  current_artist: 0,
  previous_artist: 0,
  refreshing: false,
  get_song_list: function(id, scope, page, order_by, order_dir, artist_id) {
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
  }

}

$(document).ready(function() {
  $('.rec-artistas li').livequery(function() {
    $(this).mouseover(function() {
      $(this).find('.tip_aviso').css('display', 'block');
    }).mouseout(function() {
      $(this).find('.tip_aviso').css('display', 'none');
    });
  });
});
