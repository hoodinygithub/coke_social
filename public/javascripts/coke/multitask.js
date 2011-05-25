$(document).ready(function() {
  
  //navegacion fija
  var msie6 = $.browser == 'msie' && $.browser.version < 7;
  if(!msie6){
    var top = $('.navegacion').offset().top;
    $(window).scroll(function (event) {
      var y = $(this).scrollTop();
      var alto = $(".navegacion").height();
      if (y >= top) {
        $('.navegacion').addClass('fixed');
  	    $(".cabecera").css("marginBottom",alto+"px");
      } else {
        $('.navegacion').removeClass('fixed');
  	    $(".cabecera").css("marginBottom",0);
      }
    });
  } 

  //fuente Myriad
  $('.txt').livequery(function() {
    Cufon.replace('.txt');
  })
  
  
  //observe accordion tabs
  $('.accordion_title').livequery('click', function() {
      $(this).toggleClass('expanded');
      $(this).next().slideToggle(200);

      return false;
  });

  //efecto badges
  // NOTE: Commented block below
  // Why add more javascript complexity if it doesn't improve the
  // performance of the page.  Go back to product and suggest against
  // this fluff!
  /*
     if($(".badges").length) {
     var elem = $(".badges");
     elem.animate({"opacity":0});
     $(window).scroll(function (event) {
     var top = elem.offset().top;
     var scrollY = $(this).scrollTop();
     var visible = $(window).height();
     var y = scrollY+visible;
     if (y >= top) {
     elem.animate({"opacity":1},1000);
     }
     });
     }
  */

  //plegar desplegar ficha de usuario
  //if($(".usuario_ficha .mas_info").length) {
    $(".usuario_ficha .mas_info").livequery('click', function(e){
  		e.preventDefault();
  		var padreplegado = $(this).parent().parent(".ficha_plegada");
  		var padre = $(this).parent().parent();
      if(padreplegado.length){
        padreplegado.removeClass("ficha_plegada");
        $(this).addClass("menos_info").html(Base.locale.t('actions.hide') + '<span class="bg_flecha hide">&nbsp;</span>');
        $(this).attr('title',Base.locale.t('actions.hide'));
      }else{
        padre.addClass("ficha_plegada");
        $(this).removeClass("menos_info").html(Base.locale.t('actions.show') + '<span class="bg_flecha show">&nbsp;</span>');
        $(this).attr('title',Base.locale.t('actions.show'));
      }
  	});
  //}
  
  Base.header_search.dropdown();
  
});