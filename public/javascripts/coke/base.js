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

  $('a[content_switch_enabled=true]').livequery('click', function() {
    Base.Util.XHR($(this).attr('href'), 'text', Base.UI.contentswp);

    // Class switch if main navigation was clicked.
    // Note. May want to move this out into its own class.
    if ($(this).parent().parent().hasClass('menu_principal'))
    {
      $(this).parent().parent().find('.activo').toggleClass('activo');
      $(this).parent().toggleClass('activo');
    }
    /**************************************************************/
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

var Base = {
	getCurrentSiteUrl: function() {},
	account_settings: {},
	layout: {},
	community: {},
	playlists: {},
	utils: {},
	share: {},
	locale: {}
};

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

    // NEED TO DRY THIS UP!!!
    $('ul.ult_mixes li.sonando, ul.mis_mixes li.sonando, ul.mixes li.sonando, ul.djs li.sonando, ul.amigos li.sonando').toggleClass('sonando');
    $('ul.ult_mixes, ul.mis_mixes, ul.mixes, ul.djs, ul.amigos').find('#' + Base.Station._station.pid).parent().toggleClass('sonando');
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

  alertLayer: function(layer)
  {
    $.alert_layer(layer);
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

      /*****************************************/
      _gaq.push(['_trackPageview', 'goomradio']); // Virtual Pageview
      /*****************************************/
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

  this.pid = _xmlRoot.attr('playlist_id');

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

/*
 * Account settings page
 */
Base.account_settings.highlight_field_with_errors = function() {
  if (typeof(field_with_errors) != 'undefined') {
    for(i=0; i < field_with_errors.length; i++) {
      var field_name = field_with_errors[i][0];
      var error = field_with_errors[i][1];
      var field = $(":input[name*='" + field_name + "']:not(input[type='hidden'])").first();
      Base.account_settings.add_message_on(field, error, 'error');
      if(i==0) {
        Base.account_settings.focus_first_section_with_error(field);
      }
    }
  }
};

Base.account_settings.clear_info_and_errors_on = function(field) {
  rounded_box = field.closest('.grey_round_box');
  rounded_box.removeClass('red_error')
             .removeClass('green_info')
             .nextAll('div.clearer,span.red,span.green').remove();
  rounded_box.children('b').removeClass('white');
  $('big[for="' + field.attr('name') + '"]').remove();
}

Base.account_settings.add_message_on = function(field, message, type) {
  var color = 'red';
  if (type == 'info') { color = 'green' }

  if (field.attr('type') != 'checkbox') {
    var rounded_box = field.closest('.grey_round_box');
    var label = $("label[for='" + field.attr('name') + "']").children('b');
    var box_text = rounded_box.children('b');
    rounded_box.addClass( color + '_' + type);
    label.addClass(color);
    box_text.addClass('white');
    var message_content = $('<div class="clearer" /><span class="' + color + '" style="width:250px;display:block;">' + message + '</span>');
    rounded_box.after(message_content);
  } else {
    var message_content = $('<big class="checkbox_error" for="'+ field.attr('name') + '"><b class="'+ color +'">' + message + '</b><br /></big>');
    field.parents('.form_row').children('.checkbox').prepend(message_content);
  }
}


Base.account_settings.show_validations = function(errorMap, errorList) {
  $.each (errorList, function() {
    field = $(this.element);
    error = this.message;
    Base.account_settings.clear_info_and_errors_on(field);
    Base.account_settings.add_message_on(field, error, 'error');
  });
}

Base.account_settings.focus_first_section_with_error = function(field_error) {
  if (!field_error.closest('div.accordion_box').prev().hasClass('expanded')) {
    $('div.accordion_box').hide().prev().removeClass('expanded');
    field_error.closest('div.accordion_box')
               .slideToggle(200)
               .prev()
               .toggleClass('expanded');
  }
};

Base.account_settings.focus_first_field_with_error_by_label = function() {
  var field_error = $('span.fieldWithErrors input').first();
  $('div.accordion_box').hide().prev().removeClass('expanded');
  field_error.closest('div.accordion_box')
             .slideToggle(200, function() {
               field_error.focus();
             })
             .prev()
             .addClass('expanded');
};


Base.account_settings.add_website = function() {
  var protocol_regex  = new RegExp("(ftp|http|https):\/\/");
  var site_regex = new RegExp("^[A-Za-z]+://[A-Za-z0-9-_]+\\.[A-Za-z0-9-_%&\?\/.=]+$");
  var value = $(this).val();

  Base.account_settings.clear_info_and_errors_on($(this));

  if (!protocol_regex.test(value)) {
    value = "http://" + value;
  }

  if (site_regex.test(value)) {
    value = value.replace(/(ftp|http|https):\/\//, "");
    $('#websites_clearer').before('<div class="website_row">' +
   '<input class="user_website" id="user_websites_" name="user[websites][]" type="hidden" value="' + value + '" />' +
   '<b><big><a href="http://' + value + '">' + value + '</a></big> &nbsp; ' +
   '<a href="#" class="black delete_site">[' + Base.locale.t('account_settings.delete') + ']</a></b><br/></div>');
    $('.delete_site').click(Base.account_settings.delete_website);
    $(this).val('');
  } else {
    Base.account_settings.add_message_on($(this), Base.locale.translate('share.errors.message.invalid_url'), 'error');
  } 
  return false;
};

Base.account_settings.delete_website = function() {
  $(this).closest('.website_row').remove();
  return false;
};

Base.account_settings.update_avatar_upload_info = function() {
  $('#avatar_upload_info').text($(this).val());
};

Base.account_settings.delete_account_submit_as_msn = function() {
  var form = $(this).closest('form');
  var validator = form.validate();
  if (form.valid()) {
    $.popup(function() {
      jQuery.get(Base.currentSiteUrl() + '/my/cancellation/confirm', function(data) {
        jQuery.popup(data);
      });
    });
  } else {
    validator.showErrors();
  }
  return false;
}

Base.account_settings.delete_account_submit_as_cyloop = function() {
  var form = $(this).closest('form');
  var validator = form.validate({ showErrors : Base.account_settings.show_validations});
  if (form.valid()) {
    $.ajax({
      type : "DELETE",
      url  : Base.currentSiteUrl() + "/my/cancellation/confirm",
      data : { delete_info_accepted: "true" },
      success: function(data){
        if (data.errors) {
          validator.showErrors(data.errors);
        } else {
          jQuery.popup(data);
        }
      }
    });
  }
  return false;
}


Base.account_settings.delete_account_confirmation = function() {
  $.ajax({
    type : "DELETE",
    url  : Base.currentSiteUrl() + "/my/cancellation",
    data : { delete_info_accepted: "true" },
    success: function(data){
      delete_account_data = data;
      cancelled_account_email = data.email;
      $.get(Base.currentSiteUrl() + '/my/cancellation/feedback?address='+ cancelled_account_email, function(data) {
        $.popup(data);
      });
      $(document).bind('close.facebox', function() {
        window.location = data.redirect_to;
      });
    }
  });
  return false;
}

Base.account_settings.send_feedback = function() {
  $('#redirect_to').val(delete_account_data.redirect_to);
  var form = $('#feedback_form').closest('form').submit();
}

/*
 * header search
 */



Base.currentSiteUrl = function() {
  return $("body").attr("current_site_url") || "";
}

Base.utils.showPopup = function(url) {
  $.get(url, function(response) {
    if (response.status == 'redirect')
    {
      $.simple_popup(response.html);
    }
    else
    {
      $.popup(response);
    }
  });
};

Base.layout.spin_image = function(type, no_margin) {
  if (typeof(type) == 'undefined' || !type) {
    image_name = 'red_loading.gif';
  } else {
    image_name = type + "_loading.gif";
  }
  $img = jQuery("<img></img>");
  $img.attr('src', Base.currentSiteUrl() + '/images/' + image_name);


  if (typeof(no_margin) == 'undefined' || no_margin) {
    //$img.css({'margin-top':'5px'});
  }

  return $img;
};

Base.playlists.messenger_copy = function(slug, playlist_id) {
  var url = Base.currentSiteUrl() + '/' + slug + '/playlists/' + playlist_id + '/messenger_copy';
  Base.utils.showPopup(url);
};

Base.playlists.duplicate = function(slug, playlist_id) {
  var url = Base.currentSiteUrl() + '/' + slug + '/playlists/' + playlist_id + '/duplicate';
  var params = {};
  params['playlist[name]'] = $("#playlist_name").val();

  $("#duplicate_button").children().children().append(Base.layout.spin_image());

  $.post(url, params, Base.playlists.duplicateCallback);
};

Base.playlists.duplicateCallback = function(response) {
  if (!response.success) {
    field_with_errors = $.parseJSON(response.errors);
    Base.account_settings.highlight_field_with_errors();
  } else {
//    $(document).trigger('close.facebox');
	$.alert_layer.close();
	 var my_mixes_url = Base.currentSiteUrl() + '/messenger_player/my_mixes' 
	Base.Util.XHR(my_mixes_url, 'text', Base.UI.contentswp);
    return false;
  }
  $("#duplicate_button span  span img").remove();
};

Base.utils.handle_login_required = function(response, url, button_label) {
  if (typeof(response) == 'object') {
    if (typeof(response.status) && response.status == 'redirect') {
      $.simple_popup(function()
      {
        $.get(url, function(response)
        {
          $.simple_popup(response);
          button_label.html(Base.locale.t('actions.follow'));
        });
      });
      return true;
    }
  }
  return false;
};

Base.community.follow = function(user_slug, button, remove_div, layer_path) {
  var params = {'user_slug':user_slug}
  var $button = jQuery(button);
  var old_onclick = $button.attr('onclick');

	$img = jQuery("<img></img>");
  $img.attr('src', Base.currentSiteUrl() + '/images/grey_loading.gif');

  $button_label = $button.children().children();
  $button_label.append($img);

  $button.attr('onclick', "");
  $button.bind('click', function() { return false; });

  jQuery.post(Base.currentSiteUrl() + '/users/follow', params, function(response, status) {
    if (Base.utils.handle_login_required(response, layer_path, $button_label)) {
      $button.unbind('click');
      $button.bind('click', function() {
        Base.community.follow(user_slug, button, remove_div, layer_path);
        return false;
      });
      return;
    }
  
    if (status == 'success') {
      $button_label.html("");
      $button.removeClass("btn_seguir_red");
      if (response.status == 'following') {
        $button_label.html(Base.locale.t('actions.unfollow'));
        $button.addClass("btn_seguir_green");
      } 

      $button.unbind('click');
      $button.bind('click', function() { Base.community.unfollow(user_slug, this, remove_div); return false; });
    }
  });
};

Base.community.unfollow = function(user_slug, button, remove_div) {
  var params = {'user_slug':user_slug}
  var $button = jQuery(button);
  var old_onclick = $button.attr('onclick');

  $button_label = $button.children().children();
  $button_label.html(Base.layout.spin_image());

  $button.attr('onclick', "");
  $button.bind('click', function() { return false; });

  jQuery.post(Base.currentSiteUrl() + '/users/unfollow', params, function(response, status) {
    if (status == 'success') {
        $button.removeClass("btn_seguir_green");
        $button.addClass("btn_seguir_red");
        $button_label.html(Base.locale.t('actions.follow'));
        $button.unbind('click');
        $button.bind('click', function() { Base.community.follow(user_slug, this, remove_div); return false; });
    }
  });
};


Base.community.text_follow = function(user_slug, element, layer_path) {
  var $element = jQuery(element);
  var params = {'user_slug':user_slug}
	$img = jQuery("<img></img>");
  $img.attr('src', Base.currentSiteUrl() + '/images/loading.gif');
	$img.css({'width':'12px','height':'12px','margin-left':'5px'});
  $element.append($img);
	
  jQuery.post(Base.currentSiteUrl() + '/users/follow', params, function(response, status) {
    if (Base.utils.handle_login_required(response, layer_path, null)) {
      //JQuery($element).parent().parent().find('#not_following').hide();
      //jQuery($element).parent().parent().find('#following').show();
			$img.remove();
      return false;
    }
    if (status == 'success') {
      jQuery($element).parent().parent().find('#not_following').hide();
      jQuery($element).parent().parent().find('#following').show();
			$img.remove();
    }
  });
};

Base.community.text_unfollow = function(user_slug, element) {
  var $element = jQuery(element);
  var params = {'user_slug':user_slug}
	$img = jQuery("<img></img>");
  $img.attr('src', Base.currentSiteUrl() + '/images/loading.gif');
	$img.css({'width':'12px','height':'12px','margin-left':'5px'});
  $element.append($img);
  jQuery.post(Base.currentSiteUrl() + '/users/unfollow', params, function(response, status) {
    if (status == 'success') {
      jQuery($element).parent().parent().find('#not_following').show();
      jQuery($element).parent().parent().find('#following').hide();
			$img.remove();
    }
  });
};


Base.share.email_share_mix = function(form_elm, mix_id,user_email){
		var name = $("#email_share_mix_form #name");
		var email = $("#email_share_mix_form #email_address");
		var msg = $("#email_share_mix_form #msg");
		var reg = /^([A-Za-z0-9_\-\.\+])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
		var name_fld = false;
		var email_fld = false;
		var count = 0 ;
		
		if (name.val() == ''){
			 $('#email_share_mix_form #name_label').addClass('error');
			 $('#email_share_mix_form #name_error').text(Base.locale.t('coke_messenger.layers.share_mix_layer.name_blank'));
			 name_fld = false;
			 $('#error').text("");
		}else{
			$('#email_share_mix_form #name_label').removeClass('error');
			$('#email_share_mix_form #name_error').text("");
			name_fld = true;
			$('#error').text("");
		}
		
		if (email.val() == ''){
			$('#email_share_mix_form #email_label').addClass('error');
			$('#email_share_mix_form #email_error').text(Base.locale.t('coke_messenger.layers.share_mix_layer.email_blank')); 
			email_fld = false;
			$('#error').text("");
			count = 1;
		}else 
      {
			str = email.val().split(',');
			for (var i=0;i < str.length ; i++ ){
				 email_str = jQuery.trim(str[i]);
			 if(!reg.test(email_str)){
						count = count+1;
				}
			}
		}		
		
		if (count > 0){
			$('#email_share_mix_form #email_label').addClass('error');
  		$('#email_share_mix_form #email_error').text(Base.locale.t('coke_messenger.layers.share_mix_layer.invalid_email'));
			email_fld = false;
			$('#error').text("");
		}else{
			$('#email_share_mix_form #email_label').removeClass('error');
			$('#email_share_mix_form #email_error').text("");
			email_fld = true;
			$('#error').text("");
		}
			
			
		var params = {'user_email':user_email, 'email':email.val(),'name':name.val(),'msg':msg.val()}
	 if (email_fld  &&	name_fld){
		jQuery.post(Base.currentSiteUrl() + '/email_share_mix/'+mix_id, params, function(response, status) {
		if (response.status == 'success') {
			 $('#error').text("");
       $.alert_layer.close();
      }else if(response.status == 'failed'){
				$('#error').text(Base.locale.t('coke_messenger.layers.share_mix_layer.time_out_error'));
			}
  	});
	 }
}

/*
 * Locales
 */
Base.locale.translate = function(key, params) {
  var translation = Base.locale.content[Base.locale.current][key];

  if (!translation) {
    translation = key + " does not exist";
  }

  // if user pass params like {'count' => 1}
  if (typeof(translation) == 'object') {
    if (typeof(params) == 'object' && typeof(params.count) != 'undefined') {
      if (params.count == 1) {
        translation = translation.one;
      } else {
        translation = translation.other.split('{{count}}').join(params.count);
      }
    }
  }

  return translation;
};

Base.locale.t = function(key, params) {
  return Base.locale.translate(key, params);
};
