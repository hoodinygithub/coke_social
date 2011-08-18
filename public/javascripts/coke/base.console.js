Base.Console = {

  get_song_list: function(id, scope, page, order_by, order_dir, artist_id) {
    if (typeof(page) == "undefined") page = 1;
    if (typeof(order_by) == "undefined") page = 1;
    q = (isNaN(parseInt(id, 10)) && typeof(id) == "string") ? ("term=" + id) : ("item_id=" + id);
    q += "&scope=" + scope
      + "&page=" + (page > 0 ? page : 1)
      + ( (order_by == '') ? "" : "&order_by=" + order_by + "&order_dir=" + ( typeof(order_dir) == "" ? "" : order_dir ) );

    // Fade out content. Make request.  Fade In.
    $('.center-content').fadeOut('slow', function() {
      $('.center-content').empty();
      Base.Util.XHR('/playlist/get_songs?' + q, 'text', function(data) {
        $('.center-content').html(data.responseText).fadeIn('slow');
      });
    });
  }

}
