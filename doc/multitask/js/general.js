$(document).ready(function(){
  
  //seleccionar el texto
  /*
  $(".buscador .txt_form").focus(function(){
    $(this).select(); 
  });
  */
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
  Cufon.replace('.txt');
  
  //efecto badges  
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
  
  //plegar desplegar ficha de usuario
  if($(".usuario_ficha .mas_info").length) {
    
	$(".usuario_ficha .mas_info").click(function(e){
		e.preventDefault();
		var padreplegado = $(this).parent().parent(".ficha_plegada");
		var padre = $(this).parent().parent();
        if(padreplegado.length){
		  padreplegado.removeClass("ficha_plegada");
		  $(this).addClass("menos_info").html('Ocultar<span class="bg_flecha">&nbsp;</span>');
		  $(this).attr('title','Ocultar');
		}else{
		  padre.addClass("ficha_plegada");
		  $(this).removeClass("menos_info").html('Mostrar<span class="bg_flecha">&nbsp;</span>');
		  $(this).attr('title','Mostrar');
		}
	}); 
	
  }
});