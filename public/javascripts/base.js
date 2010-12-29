var Base = {
  getCurrentSiteUrl: function() {},
  message_fadeout_timeout: 15000,
  listen_icon_timer: null,
  layout: {},
  account_settings: {},
  network: {},
  stations: {},
  header_search: {},
  content_search: {},
  playlist_search: {},
  main_search: {},
  community: {},
  locale: {},
  utils: {},
  registration: {},
  radio: {},
  account: {},
  playlists: {},
  djs: {},
  reviews: {},
  badges: {}
};

Base.currentSiteUrl = function() {
  return $("body").attr("current_site_url") || "";
}

/*
 * Utils
 */
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

Base.utils.resetIndexes = function() {
  if($.browser.msie){
    $('div').each(function(i) {
      if($(this).css('position')!='absolute') $(this).css('zIndex', 1000 - (i * 10));
    });
  }
}

/*
 * Simple validation utility.  I want to refactor this
 */
var validateSubmission = function(form, elem)
{
  $('ul.error').css('display', 'none');

  var errors = [];
  var validate;
  var element_value;

  for(var x = 0; x < elem.length; x++)
  {
    for(var i in elem[x])
    {
      validate = elem[x][i];
      element = form.find('#' + i);
      element_value = form.find('#' + i).attr('value');

      if(validate == 'required')
      {
        if(element_value == '')
        {
          errors.push(error_codes[i + '_blank']);
          element.parent().attr("class", "red_round_box");
        }
        else
        {
          element.parent().attr("class", "grey_round_box");
        }
      }

      if(validate == 'required_email')
      {
        if(element_value == '')
        {
          errors.push(error_codes[i + '_blank']);
          element.parent().attr("class", "red_round_box");
        }
        else if(element_value != '')
        {
          element.parent().attr("class", "grey_round_box");
          var reg = /^([A-Za-z0-9_\-\.\+])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
          if(!reg.test(element_value))
          {
            errors.push(error_codes[i + '_invalid']);
            element.parent().attr("class", "red_round_box");
          }
        }
      }

      if(validate == 'required_multiemail')
      {
        if(element_value == '')
        {
          errors.push(error_codes[i + '_blank']);
          element.parent().attr("class", "red_round_box");
        }
        else if(element_value != '')
        {
          element.parent().attr("class", "grey_round_box");
          var reg = /^([A-Za-z0-9_\-\.\+])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
          var multi = element_value.split(',');
          for(var j = 0; j < multi.length; j++)
          {
            if(!reg.test(multi[j].replace(/^\s*|\s*$/g,'')))
            {
              errors.push(error_codes[i + '_invalid']);
              element.parent().attr("class", "red_round_box");
              break;
            }
          }
        }
      }
    }
  }

  if(errors.length > 0)
  {
    printErrors(errors);
    return false;
  }
  else
  {
    return true;
  }
}

function printErrors(err)
{
  if($('ul.error li').length > 0) $('ul.error').empty();
  $('ul.error').css('display', 'block');
  for(var i = 0; i < err.length; i++)
  {
    $('ul.error').append('<li>' + err[i] + '</li>');
  }
}

$(document).ready(function() {
  $("#facebox a.close_after_click").live("click", function() {
      $(document).trigger("close.facebox");
      return true;
  });

  /*
   * Capture share station submission
   */
  $("#facebox .share_station form").live("submit", function(e) {
      e.preventDefault();
      if(validateSubmission($(this), validations))
      {
        $.ajax({
          url: $(this).attr('action'),
          type: $(this).attr('method'),
          data: $(this).serialize(),
          success: function(r) {$.facebox( r );},
          error: function(r)   {$('#facebox. .share_station .content').html(r.responseText);}
        });
      }
  });
});

var swf = function(objname)
{
  if(navigator.appName.indexOf("Microsoft") != -1)
    return window[objname];
  else
    return document[objname];
};

Base.radio.launchRadio = function(station_id) {
	if(parseInt(station_id, 10) > 0) {
		location.href = Base.currentSiteUrl() + '/radio?station_id=' + station_id;
	}
}
Base.radio.set_station_search_details = function(id, queue, play) {
  $("#create_station_submit").attr('station_id', id);
  $("#create_station_submit").attr('station_queue', queue);
	if(play || typeof(play)=='undefined') { Base.radio.set_station_details(id, queue, play); }
};

Base.radio.set_station_details = function(id, queue, play) {
  regex = /\d+/;
  playlist_id = regex.exec(queue)[0];
  Base.reviews.load_playlist_reviews_list($("#playlist_reviews"), playlist_id);
  $("#station_id").val(id);
  $("#station_queue").val(queue);
	if(play || typeof(play)=='undefined') { Base.radio.play_station(false, false, null, null); }
};

Base.radio.refresh_my_stations = function() {
  $.ajax({
    type: "GET",
    url:  Base.currentSiteUrl()+"/radio/my_stations_list",
    data: {station_id: $("#station_id").val()},
    success: function(result) {
      $("div#my_stations_container").empty();
      $("div#my_stations_container").append(result);
		  $("div#my_stations_list .songs_box ul li a.launch_station").click(function(e){
		  	e.preventDefault();
				var is_station_list_item = $(this).hasClass('launch_station');
				var is_create_station_submit = $(this).attr("id") == "create_station_submit";
				var list;
				var list_play_button;
				if(is_station_list_item) {
					var li = $(this).parentsUntil('li');
					list = this.id.match(/(.*)_list(.*)/)[1];
					list_play_button = li.find('img.list_play_button');
					if(list_play_button) { list_play_button.attr('src', Base.currentSiteUrl()+"/images/grey_loading.gif"); }
				}
				Base.radio.set_station_details($(this).attr('station_id'), $(this).attr('station_queue'), false);
				Base.radio.play_station(is_station_list_item, is_create_station_submit, list, list_play_button)
   		});
  	}
	});
};

Base.radio.play_station = function(from_list, from_create_station, list, list_play_button ) {
	var id =  $("#station_id").val();
	var queue =  $("#station_queue").val();
	var is_owner = $("#owner").val() == 'true';

  $.ajax({
    type: "GET",
    url:  Base.currentSiteUrl()+"/radio/album_detail",
    data: {station_id: id},
    success: function(result) {
			if(from_list) {
				if(list_play_button) { list_play_button.attr('src', Base.currentSiteUrl()+"/images/icon_play_small.gif"); }
				toggleButton(list, 0);
			}
			if(from_create_station) {
				$('#collapse_create_new_station').click();
        $('#create_station_submit').attr('station_id', '').attr('station_queue', '').removeClass('blue_button').addClass('grey_button_big');
        $("input[name='search_station_name']").val("").blur();
			}
      $("div#current_station_info").empty();
      $("div#current_station_info").append(result);
      $("div#current_station_info").append("<br class='clearer' />");
			initCreateStationButton();

      $('input[type=radio].star').rating();

			if(is_owner){
			  Base.radio.refresh_my_stations();
			}
      swf("coke_radio").queueStation(id, queue);
    }
  });


};

Base.radio.launch_station_handler = function(obj, e) {
  e.preventDefault();
	var is_station_list_item = $(obj).hasClass('launch_station');
	var is_create_station_submit = $(obj).attr("id") == "create_station_submit";
	var list;
	var list_play_button;
	if(is_station_list_item) {
		var li = $(obj).parentsUntil('li');
		list = obj.id.match(/(.*)_list(.*)/)[1];
		list_play_button = li.find('img.list_play_button');
		if(list_play_button) { list_play_button.attr('src', Base.currentSiteUrl()+"/images/grey_loading.gif"); }
	}

/*	if(is_create_station_submit){
	  $(obj).html(Base.layout.spanned_spin_image());
	}
*/
	Base.radio.set_station_details($(obj).attr('station_id'), $(obj).attr('station_queue'), false);
	Base.radio.play_station(is_station_list_item, is_create_station_submit, list, list_play_button)

};

Base.radio.resetSearchInput = function(value) {
	$("#search_station_name").val(value);
	$("#create_search_submit").attr('can_post', 0);
};

String.prototype.cleanupURL = function(regex, sub) {
  var cleanup = this.replace(regex, sub);
  cleanup = cleanup.replace(/&&/g, "&");
  cleanup = cleanup.replace(/\?&/g, "?");
  return cleanup;
}

var BANNERS = {};
Base.radio.initialize = function() {
  var elems = "div.songs_box ul li a.launch_station";
  $(elems).click(function(e){
    Base.radio.launch_station_handler(this, e);
  });

  // STATIC MAPPINGS OF BANNER SRC
  var regex = new RegExp(/v_folder=|v_songgenre=|v_songlabel=/g);
  BANNERS.top   = {elem: $("#top_banner"), src: String( $("#top_banner").attr("src") ).cleanupURL(regex, "")};
  BANNERS.right = {elem: $("#square_banner"), src: String( $("#square_banner").attr("src") ).cleanupURL(regex, "")};
};

Base.radio.refreshBanner = function(attr)
{
  for(key in BANNERS)
  {
    BANNERS[key].elem.attr("src", BANNERS[key].src + attr);
  }
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

Base.utils.redirect_layer_to = function(url, code, event) {
  var targ = Base.utils.get_target(event);
  if (targ && targ.tagName != "A") {
    pageTracker._trackPageview(code);
    location.href = url;
  }
}

Base.utils.get_target = function(e) {
  var targ;
  if (!e) var e = window.event;
  if (e.target) targ = e.target;
  else if (e.srcElement) targ = e.srcElement;
  if (targ.nodeType == 3) // defeat Safari bug
    targ = targ.parentNode;
  return targ;
}

/*
 * Layout shared behavior
 */
Base.layout.hide_success_and_error_messages = function() {
  var message = jQuery('.message');
  if (message.length) {
    setTimeout(function() { message.fadeOut(); }, Base.message_fadeout_timeout);
  }
};

Base.layout.bind_events = function() {
  //observe userdata arrow button click
  $('#userdata_arrow').click(function() {
      $('#userdata_box .links').slideToggle(200);
      $('#userdata_arrow .arrow_up').toggleClass('visible');
      return false;
  });

  //observe followers setting button click
  $('.settings_button').click(function() {
      $('.actions_settings', $(this).closest('.follower_actions')).slideToggle('fast');

      return false;
  });

  //observe .artist_box mouse over
  $('.artist_box').hover(function() {
    $(this).addClass('hover');
  }, function() {
    $(this).removeClass('hover');
  });


  //observe accordion tabs
  $('.accordion_title').click(function() {
      $(this).toggleClass('expanded');
      $(this).next().slideToggle(200);

      return false;
  });

  //observe listen_icon button mouse over
  $('.listen_icon').hover(function() {
    clearTimeout(Base.listen_icon_timer);
    $('.unsubscribe_mix', $(this).closest('li')).fadeIn(300);
  }, function() {
    Base.listen_icon_timer = setTimeout(function() {
      $('.unsubscribe_mix').fadeOut(300);
    }, 1000);
  });

  $('.unsubscribe_mix').hover(function() {
    clearTimeout(Base.listen_icon_timer);
  }, function() {
    Base.listen_icon_timer = setTimeout(function() {
      $('.unsubscribe_mix').fadeOut(300);
    }, 1000);
  });


  //observe .songs_box mouse over
  $('.hoverable_list > li').hover(function() {
    $(this).addClass('hover');
  }, function() {
    $(this).removeClass('hover');
  });

  //observe .rule_tooltip mouse over
  $('.rule.info_text, .rule.info_default_text, .rule.info_success_text').live('mouseenter mouseout', function(event) {
      $t= $('.rule_tooltip', this);
      if (event.type == 'mouseenter') {
        $t.css('top', -($t.height()/2));
        $t.stop();
        $t.fadeTo(400, 1);
      } else {
        $t.fadeOut(400);
      }
  });

  $('.rule_tooltip').live('hover', function() {
    $(this).stop();
    $(this).fadeTo(100,1);
  });
}

Base.layout.spin_image = function(type, no_margin) {
  if (typeof(type) == 'undefined' || !type) {
    image_name = 'red_loading.gif';
  } else {
    image_name = type + "_loading.gif";
  }
  $img = jQuery("<img></img>");
  $img.attr('src', Base.currentSiteUrl() + '/images/' + image_name);


  if (typeof(no_margin) == 'undefined' || no_margin) {
    $img.css({'margin-top':'5px'});
  }

  return $img;
};

Base.layout.spanned_spin_image = function(type, no_margin) {
  $img = Base.layout.spin_image(type, no_margin);
  $span1 = $('<span></span>');
  $span2 = $span1.clone();
  $span2.append($img);
  $span1.append($span2);

  return $span1;
};

Base.layout.span_button = function(content) {
  return "<span><span>" + content + "</span></span>";
};

Base.layout.blue_button = function(label, options) {
  link = document.createElement('a');
  link.setAttribute('href', '#');
  link.setAttribute('class', 'blue_button');

  span1 = document.createElement('span');
  span2 = document.createElement('span');

  button_label = document.createTextNode(label);
  span2.appendChild(button_label);
  span1.appendChild(span2);
  link.appendChild(span1);

  if (typeof(options) == 'object' && typeof(options.width) != 'undefined') {
    link.setAttribute('style', "width: " + options.width + ";");
  }

  return link;
};

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

Base.locale.date_difference = function(old_date, new_date) {
  old_date      = new Date(old_date * 1000);

  if (typeof(new_date) == 'undefined') {
    new_date   = new Date();
  } else {
    new_date   = new Date(new_date * 1000);
  }

  date_diff     = new Date(new_date - old_date).getTime();

  weeks = Math.floor(date_diff / (1000 * 60 * 60 * 24 * 7));
  date_diff -= weeks * (1000 * 60 * 60 * 24 * 7);

  days = Math.floor(date_diff / (1000 * 60 * 60 * 24));
  date_diff -= days * (1000 * 60 * 60 * 24);

  hours = Math.floor(date_diff / (1000 * 60 * 60));
  date_diff -= hours * (1000 * 60 * 60);

  minutes = Math.floor(date_diff / (1000 * 60));
  date_diff -= minutes * (1000 * 60);

  seconds = Math.floor(date_diff / 1000);
  date_diff -= seconds * 1000;

  old_time_ago_str = "";

  if (days > 0) {
    old_time_ago_str = Base.locale.t('datetime.distance_in_words.x_days', {'count':days});
  } else if (hours > 1) {
    old_time_ago_str = Base.locale.t('datetime.distance_in_words.x_hours', {'count':hours});
  } else if (minutes > 1) {
    old_time_ago_str = Base.locale.t('datetime.distance_in_words.x_minutes', {'count':minutes});
  } else if (seconds > 30) {
    old_time_ago_str = Base.locale.t('datetime.distance_in_words.x_seconds', {'count':seconds});
  } else {
    old_time_ago_str = Base.locale.t('datetime.distance_in_words.less_than_x_seconds', {'count':seconds});
  }

  return old_time_ago_str + " "+Base.locale.t('datetime.ago');
};

/*
 * Community
 */
Base.community.approve = function(user_slug, button) {
  var params = {'user_slug':user_slug};
  $list      = jQuery('.followers_list');
 
  $approve_button = jQuery(button);
  var old_button_content = $approve_button.html();
  $approve_button.removeClass('yellow_button').addClass('yellow_button_wo_hover');
  $approve_button_label = $approve_button.children().children();
  $approve_button_label.html(Base.layout.spanned_spin_image('yellow'));
  
  
  jQuery.post(Base.currentSiteUrl()+"/users/approve", params, function(response) {
    $li   = $approve_button.parent().parent();
    $li.slideUp();
    $list.prepend(jQuery("<li></li>").append(response));

    Base.layout.bind_events();
  });
};

Base.community.deny = function(user_slug, button) {
  var params = {'user_slug':user_slug}
  var $button = jQuery(button);
  var old_onclick = $button.attr('onclick');
  var $main_div = $button.parent().parent().parent().parent();
  var $black_ul = $button.parent().parent();
  var $settings_button = $main_div.find('.settings_button').children().children();

  $black_ul.fadeOut();
  $settings_button.html(Base.layout.spin_image(false, false));

  jQuery.post(Base.currentSiteUrl() + '/users/deny', params, function(response, status) {
    $main_div.slideUp();
  });
};

Base.community.__follow_request_handler = function(type, user_slug, link, callback) {
  var params           = {'user_slug':user_slug};
  var $link            = jQuery(link);
  var $main_element    = $link.parent().parent().parent().parent();
  var $black_ul        = $link.parent().parent();
  var $settings_button = $main_element.find('.settings_button').children().children();
 
  return;

  // $black_ul.fadeOut();
  // $settings_button.html(Base.layout.spin_image(false, false));
  // 
  // jQuery.post(Base.currentSiteUrl() + '/users/' + type, params, function(response, status) {
  //   $main_element.slideUp();
  //   if (typeof(callback) == 'function') callback(response);
  // });
};

Base.community.follow = function(user_slug, button, remove_div, layer_path) {
  var params = {'user_slug':user_slug}
  var $button = jQuery(button);
  var old_onclick = $button.attr('onclick');

  $button_label = $button.children().children();
  $button_label.html(Base.layout.spanned_spin_image());

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
      $button.removeClass("red_button");
      if (response.status == 'following') {
        $button_label.html(Base.locale.t('actions.unfollow'));
        $button.addClass("green_button");
      } else if (response.status == 'pending') {
        $button_label.html(Base.locale.t('actions.pending'));
        $button.addClass("yellow_button");
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
  $button_label.html(Base.layout.spanned_spin_image('green'));

  $button.attr('onclick', "");
  $button.bind('click', function() { return false; });

  jQuery.post(Base.currentSiteUrl() + '/users/unfollow', params, function(response, status) {
    if (status == 'success') {
      if (remove_div) {
        $button.parent().parent().slideUp();
      } else {
        $button.removeClass("green_button");
        $button.addClass("red_button");
        $button_label.html(Base.locale.t('actions.follow'));
        $button.unbind('click');
        $button.bind('click', function() { Base.community.follow(user_slug, this, remove_div); return false; });
      }
    }
  });
};

Base.community.text_follow = function(user_slug, element, layer_path) {
  var $element = jQuery(element);
  var params = {'user_slug':user_slug}
  jQuery.post(Base.currentSiteUrl() + '/users/follow', params, function(response, status) {
    if (Base.utils.handle_login_required(response, layer_path, null)) {
      //JQuery($element).parent().parent().find('#not_following').hide();
      //jQuery($element).parent().parent().find('#following').show();
      return false;
    }
    if (status == 'success') {
      jQuery($element).parent().parent().find('#not_following').hide();
      jQuery($element).parent().parent().find('#following').show();
    }
  });
};

Base.community.text_unfollow = function(user_slug, element) {
  var $element = jQuery(element);
  var params = {'user_slug':user_slug}
  jQuery.post(Base.currentSiteUrl() + '/users/unfollow', params, function(response, status) {
    if (status == 'success') {
      jQuery($element).parent().parent().find('#not_following').show();
      jQuery($element).parent().parent().find('#following').hide();
    }
  });
};


Base.community.block = function(user_slug, button) {
  var params = {'user_slug':user_slug}
  var $button = jQuery(button);
  var old_onclick = $button.attr('onclick');
  var $main_div = $button.parent().parent().parent();
  var $black_ul = $button.parent().parent();
  var $settings_button = $main_div.find('.settings_button').children().children();

  $black_ul.fadeOut();
  //$settings_button.html("<img src='/images/red_loading.gif'></img>");
  $settings_button.html(Base.layout.spin_image(false, false));

  jQuery.post(Base.currentSiteUrl() + '/users/block', params, function(response, status) {
    if (status == 'success') {
      $main_div.find('.blocked').html("<img src='"+Base.currentSiteUrl()+"/images/blocked.gif'></img> " + Base.locale.t('blocks.blocked'));
      $settings_button.html("<img src='"+Base.currentSiteUrl()+"/images/settings_button.png'></img>");      
      $button.attr('onclick', "");
      $button.unbind('click');
      $button.bind('click', function() { Base.community.unblock(user_slug, this); return false; });
      $button.html(Base.locale.t('actions.unblock'));
    }
  });
};

Base.community.unblock = function(user_slug, button) {
  var params = {'user_slug':user_slug}
  var $button = jQuery(button);
  var old_onclick = $button.attr('onclick');
  var $main_div = $button.parent().parent().parent();
  var $black_ul = $button.parent().parent();
  var $settings_button = $main_div.find('.settings_button').children().children();

  $black_ul.fadeOut();
  // $settings_button.html("<img src='/images/red_loading.gif'></img>");
  $settings_button.html(Base.layout.spin_image(false, false));

  jQuery.post(Base.currentSiteUrl()+'/users/unblock', params, function(response, status) {
    if (status == 'success') {
      $main_div.find('.blocked').html("");
      $settings_button.html("<img src='"+Base.currentSiteUrl()+"/images/settings_button.png'></img>");      
      $button.attr('onclick', "");
      $button.unbind('click');
      $button.bind('click', function() { Base.community.block(user_slug, this); return false; });
      $button.html(Base.locale.t('actions.block'));
    }
  });
};


/*
 * Stations
 */
Base.stations.edit = function(user_station_id, button) {
  $button = jQuery(button);
  $station_text = $button.parent().parent();
  $station_name_container = $station_text.find('.station_name');
  $buttons = $station_text.find('.buttons');

  old_station_name_content = $station_name_container.html();
  old_station_name = $station_name_container.text().replace(/^\s+|\s+$/g, "");

  station_name_input = document.createElement('input');
  station_name_input.setAttribute('type', 'text');
  station_name_input.setAttribute('id', 'station_' + user_station_id + '_input');
  station_name_input.setAttribute('value', old_station_name);

  old_buttons_content = $buttons.html();

  done_button = jQuery(Base.layout.blue_button('Done'));
  done_button.bind('click', function() {
    new_station_input = jQuery('#station_' + user_station_id + "_input");
    new_station_name = new_station_input.val();
    new_station_input.attr('readOnly', true);

    $buttons.hide();
    params = {'_method' : 'put', 'user_station' : {'name':new_station_name} };
    jQuery.post(Base.currentSiteUrl() + '/my/stations/' + user_station_id, params, function(response) {
      new_station_name_content = old_station_name_content;
      new_station_name_content = new_station_name_content.split(old_station_name).join(new_station_name);
      $buttons.html(old_buttons_content).show();
      $station_name_container.html(new_station_name_content);
    });

    return false;
  });

  cancel_button = jQuery(Base.layout.blue_button('Cancel'));
  cancel_button.bind('click', function() {
    $station_name_container.html(old_station_name_content);
    $buttons.html(old_buttons_content);
    return false;
  });


  $buttons.html("");
  $buttons.append(done_button);
  $buttons.append("&nbsp;");
  $buttons.append(cancel_button);

  $station_name_container.html(station_name_input);
};

Base.stations.share = function(station_id) {
  var url = Base.currentSiteUrl()+"/share/station/" + station_id;
  $.popup(function()
  {
    $.get(url, function(response)
    {
      $.popup(response);
    });
  });
};

Base.stations.edit_from_layer = function() {
  station_id = $('#layer_station_id').val();
  playable_id = $('#playable_id').val();
  new_station_name = $('#new_station_name').val();

  if(new_station_name == '') { alert(blank_station_alert); return false; }
	jQuery('#edit_loading').removeClass('hide');

  params = {'_method' : 'put', 'user_station' : {'name': new_station_name} };
  jQuery.post(Base.currentSiteUrl() + '/my/stations/' + playable_id, params, function(response) {
		if(parseInt(station_id, 10) == parseInt($('#station_id').val(), 10)) {
			jQuery('#station_name').html(new_station_name);
		}
	jQuery('#my_stations_list_name_' + station_id).html(new_station_name);
	jQuery(document).trigger('close.facebox');
  });
};

Base.stations.init_delete_layer = function() {
  $("#delete_station_button").click(function() {
    var station_id = parseInt(jQuery("#station_to_delete").val(), 10);
    if(station_id > 0) {
      $('#delete_loading').removeClass('hide');
      $.post(Base.currentSiteUrl() + '/stations/' + station_id + "/delete", {'_method':'delete'}, function(response) {
	    $(document).trigger('close.facebox');
	    if (response == 'destroyed') {
          $('#station_to_delete').attr('value', 0);
          $('#my_station_item_' + station_id).slideUp('fast');
        }
      });
    }
    return false;
  });
};

Base.stations.launch_edit_layer = function(station_id) {
  $.popup(function() {
    url = Base.currentSiteUrl() + '/stations/' + station_id + '/edit';
    $.get(url, function(data) {
      $.popup(data);
    });
  });
  return false;
};

Base.stations.remove_from_layer = function(station_id) {
  $("#station_to_delete").attr('value', station_id);
  url = Base.currentSiteUrl() + '/stations/' + station_id + '/delete_confirmation';
  $.get(url, function(data) {
    $.popup(data);
  });
};

Base.stations.remove = function(user_station_id, button) {
  $button = jQuery(button);
  $station_text = $button.parent().parent();
  $buttons = $station_text.find('.buttons');
  $li = $button.parent().parent().parent();

  $buttons.hide();

  $.post(Base.currentSiteUrl() + '/my/stations/' + user_station_id, {'_method':'delete'}, function(response) {
    if (response == 'destroyed') {
      $li.slideUp();
    } else {
      $buttons.show();
    }
  });
};

Base.stations.close_button_event_binder = function() {
  jQuery("span.recommended_station").bind('click', function() { Base.stations.close_button_handler(this); });
};

Base.djs.close_button_event_binder = function() {
  jQuery("span.close_dj").bind('click', function() { Base.djs.close_button_handler(this); });
};

Base.stations.close_button_handler = function(object) {
    $button = jQuery(object);
    var artist_id = $button.attr('artist_id');

    $parent_div = $button.parent();
    $parent_div.html("<img style='margin-top:50px' src='"+Base.currentSiteUrl()+"/images/loading.gif'></img>");
    $parent_div.css({'background':'#cccccc', 'text-align':'center'});

    var new_artist_id = recommended_stations_queue.shift();

    if (typeof(new_artist_id) == 'undefined') {
      $parent_div.html("");
      $parent_div.css({'background':'white', 'text-align':'left'});
      return;
    }

    var params = {'artist_id':new_artist_id, 'last_box':$parent_div.hasClass('last_box')};
    jQuery.get(Base.currentSiteUrl() + '/stations/top_station_html', params, function(data) {
      $new_div = jQuery(data);
      $parent_div.html($new_div.html());
      $parent_div.css({'background':'white', 'text-align':'left'});
      Base.stations.close_button_event_binder();
    });
};

Base.djs.close_button_handler = function(object) {
    $button = jQuery(object);
    var dj_id = $button.attr('dj_id');

    $parent_div = $button.parent();
    $parent_div.html("<img style='margin-top:3px' src='"+Base.currentSiteUrl()+"/images/loading.gif'></img>");
    $parent_div.css({'background':'#cccccc', 'text-align':'center'});

    var new_dj_id = recommended_djs_queue.shift();

    if (typeof(new_dj_id) == 'undefined') {
      $parent_div.html("");
      $parent_div.css({'background':'white', 'text-align':'left'});
      return;
    }

    var params = {'user_id':new_dj_id, 'last_box':$parent_div.hasClass('last_box')};
    jQuery.get(Base.currentSiteUrl() + '/users/tiny_box_html', params, function(data) {
      $new_div = jQuery(data);
      $parent_div.html($new_div.html());
      $parent_div.css({'background':'white', 'text-align':'left'});
      Base.djs.close_button_event_binder();
    });
};


/*
 * Comment shared
 */
Base.network.show_more = function(button) {
  $button = jQuery(button);

  $span_label = $button.find('span').find('span');
  old_button_label = $span_label.html();
  $span_label.html(Base.layout.spin_image());

  // activities page
  $list   = jQuery('.followers_list');

  if ($list.length == 0) {
    $list = jQuery(".comments_list");
  }

  if ($list.length == 0) {
    throw("Could not find a valid list element.");
  }

  $last_li  = $list.find('li:last');
  timestamp = $last_li.attr('timestamp');

  var params = {'after':timestamp, 'slug':Base.account.slug};
  if (typeof(Base.network.FILTER_BY) != 'undefined') {
    params.filter_by = Base.network.FILTER_BY;
  }

  jQuery.post(Base.currentSiteUrl() + "/activity/latest", params, function (response) {
    $list.html(response).fadeIn();
    $span_label.html(old_button_label);
  });
};

Base.network.count_chars = function() {
  $textarea     = jQuery("#network_comment");
  $chars_counter = jQuery(".chars_counter");

  if ($textarea.val().length < 140) {
    $chars_counter.css({'color':'#cccccc'});
    $chars_counter.html(140 - $textarea.val().length);
  } else {
    $chars_counter.css({'color':'red'});
    $chars_counter.html("0");
    $textarea.val( $textarea.val().substr(0, 140) );
  }
};

Base.network.__update_page_owner_page = function(response, options) {
  $show_more_button    = jQuery('#show_more_comments');
  $comment_list        = jQuery('#network_comment_list');
  $share_button        = jQuery('a.compartir_button');

  $comment_list.show();
  if (typeof(options) == 'object' && typeof(options.replace) != 'undefined' && options.replace) {
    $comment_list.hide().html(response).fadeIn();
    $comment_list.show();
  } else {
    $comment_list.hide().append(response).fadeIn();
    $comment_list.show();
  }

  if ($comment_list.find('li').length >= 6) {
   $show_more_button.fadeIn();
  }
};

Base.network.__update_page_user_page = function(response) {
  $user_medium_text = jQuery("#user_activity_medium_text");
  $ul = jQuery('#user_recent_activities');

  $user_medium_text.find('img').remove();

  if (jQuery.trim(response).length == 0) {
    $user_medium_text.find('span').fadeIn();
    return;
  }

  html_content = $(response).filter('li');

  if (html_content.eq(6).length != []) {
    html_content = html_content.filter(function(index) { if (index < 6) { return $(this) }; });
    jQuery('#show_more_activities').fadeIn();
  }

  $user_medium_text.remove();
  $ul.html(html_content);
};


Base.network.load_latest = function(params, profile_owner) {
  jQuery(document).ready(function() {
    var user_page = jQuery('#user_recent_activities').length > 0;

    if (typeof(params) != 'object') params = {};

    if (user_page) {
      params["public"] = true;
    }

    params.profile_owner = profile_owner;

    jQuery.post(Base.currentSiteUrl() + '/activity/latest', params, function (response) {
      if (user_page) {
        Base.network.__update_page_user_page(response);
      } else {
        jQuery(".chars_counter").show();
        jQuery('#network_update_form').show();
        Base.network.__update_page_owner_page(response);
      }
    });
  });
};

Base.network.__artist_latest_tweet = function(response) {
  $user_big_text = jQuery("#tweet_big_text");
  $msg = jQuery('#tweet_recent_activities');
  $user_big_text.find('img').remove();

  $user_big_text.remove();
  $msg.html(response).fadeIn();
}

Base.network.load_latest_tweet = function(params) {
  jQuery(document).ready(function() {
    if (typeof(params) != 'object') params = {};
    jQuery.post(Base.currentSiteUrl() + '/activity/latest_tweet', params, function (response) {
      Base.network.__artist_latest_tweet(response);
    });
  });
};

Base.network.getPushUpdateParams = function() {
  var params = {};
  params['message'] = $("#network_comment").val();
  return params;
}

Base.network.pushUpdateCallback = function(response) {
 var commentField = $("#network_comment");
 if (response.success) {
   commentField.val("");
   var charsCounter = $(".chars_counter");
   charsCounter.html(140);
   charsCounter.css({'color':'#cccccc'});
   Base.network.__update_page_owner_page(response.latest, {'replace':true});
   $("div.sorting a").removeClass("active");
   $("div.sorting a[href*=all]").addClass("active");   
 } else {
    commentField.addClass('network_update_red');
    var networkArrow = $(".network_arrow");
    networkArrow.attr("src", Base.currentSiteUrl() + "/images/network_arrow_red.gif");    
    $('.status_red_msg').remove();
    var messageDiv = $('<div class="status_red_msg"></div>');
    $.each($.parseJSON(response.errors), function() {
      messageDiv.append(this + "<br />");
    });
    networkArrow.next().after(messageDiv);
 }
 $('a.compartir_button').removeClass('blue_button_wo_hover').addClass('blue_button').html($oldButtonContent);
}

Base.network.pushUpdate = function() {    
  var shareButton = $('a.compartir_button');
  $oldButtonContent = shareButton.html();
  shareButton.removeClass('blue_button').addClass('blue_button_wo_hover');
  var shareButtonLabel = shareButton.children().children();
  shareButtonLabel.html(Base.layout.spanned_spin_image());

  $.post(Base.currentSiteUrl() + '/activity/update/status', 
         Base.network.getPushUpdateParams(), 
         Base.network.pushUpdateCallback);
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
  var url   = Base.currentSiteUrl() + "/search/all/" + ( q == msg ? "" : q) ;
  location.href = url;
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


Base.header_search.autocomplete = function(last_value) {
  jQuery('.search_results_ajax').show();
  var form_values = jQuery("#header_search_form").serializeArray();
  var q = Base.header_search.getFieldValue(form_values,'q');
  if( last_value != q || q == ''){
    jQuery('.search_results_ajax').hide();
    return;
  }
  jQuery.get(Base.currentSiteUrl() + '/search/all/' + q, function(data) {
      jQuery('.search_results_box').html(data);
      jQuery('.search_results_box').show();
      jQuery('.search_results_ajax').hide();
  });
};

/*
 * content search
 */


Base.content_search.buildSearchUrl = function () {
  var form_values = jQuery("#content_search_form").serializeArray();
  var q     = Base.header_search.getFieldValue(form_values,'q');
  var url   = Base.currentSiteUrl() + "/playlist/create/?term=" + ( q == content_msg ? "" : q) ;
  location.href = url;
  return false;
};

Base.content_search.dropdown = function() {
  jQuery("#content_search_query").keyup(function(e) {
      //jQuery('.search_results_ajax').show();
      var keyCode = e.keyCode || window.event.keyCode;
      var form_values = jQuery("#content_search_form").serializeArray();
      var q = Base.header_search.getFieldValue(form_values,'q');
      if(keyCode == 37 || keyCode == 38 || keyCode == 39 || keyCode == 40){
        return;
	  }
      if(keyCode == 13 || keyCode == 27 || q.length <= 1){
        //jQuery('.search_results_ajax').show();
        jQuery('.content_search_results_ajax').hide();
        jQuery('.create_box').hide();
        return;
  	  }
      //jQuery('.search_results_box').show();
      setTimeout(function () {Base.content_search.autocomplete(q)}, 500);
      return true;
    });
};


Base.content_search.autocomplete = function(last_value) {
  jQuery('.content_search_results_ajax').show();
  var form_values = jQuery("#content_search_form").serializeArray();
  var q = Base.header_search.getFieldValue(form_values,'q');
  if( last_value != q || q == ''){
    jQuery('.content_search_results_ajax').hide();
    return;
  }
  jQuery.get(Base.currentSiteUrl() + '/search/content/all/' + q, function(data) {
      jQuery('.create_box').html(data);
      Base.utils.resetIndexes();
      jQuery('.create_box').show();
      
      jQuery('.content_search_results_ajax').hide();
  });
};


/*
 * playlist create search
 */

Base.playlist_search.buildSearchUrl = function () {
  //var form_values = jQuery("#playlist_search_form").serializeArray();
  //var q     = Base.header_search.getFieldValue(form_values,'q');
  //var url   = "/playlists/create/?term=" + ( q == msg ? "" : q) ;
  //location.href = url;
  return false;
};

Base.playlist_search.dropdown = function() {
  jQuery("#playlist_search_query").keyup(function(e) {
      //jQuery('.search_results_ajax').show();
      var keyCode = e.keyCode || window.event.keyCode;
      //var form_values = jQuery("#playlist_search_form").serializeArray();
      //var q = Base.header_search.getFieldValue(form_values,'q');
      var q = jQuery('#playlist_search_query').val();
      
      if(keyCode == 37 || keyCode == 38 || keyCode == 39 || keyCode == 40){
        return;
	  }
      if(keyCode == 13 || keyCode == 27 || q.length <= 1){
        //jQuery('.search_results_ajax').show();
        jQuery('.content_search_results_ajax').hide();
        jQuery('.create_box').hide();
        return;
  	  }
      //jQuery('.search_results_box').show();
      setTimeout(function () {Base.playlist_search.autocomplete(q)}, 500);
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

/*
 * Playlists
 */

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
    elem.find('img').attr('src', Base.currentSiteUrl() + '/images/icon_stop_button.png');
    swf('stream_connect').playSample(media, songId);
    _playing = true;
  }
  else if(songId != _songId)
  {
    //_activeStream.attr('class', 'draggable_item ui-draggable');
    _activeStream.removeClass('selected_row');
    _activeStream.find('div.song_name img').attr('src', Base.currentSiteUrl() + '/images/icon_play_button.png');
    Base.playlists.onStreamEnd(_activeStream);
    _activeStream = elem.parent().parent().addClass('selected_row');
    Base.playlists.onStreamStart(_activeStream);
    elem.find('img').attr('src', Base.currentSiteUrl() + '/images/icon_stop_button.png');
    swf('stream_connect').playSample(media, songId);
  }
  else if(_playing && songId == _songId)
  {
    //_activeStream.attr('class', 'draggable_item ui-draggable');
    _activeStream.removeClass('selected_row');
    _activeStream.find('div.song_name img').attr('src', Base.currentSiteUrl() + '/images/icon_play_button.png');
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
  _activeStream.find('div.song_name img').attr('src', Base.currentSiteUrl() + '/images/icon_play_button.png');
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

/*
 * main search
 */

Base.main_search.buildSearchUrl = function () {
  $('#search_page').attr('value', '');		
  location.href = Base.main_search.getSearchUrl();
  return false;
};

Base.main_search.getSearchUrl = function () {
  var form_values = jQuery("#main_search_form").serializeArray();
  var q     = Base.header_search.getFieldValue(form_values,'q');
  var scope = Base.header_search.getFieldValue(form_values,'scope');
  var sort  = Base.header_search.getFieldValue(form_values,'sort');
  var page  = Base.header_search.getFieldValue(form_values,'page');
  var url   = Base.currentSiteUrl() + "/search" + (scope == "" ? "/all" : "/" + scope) + 
    "/" + q + "?sort_by=" + sort + ((!isNaN(parseInt(page,10))) ? "&page=" + page : "");
  return url;
};

Base.main_search.highlight_scope = function() {
  $(".scope a").each(function(el) {
    $(this).removeClass('active');
  });
  value = $("#search_scope").get(0).value;
  $("#search_" + value).addClass('active');
};

Base.main_search.highlight_sort = function(scope) {
  var sort =  jQuery('#search_sort').val();
  $("#" + value + "_result div.sorting a").each(function(el) {
    $(this).removeClass('active');
  });
  $("#" + value + "_sort_" + sort).addClass('active');
};

Base.main_search.refresh_result = function() {
  var url = Base.main_search.getSearchUrl();
  $.ajax({
    url: url,
    type: 'GET',
    data: { result_only: true },
    success: function(result) {
      var value = $("#search_scope").get(0).value;
      var ul = $("#" + value + '_result_details');
      ul.empty();
      ul.append(result);
      ul.find('div.sorting a').click(function(e) {
        e.preventDefault();
        $('#search_sort').attr('value', $(this).attr('href').match(/sort_by\=(.*)/)[1]);
        $("#scope_" + value + "_toggle").parentsUntil('ul').find('img.mini_loader').removeClass('hide');
        Base.main_search.refresh_result();				
      });
	  $("#scope_" + value + "_toggle").parentsUntil('ul').find('img.mini_loader').addClass('hide');
      Base.main_search.toggle_scope(false);
      Base.main_search.init_pagination();
      $('input[type=radio].star').rating();
    },
    error: function(result) { alert("error"); }
  });
};

Base.main_search.init_toggles = function() {
  $(".scope_toggle a").click(function(e) {
    e.preventDefault();
    Base.main_search.refresh_result();
  });
  value = $("#search_scope").get(0).value;
  $("#search_" + value).addClass('active');
};
	
Base.main_search.activate_scope_toggle = function() {
  Base.main_search.highlight_scope();
  value = $("#search_scope").get(0).value;
  $(".scope_toggle a").each(function(el) {
    if(this.id != "scope_" + value + "_toggle") {
      $(this).removeClass('active');
    }
  });
  $("#scope_" + value + "_toggle").addClass('active');
};

Base.main_search.toggle_scope = function(activate) {
  if(activate || typeof(activate)=="undefined" ) { Base.main_search.activate_scope_toggle(); }
  $(".scope_result").each(function(el) {
    if(this.id != value + "_result") {
      $(this).addClass('hide');
    }
  });
  $("#" + value + "_result").removeClass('hide');
};

Base.main_search.select_scope = function() {
  $(".scope a").click(function() {
    value = this.id.match(/search_(.*)/)[1];
    $('#search_scope').attr('value', value);
    Base.main_search.highlight_scope();
    return false;
  });
  $('#main_search_form').submit(function() {	
    scope = $('#search_scope').attr('value');
  });
  Base.main_search.highlight_scope();
};

Base.main_search.initialize_scope_toggle = function() {
  Base.main_search.select_scope();

  $(".scope_toggle a").click(function() {
  value = this.id.match(/scope_(.*)_toggle/)[1];
  $('#search_scope').attr('value', value);    
  if(!$("#" + value + "_result_details").children().length && parseInt($("#" + value + "_result").attr('result_count'), 10) > 0) {				
    Base.main_search.activate_scope_toggle();
    $(this).parentsUntil('ul').find('img.mini_loader').removeClass('hide');
      Base.main_search.refresh_result();
    } else {
      Base.main_search.toggle_scope();
    }
    return false;
  });

  $("div.scope_result .sorting a").click(function(e) {						
    e.preventDefault();
    scope = $(this).parent().parent().attr('id').match(/(.*)_result/)[1];
    $('#search_sort').attr('value', this.href.match(/sort_by\=(.*)/)[1]);
    Base.main_search.highlight_sort(scope);
    if(parseInt($(this).parent().parent().attr('result_count'), 10) > 1) {
      $("#scope_" + $('#search_scope').val() + "_toggle").parentsUntil('ul').find('img.mini_loader').removeClass('hide');
        Base.main_search.refresh_result();
      }
    return false;
  });

};

Base.main_search.init_pagination = function() {
  $("div.pagination a").click(function(e){
    e.preventDefault();
    $('#search_page').attr('value', this.href.match(/page\=(\d+)/)[1]);		
    $('div.pagination').after('<div class="small_loading">');
    Base.main_search.refresh_result();
  });
};

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
}


Base.radio.init_edit_station_layer = function() {
  $("#edit_station_name").click(function() {
    $.popup(function() {
      url = Base.currentSiteUrl() + '/stations/' + jQuery('#station_id').val() + '/edit';
      $.get(url, function(data) {
        $.popup(data);
      });
    });
  });

  return false;

  save_button.bind('click', function() {
    params = {'_method' : 'put', 'user_station' : {'name': new_station_name } };
    $.post(Base.currentSiteUrl() + '/my/stations/' + user_station_id, params, function(response) {
      $("#station_name").html(new_station_name);
      $(document).trigger('close.facebox');
    });
    return false;
  });
};

/*
 * Register and triggers
 */
$(document).ready(function() {
  // Effects and Layout fixes
  $('.png_fix').supersleight({shim: Base.currentSiteUrl() + '/images/blank.gif'});

  Base.playlists.close_button_event_binder();
  Base.djs.close_button_event_binder();
  Base.layout.bind_events();
  Base.layout.hide_success_and_error_messages();
  Base.header_search.dropdown();
  Base.content_search.dropdown();
  Base.playlist_search.dropdown();

  $("#network_comment").focus(function() {
    $("#network_comment").addClass("network_update_red");
    $(".network_arrow").attr("src", Base.currentSiteUrl() + "/images/network_arrow_red.gif");
  });  
  
  $("#network_comment").blur(function() {
    $("#network_comment").removeClass("network_update_red");
    $(".network_arrow").attr("src", Base.currentSiteUrl() + "/images/network_arrow.gif");
    $(".network_red_msg").remove();
    $('.status_red_msg').remove();
  }); 

  $("#network_comment_list").show();

  $(".ajax_sorting a").click(Base.utils.ajax_sorting);

  $('.delete_site').click(Base.account_settings.delete_website);

  $(".ajax_pagination .pagination a:not(.disabled)").click(Base.utils.ajax_pagination); 

  $("p.filter a").click(Base.badges.filter);

 $(document).bind('reveal.facebox', function() {     
    $('#facebox .real_tags').val('');
    $('#selected_tags').val('');
    if ($('#facebox .real_tags').length != 0) {
      $tag_box = new $.TextboxList('#facebox .real_tags', {  });
    }
 })
 
});

Base.network.reload_comments = function(filter) {
  $list = jQuery(".comments_list");

  $last_li  = $list.find('li:last');
  timestamp = $last_li.attr('timestamp');

  var params = {'slug':Base.account.slug};
  params.filter_by = filter;

  var sort_link = $("div.sorting a[href*="+filter+"]" );

  sort_link.parents('.sorting').after('<div class="small_loading at_sorting">');

  $.post(Base.currentSiteUrl() + "/activity/latest", params, function (response) {
    $("ul#network_comment_list").show();
    $("div.sorting a").removeClass("active");
    $(".comments_list").html(response);
    sort_link.addClass("active");
    $('div.small_loading').remove();
  });
};

/* Reviews */
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
    params['comment'] = $.trim($("#comment_update").val());
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

Base.utils.showRegistrationLayer = function(url, type) {
  if (url == undefined) {
    url = '/my/dashboard';	
  }
  type || (type = '')
  $.get('/registration_layers/' + type + '?return_to=' + url, function(response) {
    $.simple_popup(response);
  });
  return false;
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

Base.reviews.overwrite = function(review) {
  var params = Base.reviews.getParams();
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
    $('input[type=radio].star').rating();
    Base.reviews.resetForm();
  } else {
    Base.reviews.showErrors(response.errors);
  }
};

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

Base.reviews.show = function(review) {
  var url = Base.currentSiteUrl() + "/reviews/" + review + "/show";
  $.get(url, function(response) {
    $.popup(response);
    $('input[type=radio].star').rating();
  });
};

Base.badges.init_notifications = function() {
  $("a.congrats_update").click(function(e){
    e.preventDefault();
    Base.badges.set_notified();
  });

  setTimeout(function(){
    $('#congrats_slides').cycle({fx: 'fade', timeout: 5000});
    $("#congrats_popup").fadeIn('slow');
  }, 3000);
};

Base.badges.set_notified = function() {
  var url = Base.currentSiteUrl() + "/my/badges/set_notified";
  $.get(url, function(response) {
    $("#congrats_popup").fadeOut('slow');
  });
};

Base.badges.filter = function() {
  $("table.coke tbody tr").hide();
  if ( $(this).attr('type') == "All" ) {
	$("table.coke tbody tr").fadeIn();	
  } else {
    $("table.coke tbody tr:has(td:contains('" + $(this).attr('type') + "'))").fadeIn();		
  }
  var inactive_link = $("p.filter span.selected");
  inactive_link.replaceWith('<a href="#" type="' + inactive_link.attr('type') + '">' + inactive_link.text() + '</a>');
  $(this).replaceWith('<span class="selected" type="' + $(this).attr('type') + '">' + $(this).text() + '</span>');
  $("p.filter a").click(Base.badges.filter);  
  return false;	
}

Base.utils.rebind_list = function() {
  $('.artist_box').hover(function() {
    $(this).addClass('hover');
  }, function() {
    $(this).removeClass('hover');
  });
  $('input[type=radio].star').rating();
  $(".ajax_pagination .pagination a:not(.disabled)").click(Base.utils.ajax_pagination);
  $(".ajax_sorting a").click(Base.utils.ajax_sorting);
};

Base.utils.load_content = function(response) {
  $('#content_list').html(response);
  $('div.small_loading').remove();
  Base.utils.rebind_list();
};

Base.utils.ajax_sorting = function() {
  var sort_link = $(this);
  var title = sort_link.parents('.ajax_pagination').prev();

  title.append('<div class="small_loading">');

  $(".ajax_sorting a").removeClass("active");
  sort_link.addClass("active");

  $.get(sort_link.attr('href'), Base.utils.load_content);
  return false;
};

Base.utils.ajax_pagination = function() {
  var paginate_link = $(this);  
  $('div.pagination').after('<div class="small_loading">');
  $.get(paginate_link.attr('href'), Base.utils.load_content);
  return false;
};

Base.playlists.copy = function(slug, playlist_id) {
  var url = Base.currentSiteUrl() + '/' + slug + '/playlists/' + playlist_id + '/copy';
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
    $(document).trigger('close.facebox');
    return false;
  }
  $("#duplicate_button span span img").remove();
};

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

Base.playlists.removeTag = function() {
  var tag = $(this).text();
  $(this).parent().remove();
  $("ul.available_tags li a:contains('" + tag + "')").parent().show();
  $("#selected_tags").val( $("#selected_tags").val().replace(new RegExp('(,)?' + tag),"") );   
  Base.playlists.updateSelectedTagCount();
  return false;
}

Base.playlists.updateSelectedTagCount = function() {
  $('#selected_tags_count').text('(' + $('ul.selected_tags li a').length + ')');  
  $('#available_tags_count').text('(' + $('ul.available_tags li:visible a').length + ')');
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

Base.playlists.removeAllTags = function() {
  $('ul.selected_tags li').remove();   
  $('ul.available_tags li').show();
  Base.playlists.updateSelectedTagCount();
  $('#selected_tags').val('');
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

// getPageScroll() by quirksmode.com
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

// Adapted from getPageSize() by quirksmode.com
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
