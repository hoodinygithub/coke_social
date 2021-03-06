$(document).ready(function() {

  // global tool tip helper
  $('a.tooltip').mouseover(function() {
    $(this).attr('title', '');
    idtip = "#" + $(this).attr('rel');
    left = $(this).position().left;
    ancho = $(idtip).width() / 2;
    
    // MULTITASK Updates
    // left = left - ancho + 8;
    // $(idtip).show().css({'top':29,'left':left});
    left = left - ancho + 8;
    $(idtip).show().css({'top':34,'left':left});

    $(this).addClass('activo');
  }).mouseout(function() {
    $(idtip).hide();
    $(this).removeClass('activo');
  });

  if (app == "multitask")
    $('.volumen .puntero').css('left', 24);
  else
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
    var url = $(this).attr('href').replace(/^.*#/, '');
    $.history.load(url);
    return false;
  });

  $('.artist_box').livequery(function() {
    $(this).hover(function() {
      $(this).find('.hidden').show();
      $(this).find('.visible').hide();
    },
    function() {
      $(this).find('.hidden').hide();
      $(this).find('.visible').show();
    });
  });

 $(document).bind('reveal.facebox', function() {     
    $('#facebox .real_tags').val('');
    $('#selected_tags').val('');
    if ($('#facebox .real_tags').length != 0) {
      $tag_box = new $.TextboxList('#facebox .real_tags', {  });
    }
 });

});

var Base = {
  getCurrentSiteUrl: function() {},
  badges: {},
  account_settings: {},
  layout: {},
  community: {},
  playlists: {},
  stations: {},
  reviews: {},
  activity: {},
  utils: {},
  share: {},
  locale: {},
  header_search: {},
  account: {},
  playlist_search: {},
  rating: {}
};

// Social sharing
Base.Social = {
  Facebook: {
    shareMix: function() {
      FB.login(function(response) {
        if (response.session)
        {
          FB.ui({
            method: "feed",
            name: "Mix: " + Base.Station._station.playlistName,
            link: current_url_site + "/playlists?station_id=" + Base.Station._station.sid,
            //picture: (String(Base.Station._station.playlistAvatar).match(/http/) ? "" : current_url_site) + Base.Station._station.playlistAvatar,
            message: $('.compartir').attr('message')
          });
        }
      });
      return false;
    },
    sharePage: function() {
      FB.login(function(response) {
        if (response.session)
        {
          FB.ui({
            method: "feed",
            name: "CocaCola.fm",
            link: current_url_site,
            //picture: (String(Base.Station._station.playlistAvatar).match(/http/) ? "" : current_url_site) + Base.Station._station.playlistAvatar,
            message: $('.sociales').attr('message')
          });
        }
      });
      return false;
    }
  },
  Orkut: {
    shareMix: function() {
      var b = "http://promote.orkut.com/preview";
      var q = [];
      q.push('nt=orkut.com');
      q.push('du=' + current_url_site + '/playlists?station_id=' + Base.Station._station.sid);
      q.push('tt=' + escape('Mix: ' + Base.Station._station.playlistName));
      q.push('cn=' + escape($('.compartir').attr('message')));
      // Options below does not seem to be working
      // These are optional query parameters available in the GET api
      q.push('uc=' + escape($('.compartir').attr('message')));
      //q.push('tn=' + (String(Base.Station._station.playlistAvatar).match(/http/) ? "" : current_url_site) + Base.Station._station.playlistAvatar);
      window.open(String(b + '?' + q.join('&')), 'orkut', 'width=655,height=400,status=0,toolbar=1,scrollbars=0,menubar=0,location=0');
      return false;
    },
    sharePage: function() {
      var b = "http://promote.orkut.com/preview";
      var q = [];
      q.push('nt=orkut.com');
      q.push('du=' + current_url_site);
      q.push('tt=' + escape('CocaCola.fm'));
      q.push('cn=' + escape($('.sociales').attr('message')));
      // Options below does not seem to be working
      // These are optional query parameters available in the GET api
      q.push('uc=' + escape($('.sociales').attr('message')));
      //q.push('tn=' + (String(Base.Station._station.playlistAvatar).match(/http/) ? "" : current_url_site) + Base.Station._station.playlistAvatar);
      window.open(String(b + '?' + q.join('&')), 'orkut', 'width=655,height=400,status=0,toolbar=1,scrollbars=0,menubar=0,location=0');
      return false;
    }
  },
  Twitter: {
    shareMix: function() {
      var b = "http://twitter.com/share";
      var q = [];
      q.push('url=' + current_url_site + '/playlists?station_id=' + Base.Station._station.sid);
      q.push('text=' + encodeURI($('.compartir').attr('message')));
      window.open(String(b + '?' + q.join('&')), 'twitter', 'width=655,height=343,status=0,toolbar=1,scrollbars=0,menubar=0,location=0');
      return false;
    },
    sharePage: function() {
      var b = "http://twitter.com/share";
      var q = [];
      q.push('url=' + current_url_site);
      q.push('text=' + encodeURI($('.sociales').attr('message')));
      window.open(String(b + '?' + q.join('&')), 'twitter', 'width=655,height=343,status=0,toolbar=1,scrollbars=0,menubar=0,location=0');
      return false;
    }
  }
}

// Helpers
Base.Util = {
  XHR: function(req, type, func, error_func)
  {
    error_func = typeof(error_func) != 'undefined' ? error_func : Base.UI.xhrerror;
    var options = arguments[4];

    // Checks if the request is coming from the artist idx page.
    // suffix _partial to url to load partial document
    if (req.match(/index-bands/)) req = req + "_partial";

    // Allows actions that respond to XHR differently to be overridden
    new_req = req + (req.indexOf('?') != -1 ? "&ajax=1" : "?ajax=1");
    new_req = new_req + (new_req.indexOf('?') != -1 ? ("&app=" + app) : ("?app=" + app));

    $.ajax({
      url: new_req,
      dataType: type,
      complete: function(data) {
        if (typeof options != "undefined" && typeof options.afterComplete != "undefined") options.afterComplete();
        func(data);
      }, 
      error: function(data) {
        if (data.status == "500") document.location = "/500.html";
      }
    });
  },
  
  xhr_call: function(href)
  {
    Base.Util.XHR(href, 'text', Base.UI.contentswp, Base.UI.xhrerror, {});
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

// Ajaxification of search request
Base.Search = {
  toggleScope: function(e)
  {
    var btn = $(e);
    var frm = btn.parent();
    if (!btn.hasClass('activo'))
    {
      frm.find('.activo').toggleClass('activo');
      btn.toggleClass('activo');

      frm.find('#scope').attr('value', btn.attr('scope'));
      if (frm.find('#q').attr('value') != "") this.query(frm);
    }
  },

  query: function(e)
  {
    var form = $(e);
    var data = form.serialize();
    Base.Util.XHR((form.attr('action') + "?" + data), 'text', Base.UI.contentswp, Base.UI.xhrerror);
  }
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
      if (app == "multitask") this.controlUI().find('.titulo_mix').empty();
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
    var tickr = "<ul>";
    if (Base.Player._player == 'coke')
    {
      if (app == "multitask")
      {
        var tm = "<p><a class='link_decor' href='/playlists?station_id=" + Base.Station._station.sid + "' title='" + s.playlistName + "' content_switch_enabled='true'>" + s.playlistName + "</a></p>";
        tm += "<p>por: <a class='link_decor' href='" + Base.Station._station.ownerProfile + "' content_switch_enabled='true'>" + Base.Station._station.ownerName + "</a></p>";
        this.controlUI().find('.titulo_mix').append(tm);
      }
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
          rate += "<span class='llena'></span>";
        else
          rate += "<span class='vacia'></span>";
      }
      this.controlUI().find('a.r_info').attr('href', ('/playlists?station_id=' + Base.Station._station.sid));
      if (app == "multitask")
      {
        //this.controlUI().find('a.r_facebook').unbind('click');
        //this.controlUI().find('a.r_facebook').bind('click', function() { Base.Social.Facebook.share_mix() });
        this.controlUI().find('a.punt_botellas').attr('href', ('/playlists?station_id=' + Base.Station._station.sid));
        this.controlUI().find('a.r_copiar').attr('href', ('/playlists?station_id=' + Base.Station._station.sid + '&cmd=copy'));
        this.controlUI().find('a.r_compartir').attr('href', ('/playlists?station_id=' + Base.Station._station.sid + '&cmd=share'));
      }
      this.controlUI().find('a.punt_botellas').append(rate);
    }
  },

  random: function(b)
  {
    if (b)
    {
      this.controlUI().find('.controles .r_random').addClass('activo').css('cursor', 'default').unbind('click');
    }
    else
    {
      this.controlUI().find('.controles .r_random').removeClass('activo').css('cursor', 'pointer').bind('click', function() {
        Base.Station.random();
      });
    }
  },

  contentswp: function(data)
  {
    if (typeof data == "object")
    {
      if (data.status == "200")
        $('#content').empty().html(data.responseText);
    }
    else if (typeof data == "string")
    {
      $('#content').empty().html(data);
    }
    // Scrolls up to top of page after load showing just header nav
    if ($('.navegacion').offset().top > 180) window.scrollTo(0, 180);
    
    // Sets rating bottles onload
    $('#content input[type=radio].star').rating();
  },
  
  xhrerror: function(data)
  {
    if(data.status == "500")
      $.alert_layer('/messenger_player/alert_layer/error');
    else {
      $.alert_layer(data.responseText);
    }
  },

  _goomint: null,
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
      if (typeof Base.Player.service() != "undefined")
      {
        Base.Player.service().playRadio(4242705);
      }
      else
      {
        this._goomint = setInterval(function() {
          if (!(Base.Player.service() == undefined))
          {
            try 
            {
              Base.Player.service().playRadio(4242705);
              clearInterval(Base.UI._goomint);
            }
            catch(e)
            {
              // console.log('not ready');
            }
          }
        
        }, 500);
      }

      /*****************************************/
      _gaq.push(['_trackPageview', 'goomradio']); // Virtual Pageview
      /*****************************************/
    }
  }

};

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
Base.account_settings.edit = function(p_target) {
  var form = $(p_target).closest('form');
  form.ajaxSubmit({
    type: "POST",
    success: function(response)
    {
      Base.UI.contentswp(response);
    }
  });
  return false;
};

Base.account_settings.highlight_field_with_errors = function(multitask, id, field_object) {
  if (typeof(field_with_errors) != 'undefined') {
    // Clear current error list
    $("#" + id + " ul.error_list").html("");
    
    for(i=0; i < field_with_errors.length; i++) {
      var field_name = field_object ? field_object + '[' + field_with_errors[i][0] + ']' : field_with_errors[i][0];
      var error = field_with_errors[i][1];
      var field = $("#"+id+" :input[name*='" + field_name + "']:not(input[type='hidden'])").first();
      if(multitask) {
        //if ( !error.match(  new RegExp(field_with_errors[i][0],'i')  ) ) { error = (Base.locale.t('basics.' + field_with_errors[i][0]) + " " + error) }
        Base.account_settings.add_multitask_message_on(field, id, error, 'error');
      }
      else
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
    rounded_box.addClass( color + '_' + type);

    var label = $("label[for='" + field.attr('id') + "']").children('b');
    label.addClass(color);

    var box_text = rounded_box.children('b');
    box_text.addClass('white');
    rounded_box.addClass('white');

    var message_content = $('<div class="clearer" /><span class="' + color + '" style="width:250px;display:block;">' + message + '</span>');
    rounded_box.after(message_content);
  } else {
    var message_content = $('<big class="checkbox_error" for="'+ field.attr('name') + '"><b class="'+ color +'">' + message + '</b><br /></big>');
    field.parents('.form_row').children('.checkbox').prepend(message_content);
  }
}

Base.account_settings.add_multitask_message_on = function(field, id, message, type) {
  if (field.attr('type') != 'checkbox') {
    field.parent().children().first().addClass("error");
  } else {
    field.parent().children().first().addClass("error");
  }
  ul = $("#" + id + " ul.error_list")
  ul.append("<li>"+ message +"</li>")
}

Base.account_settings.show_validations = function(errorMap, errorList) {
  $.each (errorList, function() {
    field = $(this.element);
    error = this.message;
    if (error == "This field is required.") error = FIELD_REQUIRED_ERROR;
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
  var validator = form.validate({
    rules:{delete_info_accepted:{required:true}},
    showErrors:Base.account_settings.show_validations
  });
  if (form.valid()) {
    $.ajax({
      type : "DELETE",
      url  : Base.currentSiteUrl() + "/my/cancellation/confirm",
      data : { delete_info_accepted: "true" },
      success: function(data){
        if (data.errors) {
          validator.showErrors(data.errors);
        } else {
          $.popup(data);
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
      $(document).trigger("close.facebox");
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

Base.playlists.multitask_layer_submit = function(id, callback) {
  var form = $('#'+id+' form');
  $.post($(form).attr('action'), $(form).serialize(), callback); 
};

Base.playlists.multitask_layer_clear = function(id) {
  $("#" + id + " ul.error_list").html("");
	$("#" + id + " form label span.error").removeClass("error");
}

Base.playlists.multitask_duplicateCallback = function(response) {
  if (!response.success) {
    field_with_errors = $.parseJSON(response.errors);
    Base.account_settings.highlight_field_with_errors(true, 'sub_copiar', 'copy');
  } else {
    var ancho = $("#sub_home").width();
    $("#sub_copiar").animate({"left":"+="+ancho+"px"});
		$("#sub_home").animate({"left":"+="+ancho+"px"});
		
		Base.playlists.multitask_layer_clear('sub_copiar');
		
    return false;
  }
  //$("#duplicate_button span  span img").remove();
};

Base.playlists.multitask_shareCallback = function(response) {
  if (!response.success) {
    field_with_errors = $.parseJSON(response.errors);
    Base.account_settings.highlight_field_with_errors(true, 'sub_compartir');
  } else {
    var ancho = $("#sub_home").width();
    $("#sub_compartir").animate({"left":"+="+ancho+"px"});
    $("#sub_home").animate({"left":"+="+ancho+"px"});
   
    Base.playlists.multitask_layer_clear('sub_compartir');
   
    return false;
  }
  //$("#duplicate_button span  span img").remove();
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

Base.community.multitask_follow = function(user_slug, button) {
  var params = {'user_slug':user_slug}
  var $button = jQuery(button);

	$img = jQuery("<img></img>");
  $img.attr('src', Base.currentSiteUrl() + '/images/grey_loading.gif');
  $button_label = $button;//.children().children();
  $button_label.append($img);

  $button.attr('onclick', "");
  $button.bind('click', function() { return false; });

  jQuery.post(Base.currentSiteUrl() + '/users/follow', params, function(response, status) {
    // if (Base.utils.handle_login_required(response, layer_path, $button_label)) {
    //   $button.unbind('click');
    //   $button.bind('click', function() {
    //     Base.community.multitask_follow(user_slug, button, remove_div, layer_path);
    //     return false;
    //   });
    //   return;
    // }

    if (status == 'success') {
      $button.html("");
      if (response.status == 'following') {
        $('.follow_button[slug="'+user_slug+'"]').html(Base.locale.t('actions.unfollow').toUpperCase() + '<span class="bg_fin">&nbsp;</span>');
        $('.follow_button[slug="'+user_slug+'"]').addClass("activo");
      } 

      $('.follow_button[slug="'+user_slug+'"]').unbind('click');
      $('.follow_button[slug="'+user_slug+'"]').bind('click', function() { Base.community.multitask_unfollow(user_slug, this); return false; });
    }
  });
};

Base.community.multitask_unfollow = function(user_slug, button) {
  var params = {'user_slug':user_slug}
  var $button = jQuery(button);

	$img = jQuery("<img></img>");
  $img.attr('src', Base.currentSiteUrl() + '/images/grey_loading.gif');
  $button_label = $button;//.children().children();
  $button_label.append($img);

  $button.attr('onclick', "");
  $button.bind('click', function() { return false; });

  jQuery.post(Base.currentSiteUrl() + '/users/unfollow', params, function(response, status) {
    if (status == 'success') {
      $('.follow_button[slug="'+user_slug+'"]').html("");
      $('.follow_button[slug="'+user_slug+'"]').removeClass("activo");
      $('.follow_button[slug="'+user_slug+'"]').html(Base.locale.t('actions.follow').toUpperCase() + '<span class="bg_fin">&nbsp;</span>');

      $('.follow_button[slug="'+user_slug+'"]').unbind('click');
      $('.follow_button[slug="'+user_slug+'"]').bind('click', function() { Base.community.multitask_follow(user_slug, this); return false; });
    }
  });
};


Base.share.email_share_mix = function(form_elm, mix_id,user_email){
  var name = $("#email_share_mix_form #name");
  var email = $("#email_share_mix_form #email_address");
  var msg = $("#email_share_mix_form #msg");
  var reg = /^([A-Za-z0-9_\-\.\+])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
	var embed_code_regex = /(<([\/@!?#]?[^\W_]+)(?:\s|(?:\s(?:[^'">\s]|'[^']*'|"[^"]*")*))*>)|(<\!--[^-]*-->)|(<\%)/;
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
    return false;
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

  if (msg.val() != ''){
		if (embed_code_regex.test(msg.val())) {
			 $('#email_share_mix_form #msg_label').addClass('error');
			 $('#email_share_mix_form #msg_error').text(Base.locale.t('coke_messenger.layers.share_mix_layer.invalid_msg'));
			 $('#error').text("");
			return false;
		}else{
			$('#email_share_mix_form #msg_label').removeClass('error');
    	$('#email_share_mix_form #msg_error').text("");
    	$('#error').text("");
		}
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


/*
 * header search
 */

Base.header_search.getFieldValue =  function(arr, fieldName) {
  for(i=0; i<arr.length; i++) {
    if (arr[i].name == fieldName) {
      return arr[i].value;
    }
  }
};

Base.header_search.buildSearchUrl = function () {
  var form_values = jQuery("#header_search_form").serializeArray();
  var q     = Base.header_search.getFieldValue(form_values,'q');
  var url   = Base.currentSiteUrl() + "/search/all/" + ( q == msg ? "" : q);
  //location.href = url;
  Base.Util.XHR(url, 'text', Base.UI.contentswp, Base.UI.xhrerror, {});
  return false;
};

Base.header_search.dropdown = function() {
  jQuery("#search_query").keyup(function(e) {
      //jQuery('.search_results_ajax').show();
      var keyCode = e.keyCode || window.event.keyCode;
      var form_values = jQuery("#header_search_form").serializeArray();
      var q = Base.header_search.getFieldValue(form_values,'q');
      if(keyCode == 37 || keyCode == 38 || keyCode == 39 || keyCode == 40){
        return;
	    }
      if(keyCode == 13 || keyCode == 27 || q.length <= 1){
        //jQuery('.search_results_ajax').show();
        jQuery('.search_results_ajax').hide();
        jQuery('.search_results_box').hide();
        return;
  	  }
      //jQuery('.search_results_box').show();
      setTimeout(function () {Base.header_search.autocomplete(q)}, 500);
      return true;
    });
};

Base.playlist_search.autocomplete = function(last_value) {
  jQuery('.content_search_results_ajax').css('top', $('.search_playlist_form').position().top + 10).show();
  //var form_values = jQuery("#playlist_search_form").serializeArray();
  //var q = Base.header_search.getFieldValue(form_values,'q');
  var q = jQuery('#playlist_search_query').val();
  if( last_value != q || q == ''){
    jQuery('.content_search_results_ajax').hide();
    return;
  }
  jQuery.get(Base.currentSiteUrl() + '/search/content_local/all/' + q, function(data) {
      jQuery('.create_box').html(data);

      if($.browser.version == '7.0'){
        jQuery('.create_box').css('z-index', 10000).css('position', 'relative').css('top', -10);
      }

      jQuery('.create_box').show();
      jQuery('.content_search_results_ajax').hide();
  });
};

Base.header_search.autocomplete = function(last_value) {
  jQuery('.search_results_ajax').show();
  var form_values = jQuery("#header_search_form").serializeArray();
  var q = Base.header_search.getFieldValue(form_values,'q');
  if( last_value != q || q == ''){
    jQuery('.search_results_ajax').hide();
    return;
  }
  jQuery.get(Base.currentSiteUrl() + '/search/all/' + q + '?results_only=1', function(data) {
      jQuery('.search_results_box').html(data);
      jQuery('.search_results_box').show();
      jQuery('#header_search_form').parent().addClass('activo');
      jQuery('.search_results_ajax').hide();
  });
};

Base.header_search.close = function(msg) {
  jQuery("#search_query").val(msg);
  setTimeout(function() {
    $('.search_results_box').hide();
    $('.search_results_box').html('');
    jQuery('#header_search_form').parent().removeClass('activo');
    jQuery('.search_results_ajax').hide();
  }, 300);
};

// Reviews
Base.reviews.show = function(review) {
  var url = Base.currentSiteUrl() + "/reviews/" + review + "/show";
  $.get(url, function(response) {
    $.popup(response);
    $('input[type=radio].star').rating();
  });
};

Base.reviews.load_playlist_reviews_list = function(container, playlist) {
  var url = Base.currentSiteUrl() + '/playlist/' + playlist + '/reviews/list';

  $.get(url, function(response) {
    container.html(response);
    $('input[type=radio].star').rating();
    Base.reviews.bind_textarea();
    $('.ajax_sorting').click(Base.reviews.remote_sort);
    $('.ajax_pagination a.page').click(Base.reviews.paginate);
  });
};

Base.reviews.getParams = function(review) {
  var params = {};
  if (review) {
    params['comment'] = $.trim($("#network_comment").val());
    params['rating']  = $('input[name=rating_' + review + ']:checked').last().val();
  } else {
    params['comment'] = $.trim($("#network_comment").val());
    params['rating']  = $('input[name=rating]:checked').val();
  }
  return params;
};

Base.reviews.count_chars = function(textarea) {
  var textarea = $(textarea);
  var chars_counter = $('#' + textarea.attr('chars_counter'));

  if (textarea.val().length < 140) {
    chars_counter.css({'color':'#cccccc'});
    chars_counter.html(140 - textarea.val().length);
  } else {
    chars_counter.css({'color':'red'});
    chars_counter.html("0");
    textarea.val( textarea.val().substr(0, 140) );
  }
};

Base.reviews.resetForm = function() {
  $("#network_comment").val('');
  $('input[name=rating]:checked').rating('select', '');
  $('input[type=radio].star').rating();
  $('#' + $("#network_comment").attr('chars_counter')).html(140);
  $('div.network_red_msg').remove();
  $('#network_comment').removeClass('network_red_msg');
  $('#network_comment').next('img').attr("src", Base.currentSiteUrl() + "/images/network_arrow.gif");
  $('.rating_bottles').removeClass('red_round_box2');
};

Base.reviews.showErrors = function(errors, form) {

  var error_class = 'network_red_msg';
  var input_id = '#network_comment';
  var arrow = '.network_arrow';

  if (form.attr('id') != 'post_review') {
    error_class = 'edit_review_red_msg';
    input_id = '#comment_update';
    arrow    = '#comment_update_arrow';
  };

  $('div.' + error_class).remove();
  $(input_id).removeClass(error_class);
  $(input_id).next('img').attr("src", "/images/network_arrow.gif");


  var message_div = $('<div class="'+ error_class + '"></div>');

  $.each(errors, function() {
    if (this[0] == 'comment') {
      message_div.append(this[1] + "<br />");
      $(input_id).parents(".album_textarea").append(message_div);
      $(input_id).addClass(error_class);
      $(arrow).attr("src", Base.currentSiteUrl() + "/images/network_arrow_red.gif");
    } else {
      form.find('.rating_bottles').addClass('red_round_box2');
    }
  });

};

Base.reviews.bind_textarea = function() {
  $("#comment_update,#network_comment").each(function (){
    $(this).focus(function() {
        if ( $("#network_comment").hasClass("requires_auth") )
          Base.utils.showRegistrationLayer( document.location, 'review_playlist' );
      $(this).addClass("network_update_red");
      $(this).next('img').attr("src", Base.currentSiteUrl() + "/images/network_arrow_red.gif");
    });
  });

  $("#comment_update,#network_comment").each(function (){
    $(this).blur(function() {
      $("div.rating_input").removeClass("red_round_box2");
      $(this).removeClass("network_update_red");
      if (!($(this).hasClass('network_red_msg') || $(this).hasClass('edit_review_red_msg'))) {
        $(this).next('img').attr("src", Base.currentSiteUrl() + "/images/network_arrow.gif");
      }
    });
  });
}

Base.reviews.post = function(playlist) {
  $.post(Base.currentSiteUrl() + '/playlists/' + playlist + '/reviews', Base.reviews.getParams(), Base.reviews.postCallback);
};

Base.reviews.postCallback = function(response) {
  if (response.success) {
    $(response.html).prependTo('.playlist_reviews');
    Base.reviews.resetForm();
  } else {
    if (response.errors) {
      Base.reviews.showErrors($.parseJSON(response.errors), $('#post_review'));
    } else {
      Base.utils.showPopup(response.redirect_to);
    }
  }
};

Base.reviews.confirm_remove = function(review) {
  var url = Base.currentSiteUrl() + "/reviews/" + review + "/confirm_remove";
  Base.utils.showPopup(url);
};

Base.reviews.remove = function(review) {
  var params = {};
  params['id'] = review;

  $.ajax({
    type : "DELETE",
    url  : Base.currentSiteUrl() + "/reviews/" + review,
    success: Base.reviews.removeCallback
  });
};

Base.reviews.removeCallback = function(response) {
  $(document).trigger("close.facebox");
  $('#review_'+ response.id).fadeOut();
  $('.reviews_count').html(response.count);
};

Base.reviews.edit = function(review, full) {
  var url = Base.currentSiteUrl() + "/reviews/" + review + "/edit";
  if (full) {
    url = url + "?full=true";
  }
  $.get(url, function(response) {
    $.popup(response);
    $('input[type=radio].star').rating();
    Base.reviews.bind_textarea();
  });
};

Base.reviews.pushUpdate = function(button, id) {
  $(button).hide();
  var params = Base.reviews.getParams(id);
  $.post(Base.currentSiteUrl() + '/playlists/' + id + '/reviews', 
         params, 
         Base.reviews.pushUpdateCallback);
         
  return false;
}
Base.reviews.pushUpdateCallback = function(response) {
 if (response.success) {
    Base.reviews.clearForm();        
    // $('p.no_resultados').remove();   
    $('ul.comments_list').prepend(response.html);
    $("p.n_comentarios strong").html(parseInt($("p.n_comentarios strong").html()) + 1);
 }
 else {
   // show response.errors
   if( response.redirect_to )
     Base.utils.showPopup(response.redirect_to);
  else if( response.errors )
     Base.reviews.showErrors($.parseJSON(response.errors), $("#network_update_form"));
   else
     alert( response.errors );
 }
      
 $('a.compartir_button').show();
}

Base.reviews.update = function(review, full) {
  var params = Base.reviews.getParams(review);
  params['id'] = review;
  if (full) {
    params['full'] = "true";
  };
  $.ajax({
    type : "PUT",
    url  : Base.currentSiteUrl() + "/reviews/" + review,
    data : params,
    success: Base.reviews.updateCallback
  });
};

Base.reviews.updateCallback = function(response) {
  if (response.success) {
    $(document).trigger("close.facebox");
    $('#review_'+ response.id).replaceWith(response.html);
    $('input[type=radio].star').rating();
    //observe .artist_box mouse over
    $('.artist_box').hover(function() {
      $(this).addClass('hover');
    }, function() {
      $(this).removeClass('hover');
    });
  } else {
    Base.reviews.showErrors($.parseJSON(response.errors), $("#update_review"));
  }
};

Base.reviews.overwrite = function(review,playlist) {
  var params = Base.reviews.getParams(playlist);
  params['id'] = review;

  $.ajax({
    type : "PUT",
    url  : Base.currentSiteUrl() + "/reviews/" + review,
    data : params,
    success: Base.reviews.overwriteCallback
  });
};

Base.reviews.overwriteCallback = function(response) {
  if (response.success) {
    $(document).trigger("close.facebox");
    $('#review_'+ response.id).replaceWith(response.html);
    // $('input[type=radio].star').rating();
    // Base.reviews.resetForm();
    Base.reviews.clearForm();
  } else {
    // Base.reviews.showErrors(response.errors);
    alert(response.errors)
  }
};

Base.reviews.clearForm = function() {
  var commentField = $("#network_comment");
      commentField.val("");
  var charsCounter = $("#chars_counter");
      charsCounter.html(140);
      charsCounter.removeClass("error");
}

Base.reviews.remote_sort = function() {
  var sort_link = $(this);
  sort_link.siblings('.active').removeClass('active');
  sort_link.addClass('active');
  sort_link.parents('.sorting').after('<div class="small_loading at_sorting">');

  var sort_data    = sort_link.metadata();
  var ajax_list    = sort_link.parent().siblings('.ajax_list');;
  var current_page = ajax_list.next('.ajax_pagination').children('span.current');

  var params = {}
  params['page']    = current_page.text();
  params['sort_by'] = sort_data.sort_by;

  $.get(sort_data.url, params, function(response) {
    Base.reviews.paginateCallback(response, ajax_list);
  });

  return false;
}

Base.reviews.paginateCallback = function(response, ajax_list, page_link) {
  if (page_link) {
    var current_page = page_link.siblings('span.current');
    current_page.replaceWith('<a href="#" class="page">' + current_page.text()+ '</a>');
    page_link.replaceWith('<span class="page current">' + page_link.text() + '</span>');
  }
  ajax_list.html(response);
  $("div.small_loading").remove();
  $('.ajax_pagination a.page').click(Base.reviews.paginate);
  $('input[type=radio].star').rating();
}

Base.reviews.paginate = function() {
  var page_link = $(this);
  page_link.parents('.ajax_pagination').after('<div class="small_loading">');
  var ajax_list = page_link.parent().prev('.ajax_list');

  var list_data = $(this).parent().metadata();
  var sort_data = ajax_list.siblings('.sorting').children('.active').metadata();

  params = {}
  params['page']    = page_link.text();
  params['sort_by'] = sort_data.sort_by;

  $.get(list_data.url, params, function(response) {
    Base.reviews.paginateCallback(response, ajax_list, page_link);
  });
  return false;
}

Base.playlists.create = function() {
};

Base.playlists.close_button_event_binder = function() {
  jQuery(".artist_box .close_btn").bind('click', function() { Base.playlists.close_button_handler(this); });
};

Base.playlists.close_button_handler = function(object) {
    $button = jQuery(object);
    
    $parent_div = $button.parent();
    $parent_div.html("<img style='margin-top:50px' src='"+Base.currentSiteUrl()+"/images/loading.gif'></img>");
    $parent_div.css({'background':'#cccccc', 'text-align':'center'});

    var new_playlist_id = recommended_playlists_queue.shift();

    if (typeof(new_playlist_id) == 'undefined') {
      $parent_div.html("");
      $parent_div.css({'background':'white', 'text-align':'left'});
      return;
    }

    var params = {'last_box':$parent_div.hasClass('last_box'), 'id':new_playlist_id};
    jQuery.get(Base.currentSiteUrl() + '/playlists/widget', params, function(data) {
      $parent_div.html(data);
      $parent_div.css({'background':'white', 'text-align':'left'});
      Base.playlists.close_button_event_binder();
    });
};

var _activeStream;
var _playing = false;
var _songId;
Base.playlists.playStream = function(obj, media, songId)
{
  var elem = $(obj);
  if(!_playing)
  {
    _activeStream = elem.parent().parent().addClass('selected_row');
    Base.playlists.onStreamStart(_activeStream);
    //elem.find('img').attr('src', Base.currentSiteUrl() + '/images/icon_stop_button.png');
    swf('stream_connect').playSample(media, songId);
    _playing = true;
  }
  else if(songId != _songId)
  {
    //_activeStream.attr('class', 'draggable_item ui-draggable');
    _activeStream.removeClass('selected_row');
    //_activeStream.find('div.song_name img').attr('src', Base.currentSiteUrl() + '/images/icon_play_button.png');
    Base.playlists.onStreamEnd(_activeStream);
    _activeStream = elem.parent().parent().addClass('selected_row');
    Base.playlists.onStreamStart(_activeStream);
    //elem.find('img').attr('src', Base.currentSiteUrl() + '/images/icon_stop_button.png');
    swf('stream_connect').playSample(media, songId);
  }
  else if(_playing && songId == _songId)
  {
    //_activeStream.attr('class', 'draggable_item ui-draggable');
    _activeStream.removeClass('selected_row');
    //_activeStream.find('div.song_name img').attr('src', Base.currentSiteUrl() + '/images/icon_play_button.png');
    Base.playlists.onStreamEnd(_activeStream);
    _activeStream = null;
    _playing = false;
    swf('stream_connect').killSample();
  }
  _songId = songId;
}

Base.playlists.streamComplete = function()
{
  Base.playlists.onStreamEnd(_activeStream);
  //_activeStream.attr('class', 'draggable_item ui-draggable');
  _activeStream.removeClass('selected_row');
  //_activeStream.find('div.song_name img').attr('src', Base.currentSiteUrl() + '/images/icon_play_button.png');
  _activeStream = null;
  _playing = false;
}

Base.playlists.onStreamStart = function(obj)
{
  // Override this as needed
}
Base.playlists.onStreamEnd = function(obj)
{
  // Override this as needed
}
var swf = function(objname)
{
  if(navigator.appName.indexOf("Microsoft") != -1)
    return window[objname];
  else
    return document[objname];
};

Base.playlist_search.buildSearchUrl = function () {
  //var form_values = jQuery("#playlist_search_form").serializeArray();
  //var q     = Base.header_search.getFieldValue(form_values,'q');
  //var url   = "/playlists/create/?term=" + ( q == msg ? "" : q) ;
  //location.href = url;
  return false;
};

// Stations
Base.stations.remove_from_layer = function(station_id, button) {
  $("#station_to_delete").remove();
  $(button).parent().append("<div id='station_to_delete' style='display:none'></div>")
  url = Base.currentSiteUrl() + '/stations/' + station_id + '/delete_confirmation';
  $.get(url, function(data) {
    $.popup(data);
  });
};

Base.stations.remove = function(station_id) {
  $('#delete_loading').show();

  // mixes page
  $li = $("#station_to_delete").closest(".albums_item");
  if ($li.length == 0) {
    // dashboard page
    $li = $("#station_to_delete").closest(".artist_box");
  }

  $.post(Base.currentSiteUrl() + '/stations/' + station_id + '/delete', {'_method':'delete'}, function(response) {
    $(document).trigger('close.facebox');
    if (response == 'destroyed') {
      $li.slideUp();
    }
  });
};

Base.playlists.showTagsLayer = function() {
  $('ul.selected_tags li').remove();
  pre_selected_tags = $('#facebox .real_tags,input.edit_tags').val();
  $("ul.available_tags li").show();
  if ( pre_selected_tags != "") {
    $('#selected_tags').val(pre_selected_tags);
    $.each(pre_selected_tags.split(','), function() {
      $('ul.selected_tags').append('<li><a href="#">' + this + '</a></li>');
      $("ul.available_tags li a:contains('" + this + "')").first().parent().hide();        
      $('ul.selected_tags li a').click(Base.playlists.removeTag);
    });
  }
  if ($('ul.available_tags li a').data('events') == undefined)
    $('ul.available_tags li a').click(Base.playlists.selectTag);
  var left = $(window).width() / 2;
  var top  = getPageScroll()[1] + (getPageHeight() / 10)
  if (!top) {
    top = 60;
  }
  $('#tags_popup').css('z-index', 1000).css('left', left).css('top', top).show();
  $(document).bind('close.facebox', function() { $('#tags_popup').hide(); });
  Base.playlists.updateSelectedTagCount();
}

function getPageScroll() {
  var xScroll, yScroll;
  if (self.pageYOffset) {
   yScroll = self.pageYOffset;
   xScroll = self.pageXOffset;
  } else if (document.documentElement && document.documentElement.scrollTop) {	 // Explorer 6 Strict
    yScroll = document.documentElement.scrollTop;
    xScroll = document.documentElement.scrollLeft;
  } else if (document.content) {// all other Explorers
    yScroll = document.content.scrollTop;
    xScroll = document.content.scrollLeft;
  }
  return new Array(xScroll,yScroll)
}

function getPageHeight() {
var windowHeight
  if (self.innerHeight) {	// all except Explorer
    windowHeight = self.innerHeight;
  } else if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
    windowHeight = document.documentElement.clientHeight;
  } else if (document.content) { // other Explorers
    windowHeight = document.content.clientHeight;
  }
  return windowHeight
}

Base.playlists.updateSelectedTagCount = function() {
  $('#selected_tags_count').text('(' + $('ul.selected_tags li a').length + ')');  
  $('#available_tags_count').text('(' + $('ul.available_tags li:visible a').length + ')');
}

Base.playlists.removeTag = function() {
  var tag = $(this).text();
  $(this).parent().remove();
  $("ul.available_tags li a:contains('" + tag + "')").parent().show();
  $("#selected_tags").val( $("#selected_tags").val().replace(new RegExp('(,)?' + tag),"") );   
  Base.playlists.updateSelectedTagCount();
  return false;
}

Base.playlists.selectTag = function() {
  var tag = $(this).text();
  $('ul.selected_tags').append('<li><a href="#">' + tag + '</a></li>');
  $('ul.selected_tags li a').click(Base.playlists.removeTag);
  $(this).parent().hide();
  Base.playlists.updateSelectedTagCount();
  $('#selected_tags').val( $('#selected_tags').val() + ',' + tag );
  return false;
}

Base.playlists.saveTags = function() { 
  $('.textboxlist-bit-box-deletable').remove();
  $('#facebox .real_tags, input.edit_tags').val(''); 
  $.each($("#selected_tags").val().replace(/^,/,"").split(','), function() {
    if (this.cleanupURL() != "") {
      $tag_box.add(this.cleanupURL());     
    }
  });
  $('#selected_tags').val('');
  $('#tags_popup').hide();
}

Base.playlists.removeAllTags = function() {
  $('ul.selected_tags li').remove();   
  $('ul.available_tags li').show();
  Base.playlists.updateSelectedTagCount();
  $('#selected_tags').val('');
}

String.prototype.cleanupURL = function(regex, sub) {
  var cleanup = this.replace(regex, sub);
  cleanup = cleanup.replace(/&&/g, "&");
  cleanup = cleanup.replace(/\?&/g, "?");
  return cleanup;
}

// Activity
Base.activity.show_more = function(button, slug) {
  $button = $(button);
  $ul = $button.parent();
  $button.remove();
  
  item_count = $ul.children().length
  
  $.get(Base.currentSiteUrl() + "/" + slug + "/activities", {'count':item_count}, function (response) {
    $ul.append(response).fadeIn();
  });
};

Base.activity.count_chars = function() {
  $textarea     = jQuery("#network_comment");
  $chars_counter = jQuery("#chars_counter");

  if ($textarea.val().length < 140) {
    $chars_counter.removeClass("error");
    $chars_counter.html(140 - $textarea.val().length);
  } else {
    $chars_counter.addClass("error");
    $chars_counter.html("0");
    $textarea.val( $textarea.val().substr(0, 140) );
  }
};

Base.activity.pushUpdate = function(button, token) {
  // $(button).hide();
  $('.share_button_container .loading').show();
  $.post(Base.currentSiteUrl() + '/activity/update/status', 
         {'message':$("#network_comment").val(), 'authenticity_token':encodeURIComponent(token)}, 
         Base.activity.pushUpdateCallback);
}

Base.activity.pushUpdateCallback = function(response) {
 var commentField = $("#network_comment");
 if (response.success) {
   commentField.val("");
   var charsCounter = $("#chars_counter");
       charsCounter.html(140);
       charsCounter.removeClass("error");
    
    $('p.no_resultados').remove();   
    $('ul.comments_list').prepend(response.latest)
 }
 else {
   // show response.errors
 }
 
 $('.share_button_container .loading').hide();
 // $('a.compartir_button').show();
}

Base.utils.showRegistrationLayer = function(url, type, accountId) {
  if (url == undefined) {
    url = '/my/dashboard';
  }
  type || (type = '');
  var accountParam;
  if (accountId == undefined) {
    accountParam = "";
  } else {
    accountParam = "&account_id=" + accountId;
  }
  $.get('/registration_layers/' + type + '?return_to=' + url + accountParam, function(response) {
      $.simple_popup(response);
      });
  return false;
};

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

Base.registration = {};
Base.registration.layers = {
removeSomeFaceboxStyles: function() {
                           $('#facebox .body').css("padding", 0);
                           $('#facebox .body').css("background-color", "transparent");
                           $(document).bind("close.facebox", function(){
                               setTimeout(function() {
                                 $('#facebox .body').css("padding", "10px");
                                 $('#facebox .body').css("background-color", "white");
                                 }, 600);
                               });
                         }
};

Base.badges.filter = function() {
  $("p.filter a").unbind('click', Base.badges.filter);
  $("table.coke tbody tr").hide();
  if ( $(this).attr('type') == "All" ) {
    $("table.coke tbody tr").fadeIn();
  } else {
    $("table.coke tbody tr:has(td:contains('" + $(this).attr('type') + "'))").fadeIn();
  }
  var inactive_link = $("p.filter span.selected");
  inactive_link.replaceWith('<a href="#" type="' + inactive_link.attr('type') + '">' + inactive_link.text() + '</a>');
  $(this).replaceWith('<span class="selected" type="' + $(this).attr('type') + '">' + $(this).text() + '</span>');
  $("p.filter a").bind('click', Base.badges.filter);
  return false; 
}

Base.rating.rate = function(t) {
  bottle = $(t);
  rating_control = bottle.parent().parent();
  rateable_id = rating_control.attr('id');
  rateable_type = rating_control.attr('type');
  // console.log(rateable_type + ":" + rateable_id + ":" + bottle.html())
  
  return false;
}

Base.playlists.avatarDelete = function() {
  $.popup({ div: '#avatar_delete_popup' });
}

Base.playlists.avatarDeleteConfirm = function() {
  var url = $("#remove_playlist_avatar a").attr("href");
  $.get(url, Base.playlists.avatarDeleteCallback);
}

Base.playlists.avatarDeleteCallback = function(response) {
  if (response.success) {
    $("#update_layer_avatar_container img").replaceWith(response.avatar);
    $("#remove_playlist_avatar").hide();
    $(document).trigger('close.facebox');
    has_custom_avatar = false;
  }
}
