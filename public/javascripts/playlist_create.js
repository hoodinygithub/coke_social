// var playlist_valid = false
// var playlist_ids = [];
// var playlist_count = 0;
// var playlist_items_req = 10;
// var playlist_max_artist = 3;
// var playlist_max_album = 3;
var edit_playlist = false;

var _pv = new PlaylistValidations(10,3,3);

function PlaylistValidations(items_req, max_artist, max_album)
{
    // rules
    this.max_artist = max_artist;
    this.max_album  = max_album;
    this.items_req  = items_req;
    
    // atributes
    this.valid      = false;
    this.item_count = 0;
    this.item_ids   = [];
    
    
    // collections
    this.items    = new ValidationList();
    this.artists  = new ValidationList();
    this.albums   = new ValidationList();
    this.errors   = new ValidationList();
    
    // methods
    this.validate = function() {
      clear_list_errors();
      this.valid = true;
      
      // Song Count
      if (this.item_count < this.items_req)
      { 
        add_playlist_errors();
        this.valid = false;
      }
      
      // Artist Count
      artist = this.artists.hasCountGreater(this.max_artist);
      if (artist)
      {
        add_artist_errors(artist, this.artists.getItem(artist));
        this.valid = false;
        return;
      }
      
      // Album Count
      album = this.albums.hasCountGreater(this.max_albums);
      if (album)
      {
        add_album_errors(album, this.albums.getItem(album));
        this.valid = false;
        return;
      }

    }
    
    this.add_item = function(song_id, artist_id, album_id, suppress_validation) {
      // Add Song ID to playlist
      this.items.setItem(song_id, [artist_id, album_id]);
      this.item_ids.push(song_id);
      this.item_count = this.item_ids.length;
      
      // Increment Song Artist count
      this.add_artist(artist_id, song_id);
      
      // Increment Song Album count
      this.add_album(album_id, song_id);
      
      if(!suppress_validation)
        this.validate();
    }
    
    this.remove_item = function(song_id) {
      // Remove Song ID from playlist
      i = this.items.getItem(song_id);
      artist_id = i[0];
      album_id = i[1];
      this.items.removeItem(song_id);
      this.item_ids.remove(song_id);
      this.item_count = this.item_ids.length;
      
      // Decrement Song Artist count
      this.remove_artist(artist_id, song_id);
      
      // Decrement Song Album count
      this.remove_album(album_id, song_id);
      
      this.validate();
    }
    
    this.add_artist = function(artist_id, song_id) {
      this.artists.pushItem(artist_id, song_id);
    }
    
    this.add_album = function(album_id, song_id) {
      this.albums.pushItem(album_id, song_id);
    }
    
    this.remove_artist = function(artist_id, song_id) {
      this.artists.pullItem(artist_id, song_id);
    }
    
    this.remove_album = function(album_id, song_id) {
      this.albums.pullItem(album_id, song_id);
    }
    
    this.contains = function(id) {
      return this.items.hasItem(id);
    }
    
    this.get_remaining = function() {
      return (this.item_count > this.items_req) ? 0 : (this.items_req - this.item_count)
    }
}

function ValidationList()
{
	this.length = 0;
	this.items = new Array();
	
	for (var i = 0; i < arguments.length; i += 2) {
		if (typeof(arguments[i + 1]) != 'undefined') {
			this.items[arguments[i]] = arguments[i + 1];
			this.length++;
		}
	}
   
	this.hasCountGreater = function(num) {
	  for (var i in this.items) {
			if (this.items[i].length > num)
			  return i;
		}
		return false;
	}
	
	this.getItemCount = function(in_key) {
    
	}
	
	this.removeItem = function(in_key)
	{
		var tmp_previous;
		if (typeof(this.items[in_key]) != 'undefined') {
			this.length--;
			var tmp_previous = this.items[in_key];
			delete this.items[in_key];
		}
	   
		return tmp_previous;
	}

	this.getItem = function(in_key) {
		return this.items[in_key];
	}

	this.pushItem = function(in_key, in_value)
	{
	  if (this.hasItem(in_key))
	  {
	    r = this.getItem(in_key);
	    r.push(in_value);
	    this.items[in_key] = r;
	  }
	  else
	    this.setItem(in_key, [in_value]);
	}
	
	this.pullItem = function(in_key, in_value)
	{
	  if (this.hasItem(in_key))
	  {
	    r = this.getItem(in_key);
	    r.remove(in_value);
	    this.items[in_key] = r;
	    this.length--;
	  }
	}
	
	this.setItem = function(in_key, in_value)
	{
		var tmp_previous;
		if (typeof(in_value) != 'undefined') {
			if (typeof(this.items[in_key]) == 'undefined') {
				this.length++;
			}
			else {
				tmp_previous = this.items[in_key];
			}

			this.items[in_key] = in_value;
		}
	   
		return tmp_previous;
	}

	this.hasItem = function(in_key)
	{
		return typeof(this.items[in_key]) != 'undefined';
	}

	this.clear = function()
	{
		for (var i in this.items) {
			delete this.items[i];
		}

		this.length = 0;
	}
}


function add_item(id, title, artist_id, artist_name, album_id, album_name, image_src, suppress_validation)
{
  if(!_pv.contains(id))
  {
    li = '<li id="'+id+'" artist_id="'+artist_id+'" album_id="'+album_id+'">'
          + '<img alt="'+id+'" class="icon avatar small" src="'+image_src+'" />'
          + '<div class="text">'
              + '<big><b>'+unescape(title)+'</b></big><br/>'
              + '<b>album:</b> '+unescape(album_name)+'<br/>'
              + '<b>by:</b> '+unescape(artist_name)+''
          + '</div>'
          + '<br class="clearer" />'
          + '<a href="#" onclick="remove_item('+id+'); return false;"><img src="/images/close_grey.gif" class="close_x" alt="" /></a>'
        + '</li>';
        
    $('#playlist_item_list').append(li);
    _pv.add_item(id, artist_id, album_id, suppress_validation);
    update_ui();
  }
}
function validate_items()
{
  _pv.validate();
}

function remove_item(id)
{
  if(_pv.contains(id))
  {
    $('#' + id).remove();
    _pv.remove_item(id);
    update_ui();
  }
}

function clear_list_errors()
{
  $('#artist_error_tag').removeClass("info_text");
  $('#album_error_tag').removeClass("info_text");
  $('#playlist_item_list').children().removeClass('selected_item');
  $('#playlist_error_tag').removeClass("info_text");
  $('#track_count').removeClass("info_text");
}

function add_playlist_errors()
{
  $('#playlist_error_tag').addClass("info_text");
  $('#track_count').addClass("info_text");
}

function add_artist_errors(artist_id, songs)
{
  $('#artist_error_tag').addClass("info_text");
  for(var s=0; s < songs.length; s++)
  {
    $('#' + songs[s]).addClass("selected_item");
  }
}

function add_album_errors(album_id, songs)
{
  $('#album_error_tag').addClass("info_text");
  for(var s=0; s < songs.length; s++)
  {
    $('#' + songs[s]).addClass("selected_item");
  }
}

function update_ui()
{
  $('#track_count').html(_pv.item_count);
  $('#remaining_track_count').html(_pv.get_remaining());
  toggle_playlist_box();
}

function toggle_playlist_box()
{
  if(_pv.item_count > 0)
  {
    $('#empty_playlist').hide();
    $('#populated_playlist').show();
    //$('#autofill_button').show();
    //$('#autofill_button_ques').show();
    $('#save_button').show();
  }
  else
  {
    $('#populated_playlist').hide();
    $('#empty_playlist').show();
    //$('#autofill_button').hide();
    //$('#autofill_button_ques').hide();
    $('#save_button').hide();
  }    
}

function open_save_popup()
{
  if(_pv.valid)
  {
    if(edit_playlist)
    {
      form = $('#update_playlist_form');
      form.find("input[name='item_ids']").attr("value", _pv.item_ids);
      form.submit();
    }
    else
    {
      img_src = $('#' + _pv.item_ids[0]).find('img').attr('src');
      $('#save_layer_avatar').attr('src', img_src.replace(/image\/thumbnail/i, "image/comments"));
      $('#save_mix_popup').fadeIn('fast');
    }
  }
  else
    $('#unable_popup').fadeIn('fast');
}

function submit_save_form()
{
  form = $('#save_playlist_form');
  
  if(_pv.valid)
  {
    name = form.find("input[name='name']").val();
    if(name != "")
    {
      //form.find("input[name='item_ids']").attr("value", playlist_ids);
      form.find("input[name='item_ids']").attr("value", item_ids);
      form.submit();
    }
    else
    {
      $('#save_mix_popup').fadeOut('fast');
      //$('#unable_popup').fadeIn('fast');
    }
  }
  else
  {
    $('#save_mix_popup').fadeOut('fast');
    $('#unable_popup').fadeIn('fast');
    toggle_playlist_box();
  }
}



function image_path(id, artist_id)
{
  return "http://assets.cyloop.com/storage?fileName=/.elhood.com-2/usr/"+artist_id+"/image/thumbnail/"+id+".sml.jpg";
}

function remove_search_result(id)
{
  $('#search_result_' + id).remove();
}

function get_song_list(id,scope)
{
  q = "item_id=" + id + "&scope=" + scope;
  show_loading_image();
  jQuery.get('/playlist/create?' + q, function(data) {
      jQuery('#search_results_container').html(data);
  });
}

function get_search_results(term,scope)
{
  q = "term=" + term + "&scope=" + scope;
  show_loading_image();
  jQuery.get('/playlist/create?' + q, function(data) {
      jQuery('#search_results_container').html(data);
  });
}

function show_loading_image()
{
  img = '<div class="empty_results_box"><img src="/images/loading_large.gif"/></div>';
  jQuery('#search_results_container').html(img);
}



function init_draggable()
{
  // $(".draggable_item").draggable({revert: true, scroll: false, snap: true, helper: 'clone', appendTo: 'body', connectToSortable: true, cursorAt: {left: 100} });
  // $(".dotted_box").droppable({
  //       accept: ".draggable_item",
  //       hoverClass: "dragging",
  //       drop: function(event, ui) {
  //         alert('dropped');
  //         
  //       }
  // });
}

$(function() {
  //init_draggable()
});





Array.prototype.contains = function (element) {
  for (var i = 0; i < this.length; i++) {
    if (this[i] == element) {
      return true;
    }
  }
  return false;
}
Array.prototype.remove = function (element) {
  for (var i = 0; i < this.length; i++) {
    if (this[i] == element) {
      this.splice(i, 1);
      break;
    }
  }
  //return this;
}

