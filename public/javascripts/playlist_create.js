// var playlist_valid = false
// var playlist_ids = [];
// var playlist_count = 0;
// var playlist_items_req = 10;
// var playlist_max_artist = 3;
// var playlist_max_album = 3;
var edit_mode = false;
var has_custom_avatar = false;

var _pv = new PlaylistValidations(10, 3, 3, 100, 60);

function PlaylistValidations(items_req, max_artist, max_album, max_items, min_full)
{
	// rules
	this.max_artist = max_artist;
	this.max_album  = max_album;
	this.max_items  = max_items;
	this.min_full   = min_full;
	this.items_req  = items_req;

	// attributes
	this.valid      = false;
	this.item_count = 0;
	this.item_ids   = [];
	this.station_ids   = [];

	// collections
	this.items          = new ValidationList();
	this.artists        = new ValidationList();
	this.albums         = new ValidationList();
	this.artist_errors  = new ValidationList();
	this.album_errors   = new ValidationList();

	// methods
	this.autofill_validate = function()
	{
		this.clear_errors();
		this.valid = true;
		artists = this.artists.hasCountGreater(this.max_artist);
		if (artists.length) this.valid = false;
		if(!this.valid)
		{
			albums = this.albums.hasCountGreater(this.max_album);
			if (albums.length) this.valid = false;
		}

		// Full Play Requirement
		$('#playlist_minimum_tag ul').children().remove();
		if(this.item_count >= this.min_full)
		{
			$('#playlist_minimum_tag').removeClass('info_default_text').addClass('info_success_text');
			$('#tool_top').removeClass('top_round_blk').addClass('top_round_grn');
			$('#tool_content').removeClass('tooltip_content_blk').addClass('tooltip_content_grn');
			$('#tool_bottom').removeClass('bottom_round_blk').addClass('bottom_round_grn');
			$('#tool_arrow').attr('src', '/images/tooltip_arrow_grn.gif');
			$('#playlist_minimum_tag ul').append( full_listen_wrapper(this.min_full, this.item_count, true) );
		}
		else
		{
			$('#playlist_minimum_tag').removeClass('info_success_text').addClass('info_default_text');
			$('#tool_top').removeClass('top_round_grn').addClass('top_round_blk');
			$('#tool_content').removeClass('tooltip_content_grn').addClass('tooltip_content_blk');
			$('#tool_bottom').removeClass('bottom_round_grn').addClass('bottom_round_blk');
			$('#tool_arrow').attr('src', '/images/tooltip_arrow_blk.gif');
			$('#playlist_minimum_tag ul').append( full_listen_wrapper(this.min_full, this.item_count, false) );
		}

	}

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
		artists = this.artists.hasCountGreater(this.max_artist);
		if (artists.length > 0)
		{
			for(i=0;i < artists.length; i++)
			{
				if (!i)
					this.add_artist_error(artists[i], this.artists.getItem(artists[i]));
				else
					this.add_artist_error(artists[i], this.artists.getItem(artists[i]), true);
				this.valid = false;
			}
		}

		// Album Count
		albums = this.albums.hasCountGreater(this.max_album);
		if (albums.length > 0)
		{
			for(var i=0;i < albums.length; i++)
			{
				if (!i)
					this.add_album_error(albums[i], this.albums.getItem(albums[i]));
				else
					this.add_album_error(albums[i], this.albums.getItem(albums[i]), true);
				this.valid = false;
			}
		}

		// Full Play Requirement
		$('#playlist_minimum_tag ul').children().remove();
		if(this.item_count >= this.min_full)
		{
			$('#playlist_minimum_tag').removeClass('info_default_text').addClass('info_success_text');
			$('#tool_top').removeClass('top_round_blk').addClass('top_round_grn');
			$('#tool_content').removeClass('tooltip_content_blk').addClass('tooltip_content_grn');
			$('#tool_bottom').removeClass('bottom_round_blk').addClass('bottom_round_grn');
			$('#tool_arrow').attr('src', '/images/tooltip_arrow_grn.gif');
			$('#playlist_minimum_tag ul').append( full_listen_wrapper(this.min_full, this.item_count, true) );
		}
		else
		{
			$('#playlist_minimum_tag').removeClass('info_success_text').addClass('info_default_text');
			$('#tool_top').removeClass('top_round_grn').addClass('top_round_blk');
			$('#tool_content').removeClass('tooltip_content_grn').addClass('tooltip_content_blk');
			$('#tool_bottom').removeClass('bottom_round_grn').addClass('bottom_round_blk');
			$('#tool_arrow').attr('src', '/images/tooltip_arrow_blk.gif');
			$('#playlist_minimum_tag ul').append( full_listen_wrapper(this.min_full, this.item_count, false) );
		}

      
		if (this.item_count && this.station_ids.length && !this.artist_errors.length && !this.album_errors.length) {
			this.activate_lucky_10();
		} else {
			this.deactivate_lucky_10();
		}

		this.add_errors_to_list();
	}

	this.clear_errors = function() {
		clear_list_errors();
		this.artist_errors.clear();
		this.album_errors.clear();
		$('#artist_error_tag ul').children().remove();
		$('#album_error_tag ul').children().remove();
	}

	this.add_artist_error = function(artist, songs, suppress) {
		if(suppress)
			add_artist_error(artist);
		else
			add_artist_error(artist, songs);

		i = this.items.getItem(songs[0]);
		text = artist_text_wrapper((this.artist_errors.length + 1), i.artist_name, songs.length, this.max_artist);
		this.artist_errors.setItem(artist,text);
	}

	this.add_album_error = function(album, songs, suppress) {
		if(suppress)
			add_album_error(album);
		else
			add_album_error(album, songs);

		i = this.items.getItem(songs[0]);
		text = album_text_wrapper((this.album_errors.length + 1), i.album_name, songs.length, this.max_album);
		this.album_errors.setItem(album,text);
	}

	this.add_errors_to_list = function() {
		for (var i in this.artist_errors.items) {
			$('#artist_error_tag ul').append(this.artist_errors.getItem(i));
		}

		for (var i in this.album_errors.items) {
			$('#album_error_tag ul').append(this.album_errors.getItem(i));
		}
	}
  
	this.fill_station_ids = function() {
		var _station_ids = [];
		var station = 0;
		$('#playlist_item_list li').each(function(){
			station = parseInt($(this).attr('station'), 10);
			if(station > 0) {
				_station_ids.push(station);
			}
		});
		this.station_ids = _station_ids;
	}
    
	this.add_item = function(song_id, title, artist_id, artist_name, album_id, album_name, image_src, suppress_validation, item_id, station) {
		// Add Song ID to playlist
		this.items.setItem(song_id, new PlaylistItem(song_id, title, artist_id, artist_name, album_id, album_name, image_src, item_id, station));
		this.item_ids.push(song_id);
		this.item_count = this.item_ids.length;
		this.fill_station_ids();
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
		artist_id = i.artist_id;
		album_id = i.album_id;
      
		this.items.removeItem(song_id);
		this.item_ids.remove(song_id);
		this.item_count = this.item_ids.length;
		this.fill_station_ids();
      
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

	this.reorder_items = function() {
		_item_ids = [];
		$('#playlist_item_list li').each(function(){
			_item_ids.push($(this).attr('id'));
		});
		this.item_ids = _item_ids;
	}

	this.activate_lucky_10 = function() {
		$('#autofill_button').show();
		// defaulting to display:none causes display:inline on show(), which is not what we want
		$('#autofill_button').css('display', 'inline-block');
		$('#lucky_10_desc').show();
		$('#autofill_button_ques').show();
	}
	this.deactivate_lucky_10 = function() {
		$('#autofill_button').hide();
		$('#lucky_10_desc').hide();
		$('#autofill_button_ques').hide();
	}
}

function PlaylistItem(song_id, song, artist_id, artist_name, album_id, album_name, image_src, item_id, station)
{
	//attributes
	this.item_id = item_id;
	this.song_id = song_id;
	this.song = song;
  
	this.artist_id = artist_id;
	this.artist_name = artist_name;
  
	this.album_id = album_id;
	this.album_name = album_name;
  
	this.image_src = image_src;

	this.station = station;
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
		var results = [];
		for (var i in this.items) {
			if (this.items[i].length > num)
				results.push(i);
		}
		return results;
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
		//this.items.splice(in_key, 1);
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
		//this.items.splice(i, 1);
		}

		this.length = 0;
	}
}


function autofill_add_item(item, index) {
	if(!_pv.contains(item.id) && (_pv.item_count < _pv.max_items)) {
		_pv.add_item(item.id, item.title, item.artist_id, item.artist_name, item.album_id, item.album_name, item.image_src, true, 0, item.station);
		_pv.autofill_validate();
		if(!_pv.valid){
			_pv.remove_item(item.id);
			station_items.splice(index, 1);
			return false
		} else {
			li = '<li id="'+item.id+'" artist_id="'+item.artist_id+'" album_id="'+item.album_id+'" item_id="'+ item.item_id+'" station="'+ item.station+'">'
			+ '<img alt="'+item.id+'" class="icon avatar small" src="'+item.image_src+'" />'
			+ '<div class="text">'
			+ '<big><b>'+unescape(item.title)+'</b></big><br/>'
			+ '<b>album:</b> '+unescape(item.album_name)+'<br/>'
			+ '<b>by:</b> '+unescape(item.artist_name)+''
			+ '</div>'
			+ '<br class="clearer" />'
			+ '<a href="#" onclick="remove_item('+item.id+'); return false;"><img src="/images/close_grey.gif" class="close_x" alt="" /></a>'
			+ '</li>';

			$('#playlist_item_list').append(li);
			update_ui();
		}
	} else {
		station_items.splice(index, 1);
		return false;
	}
	
	return true;
}

function add_item(id, title, artist_id, artist_name, album_id, album_name, image_src, suppress_validation, item_id, station)
{
	if(!_pv.contains(id) && (_pv.item_count < _pv.max_items))
	{
		li = '<li id="'+id+'" artist_id="'+artist_id+'" album_id="'+album_id+'" item_id="'+ item_id+'" station="'+ station+'">'
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
		_pv.add_item(id, title, artist_id, artist_name, album_id, album_name, image_src, suppress_validation, item_id, station);
		update_ui();
    
		if(!suppress_validation)
		{
			save_playlist_state();
			setTimeout(function(){
				$('#search_result_' + id).remove();
			}, 500);
		}
	}
}

function save_playlist_state()
{
	if(!edit_mode)
	{
		jQuery.get('/playlist/save_state?playlist_ids=' + _pv.item_ids, function(data) {});
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
    
		save_playlist_state();
	}
}

function artist_text_wrapper(num, name, item_count, max_artist)
{
	// This can be overriden to include translations
	text = '<li>'
	+ '<span class="number red">' + num + '</span> '
	+ 'You have'
	+ ' <b class="red">' + item_count + '</b> '
	+ 'songs from'
	+ ' <b class="red">' + name + '</b>, '
	+ 'please remove 1 from mix.'
	+ '</li>';
	return text;
}

function album_text_wrapper(num, name, item_count, max_album)
{
	// This can be overriden to include translations
	text = '<li>'
	+ '<span class="number red">' + num + '</span> '
	+ 'You have'
	+ ' <b class="red">' + item_count + '</b> '
	+ 'songs from the album'
	+ ' <b class="red">' + name + '</b>, '
	+ 'please remove 1 from mix.'
	+ '</li>';
	return text;
}

function full_listen_wrapper(max_songs, items, full)
{
	if(full)
	{
		text = "<li>"
	+ "<b>Congratulations!</b> You can now listen to your playlist in full!"
	+ "</li>";
	}
	else
	{
		text = "<li>"
		+ "You need"
		+ "<b class='red'> " + (Number(max_songs) - Number(items) ) + " </b>"
		+ "more songs to be able to listen to your "
		+ "playlist reaches " + max_songs + " songs, "
		+ "this tab will turn green. <br /> <br />"
		+ "<b>TIP:</b> Use the <b class='green'>\"Lucky 10\"</b> button to help "
		+ "add songs to your playlist!"
		+ "</li>";
	}
	return text;
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

function add_artist_error(artist_id, songs)
{
	$('#artist_error_tag').addClass("info_text");
	if(songs)
	{
		for(var s=0; s < songs.length; s++)
		{
			$('#' + songs[s]).addClass("selected_item");
		}
	}
}

function add_album_error(album_id, songs)
{
	$('#album_error_tag').addClass("info_text");
	if(songs)
	{
		for(var s=0; s < songs.length; s++)
		{
			$('#' + songs[s]).addClass("selected_item");
		}
	}
}

function update_ui()
{
	$('#track_count').html(_pv.item_count);
	$('#remaining_track_count').html(_pv.get_remaining());
	toggle_playlist_box();
}

var previous_artist = 0;
var refreshing = false;
function refresh_similar_artists(id)
{
	current_artist = parseInt(id, 10);
	if(!isNaN(current_artist) && current_artist != previous_artist && !refreshing){
		refreshing = true;
		$.ajax({
			url: '/playlist/recommended_artists/' + id,
			type: "GET",
			data: null,
			success: function(r){
				refreshing = false;
				previous_artist = id;
				$("#playlist_recommended_artists_container").fadeOut(function(){
					$(this).html(r).fadeIn();
				});
			},
			error: function(r){
				refreshing = false; 
				alert('Error!')
			}
		});
	}
}

function StationItem(id, title, artist_id, artist_name, album_id, album_name, image_src, suppress_validation, item_id, station) {
	this.id = parseInt(id, 10);
	this.title = title;
	this.artist_id = parseInt(artist_id, 10);
	this.artist_name = artist_name;
	this.album_id = parseInt(album_id, 10);
	this.album_name = album_name;
	this.image_src = image_src;
	this.suppress_validation = suppress_validation;
	this.item_id = parseInt(item_id, 10);
	this.station = parseInt(station, 10);
}

var current_station = 0;
var lucky_size = 10;
var autofill_fetching = false;
var previous_stations = new Array();
var station_items = new Array();

function get_station_items() {
	if(_pv.items.length) {
		var station_id = 0;
		var item = null;
		for(var i=0; i < _pv.item_ids.length; i++){
			item = _pv.items.getItem(_pv.item_ids[i]);
			if (item){
				station_id = parseInt(item.station, 10);
				if(station_id > 0 && !station_used(station_id)){
					current_station = station_id;
					break;
				}				
			}
		}
		if(!isNaN(current_station) && current_station > 0){
			autofill_fetching = true;
			$.ajax({
				url: '/playlist/autofill/' + current_station + '.xml',
				type: "GET",
				data: null,
				success: function(xml){
					autofill_fetching = false;
					station_items = new Array();
					if(!$(xml).find('song').length){
						previous_stations[previous_stations.length] = current_station;
						// no results.  get some more.
						get_station_items();
					}
					$(xml).find('song').each(function(){
						station_items[station_items.length] = new StationItem( $(this).find('idsong').text()
							,$(this).find('title').text()
							,$(this).find('idband').text()
							,$(this).find('band').text()
							,$(this).find('album_id').text()
							,$(this).find('album').text()
							//http://assets.cyloop.com/storage?fileName=/.elhood.com-2/usr/33785/image/thumbnail/093624590125.sml.jpg
							,$(this).find('fotofile').text().replace('/storage/', 'http://assets.cyloop.com/')
							,true
							,0
							,$(this).find('station_id').text() );
					});
					add_autofill_items();
					previous_stations[previous_stations.length] = current_station;
					current_station = 0;
					$('img#autofill_loading').fadeOut('fast');
					$('div#lucky_10_desc').fadeIn('fast');
				},
				error: function(r){
					autofill_fetching = false; 
					alert('Error!')
				}
			});
		}		
	}
}

function autofill() {
	if(_pv.item_count < _pv.max_items) {
		jQuery('div#lucky_10_desc').fadeOut('fast', function(){
			jQuery('img#autofill_loading').fadeIn('fast', function(){
				if(station_items.length < 1) {
					get_station_items();
				} else if(!autofill_fetching){
					// This is a timing bug just waiting to happen.
					// You hit the button (again) before get_station_items() flags autofill_fetching = true
					add_autofill_items();
					jQuery('img#autofill_loading').fadeOut('fast');
					jQuery('div#lucky_10_desc').fadeIn('fast');
				}
			});
		});		
	}
}

function clean_station_items(){
	for(var i=0; i < station_items.length; i++){
		if(_pv.contains(station_items[i].id)) {
			station_items.splice(i, 1);
		}
	}
} 

function add_autofill_items(){
	//var fill = ( (_pv.item_count >= (_pv.max_count - lucky_size))? (_pv.max_count - _pv.item_count) : lucky_size) ;
	clean_station_items();
	var fill_count = 0;
	var item = 0;
	while(fill_count < lucky_size && station_items[fill_count] && _pv.item_count < _pv.max_items) {
		if(station_items.length > lucky_size && station_items.length < (lucky_size * 2)){ 
			get_station_items();
			break;
		}
		
		if(station_items[fill_count]) {
			if(autofill_add_item(station_items[fill_count])){
				station_items.splice(fill_count, 1);
				fill_count++;
			}
		}
	}
	save_playlist_state();
} 

function station_used(id) {
	var in_array = false;
	for(var i=0; i < previous_stations.length; i++) {
		if(previous_stations[i] == id) {
			in_array = true;
			break;
		}
	}
	return in_array;
}


function toggle_playlist_box()
{
	if(_pv.item_count > 0)
	{
		$('#empty_playlist').hide();
		$('#populated_playlist').show();
		$('#save_button').show();
	}
	else
	{
		$('#populated_playlist').hide();
		$('#empty_playlist').show();
		$('#save_button').hide();
	}
}

function open_save_popup() {
	$('#save_button span span').prepend('<img class="btn_red_loading" src="/images/red_loading.gif"/>');
	if(_pv.valid) {
		if(edit_mode) {
			form = $('#update_playlist_form');
			form.find("input[name='item_ids']").attr("value", _pv.item_ids);
			$.ajax({
				url: '/playlist/edit/' + $('#playlist_item_list').attr('playlist_id'),
				type: "POST",
				data: form.serialize(),
				success: function(r) {
					if(!has_custom_avatar) {
						update_playlist_avatar('#update_layer_avatar', $('#' + _pv.item_ids[0]).find('img').attr('src').replace(/image\/thumbnail/i, "image/hi-thumbnail"));
					}
					$.popup({
						div: '#edit_conf_popup'
					});
					$('#save_button span span .btn_red_loading').remove();
				},
				error: function(r){
					alert('Error!')
					}
			});
		} else {
			if(!has_custom_avatar) {
				$('#save_layer_avatar').attr('src', $('#' + _pv.item_ids[0]).find('img').attr('src').replace(/image\/thumbnail/i, "image/hi-thumbnail"));
			}
			$.popup({
				div: '#save_mix_popup'
			});
		}
	} else {
		$.popup({
			div: '#unable_popup'
		});
	}
}

function submit_save_form() {
	var form = $('.save_playlist_form:visible');
  
	if(_pv.valid) {
		var name = form.find("input[name='name']");
		if(name.val() != "") {
			var button = $('.red_loading');
			button.empty().prepend('<img class="btn_red_loading" src="/images/red_loading.gif"/>' + button.attr('loading_message'));

			form.find("input[name='item_ids']").attr("value", _pv.item_ids);
			setTimeout(function(){
				form.submit();
			}, 500);
		} else {
			name.parent().addClass('error_field');
			name.keyup(function(e) {
				e.preventDefault();
				$(this).parent().removeClass('error_field');
			});
		}
	} else {
		$(document).trigger("close.facebox");
		toggle_playlist_box();
	}

}

function image_path(id, artist_id)
{
	return "http://assets.cyloop.com/storage?fileName=/.elhood.com-2/usr/"+artist_id+"/image/thumbnail/"+id+".sml.jpg";
}

function remove_search_result(id)
{
//thisObj = $('#search_result_' + id);
//setTimeout(function(thisObj){ thisObj.remove(); }, 500);
}

function get_song_list(id, scope, page, order_by, order_dir, artist_id)
{
	$('#playlist_search_query').val('');
	hideCreateBox();
	if (typeof(page)=="undefined"){ 
		page = 1
	}
	if (typeof(order_by)=="undefined"){ 
		page = 1
	}
	if (isNaN(parseInt(id, 10)) && typeof(id)=="string"){ 
		q = "term=" + id
		+ "&scope=" + scope
		+ "&page=" + ( (page > 0)? page : 1)
		+ ( (order_by == '')? "" : "&order_by=" + order_by + "&order_dir=" + ( typeof(order_dir)=='' ? "" : order_dir ) );
	} else {		
		q = "item_id=" + id
		+ "&scope=" + scope
		+ "&page=" + ( (page > 0)? page : 1)
		+ ( (order_by == '')? "" : "&order_by=" + order_by + "&order_dir=" + ( typeof(order_dir)=='' ? "" : order_dir ) );
	}
	
	show_loading_image();
  
	jQuery.get('/playlist/create?' + q, function(data) {
		jQuery('#search_results_container').html(data);
	});

	if(typeof(artist_id) == 'number'){
		refresh_similar_artists(artist_id);
	}
}

function do_song_list_sort(t, id, scope, order_by, page)
{
	if (typeof(page)=="undefined"){ 
		page = 1
	}
	q = "item_id=" + id + "&scope=" + scope + "&page=" + page;
	if(order_by)
	{
		has_asc = $(t).hasClass('sort_asc');
		$(t).parent().children().removeClass('sort_asc');
		$(t).parent().children().removeClass('sort_desc');
    
		if( has_asc )
			$(t).addClass('sort_desc');
		else
			$(t).addClass('sort_asc');
      
		order_dir = has_asc ? "DESC" : "ASC";
		q += "&order_by=" + order_by + "&order_dir=" + order_dir;
	}
    
	//show_loading_image();
	jQuery('#search_results_container').fadeTo('fast',0.5);
  
	jQuery.get('/playlist/create?' + q, function(data) {
		jQuery('#search_results_container').fadeTo('fast', 1.0);
		jQuery('#search_results_container').html(data);
	});
}

function do_search_list_sort(t, term, scope, order_by, page)
{
	if (typeof(page)=="undefined"){ 
		page = 1
	}
	q = "term=" + term + "&scope=" + scope + "&page=" + page;
	if(order_by)
	{
		has_asc = $(t).hasClass('sort_asc');
		$(t).parent().children().removeClass('sort_asc');
		$(t).parent().children().removeClass('sort_desc');
    
		if( has_asc )
			$(t).addClass('sort_desc');
		else
			$(t).addClass('sort_asc');
      
		order_dir = has_asc ? "DESC" : "ASC";
		q += "&order_by=" + order_by + "&order_dir=" + order_dir;
	}
    
	//show_loading_image();
	jQuery('#search_results_container').fadeTo('fast',0.5);
  
	jQuery.get('/playlist/create?' + q, function(data) {
		jQuery('#search_results_container').fadeTo('fast', 1.0);
		jQuery('#search_results_container').html(data);
	});
}

function get_search_results(term,scope)
{
	hideCreateBox();
	q = "term=" + term + "&scope=" + scope;
	show_loading_image();
	jQuery.get('/playlist/create?' + q, function(data) {
		jQuery('#search_results_container').html(data);
	});
}

function show_loading_image()
{
	img = '<div style="height: 22px">&nbsp;</div><div class="empty_results_box"><img src="/images/loading_large.gif"/></div>';
	jQuery('#search_results_container').html(img);
}

function init_draggable()
{
	liveDraggable(".draggable_item", {
		scroll: false,
		snap: true,
		helper: 'clone',
		appendTo: 'body',
		connectToSortable: true,
		cursorAt: {
			left: 100
		}
	});
  
	$(".dotted_box").droppable({
		accept: ".draggable_item",
		hoverClass: "dragging",
		drop: function(event, ui) {
			$(ui.draggable).find("div.large_bnt a").click();
		//refresh_similar_artists($(ui.draggable).attr('artist_id'));
		}
	});
}

function liveDraggable(selector, options){
	jQuery(selector).live("mouseover",function(){
		if (!jQuery(this).data("init")) {
			jQuery(this).data("init", true);
			jQuery(this).draggable(options);
		}
	});
}

$(function() {
	//init_draggable();
	});

function save_playlist_image_preview() {
	field = $('.playlist_avatar:visible');
	image = $('.save_layer_avatar:visible');
	image_name = $('.uploaded_image_name').last();
	full_path = ('file://'+ field.val()).replace(/\\/, '/'); //Fix Windows Paths
	image.attr('src', full_path);
	file_path = field.val();
	shortName = file_path.match(/[^\/\\]+$/);
	image.attr('src', '/images/upload_image_placeholder.gif');
	image_name.show();
	image_name.html(shortName[shortName.length-1]);
	has_custom_avatar = true;
}

function playlist_image_preview() {
	$('#update_layer_avatar_container').fadeOut('slow', function(){
		$("#update_layer_avatar").attr('src', '/images/upload_image_placeholder.gif');
		$('#update_layer_loading').show();
		$(this).fadeIn('slow', function(){
			$('#update_avatar_form').submit();
			$("#remove_playlist_avatar").fadeIn('slow');
		});
	}); 
	/*  field = $('#playlist_avatar');
  image = $('#update_layer_avatar');
  image_name = $('#uploaded_image_name');
  // path = 'file://'+ field;
  // path = path.replace(/\\/, '/'); // Fix Windows paths
  // image.attr('src', path);
  file_path = field.val();
  shortName = file_path.match(/[^\/\\]+$/);
  image.attr('src', '/images/upload_image_placeholder.gif');
  image_name.show();
  image_name.html(shortName[shortName.length-1]);
*/	has_custom_avatar = true;
}

function update_playlist_avatar(selector, avatar_path) {
	$('#update_layer_avatar_container').fadeOut('slow', function(){
		$('#update_layer_loading').hide();
		$(selector).attr('src', avatar_path);
		$(this).fadeIn('slow');
	});
/*	$(selector).fadeOut('fast', function(){
		$(this).attr('src', avatar_path);
	});
*/}

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

var hideCreateBox = function(){
	/*  restoreInput(content_msg, this); setTimeout(function() {$('.create_box').hide();}, 300); */
	$('.create_box').hide();
	restoreInput(content_msg, this);
}
