(function($) {
  $.alert_layer = function(data) {
    setDisplayType(data);
    $.alert_layer.loading(data);
    
    if (data.ajax) fillLayer_Ajax(data.ajax)
    else fillLayer_Html(data)
  }
  
  $.extend($.alert_layer, {
    settings: {
      inited       : false,
      displayType  : "ajax",
      opacity      : 0.8,
      skipOverlay  : false,
      loadingImage : '/images/loading_large.gif',
      imageTypes   : [ 'png', 'jpg', 'jpeg', 'gif' ],
      layerHtml    : '\
        <div id="alert_layer" style="display:none;"> \
          <div class="alert_layer_content"></div> \
        </div>'
    },
    
    loading: function(data) {
      init();
      if ($('#alert_layer .loading').length == 1) return true;
      showOverlay();
      
      $('#alert_layer .alert_layer_content').empty();
      //$('#alert_layer').css('left', $(window).width() / 2 - ($('#alert_layer').width() / 2));
      
      if ($.alert_layer.settings.displayType == "ajax")
        $('#alert_layer').children().hide().end().
          append('<div class="loading"><img src="'+$.alert_layer.settings.loadingImage+'"/></div>');

      $('#alert_layer').show();
      $(document).bind('keydown.alert_layer', function(e) {
        if (e.keyCode == 27) $.alert_layer.close()
        return true
      })
    },

    reveal: function(data) {
      $('#alert_layer .alert_layer_content').html(data);
      $('#alert_layer .loading').remove();
      $('#alert_layer').children().fadeIn('normal')
    },

    close: function() {
      $(document).trigger('close.alert_layer')
      return false
    }
  })

  /*
   * Public, $.fn methods
   */
  $.fn.alert_layer = function() {
    function clickHandler() {
      $.alert_layer(this.href)
      return false
    }
    
    return this.click(clickHandler)
  }
  
  // called one time to setup alert_layer on this page
  function init() {
    if ($.alert_layer.settings.inited) return true
    else $.alert_layer.settings.inited = true
   
    var imageTypes = $.alert_layer.settings.imageTypes.join('|')
    $.alert_layer.settings.imageTypesRegexp = new RegExp('\.' + imageTypes + '$', 'i')
    
    $('body').append($.alert_layer.settings.layerHtml)
  }
  
  function setDisplayType(data) {
    if (data.match(/#/))
      $.alert_layer.settings.displayType = "div";
    else if (data.match($.alert_layer.settings.imageTypesRegexp))
      $.alert_layer.settings.displayType = "image";
    else
      $.alert_layer.settings.displayType = "ajax";
  }
  
  
  // Figures out what you want to display and displays it
  // formats are:
  //     div: #id
  //    ajax: anything else
  function fillLayer_Html(href) {
    // div
    if ($.alert_layer.settings.displayType == "div") {
      var url    = window.location.href.split('#')[0]
      var target = href.replace(url,'')
      $.alert_layer.settings.showLoader = false;
      $.alert_layer.reveal($(target).clone().show())

    // image
    } else if ($.alert_layer.settings.displayType == "image") {
      fillLayer_Image(href)
      
    // ajax
    } else {
      fillLayer_Ajax(href)
    }
  }
  
  function fillLayer_Ajax(href) {
    $.alert_layer.settings.showLoader = true;
    $.get(href, function(data) { $.alert_layer.reveal(data) })
  }
  
  function fillLayer_Image(href) {
    $.alert_layer.settings.showLoader = false;
    var image = new Image()
        image.src = href;
        image.onload = function() {
          $.alert_layer.reveal('<div class="image"><img src="' + image.src + '" /></div>')
        }
  }
  
  function showOverlay() {
    if ($.alert_layer.settings.skipOverlay) return

    if ($('layer_overlay').length == 0) 
      $("body").append('<div id="layer_overlay" class="layer_hide"></div>')

    $('#layer_overlay').hide().addClass("layer_overlayBG")
      .css('opacity', $.alert_layer.settings.opacity)
      // .click(function() { $(document).trigger('close.alert_layer') })
      .fadeIn(200)
    return false
  }

  function hideOverlay() {
    if ($.alert_layer.settings.skipOverlay) return

    $('#layer_overlay').fadeOut(200, function(){
      $("#layer_overlay").removeClass("layer_overlayBG")
      $("#layer_overlay").addClass("layer_hide") 
      $("#layer_overlay").remove()
    })

    return false
  }
  
  $(document).bind('close.alert_layer', function() {
    $(document).unbind('keydown.alert_layer')
    $('#alert_layer').fadeOut(function() {
      hideOverlay();
      $('#alert_layer .loading').remove();
    })
  })
})(jQuery);

jQuery(document).ready(function() {
  jQuery('a[rel*=layer]').alert_layer();
})
