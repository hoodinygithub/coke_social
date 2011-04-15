jQuery(function($){

  //slide copiar compartir
  $("a.btn_slide").click(function(event) {
	  event.preventDefault(); //detengo clic
	  var elem = $(this).attr("href");
	  var ancho = $("#"+elem).width();
	  if(elem=="sub_home"){ //si llamamos a la home, volver
		$(this).parent().parent().animate({"left":"+="+ancho+"px"});
		$("#"+elem).animate({"left":"+="+ancho+"px"});
	  }else{ //si llamamos a una pantalla, copiar, compartir
		  $("#sub_home").animate({"left":"-="+ancho+"px"});
		  $("#"+elem).animate({"left":"-="+ancho+"px"});
	  }
  });
  
  //mostrar ocultar listas mixes usuario
  $(".mod_tab[id!=masmixes]").animate({"opacity":0},0);
  $("#menu_topmixes li:first-child").addClass("activo");
  $("#menu_topmixes a").click(function(event) {
	  event.preventDefault(); //detengo clic
	  var elem = $(this).attr("href");
	  if($.browser.msie){//evitar bug png en animacion
	    $(elem).css("background","#fff");
	  }
	  $("#menu_topmixes li").removeClass("activo");
	  $(this).parent().addClass("activo");
      $(".mod_tab").animate({"opacity":0},500);
      $(elem).animate({"opacity":1},500);
  });
  
  //recojo anchor de la URL
  var urlentrada = $(location).attr('href');
  if (urlentrada.match('#')){
    var urlanchor = urlentrada.split('#')[1];
	if(urlanchor=="comparto"){ //si viene para compartir por email
      var ancho = $("#sub_compartir").width();
	  $("#sub_home").animate({"left":"-="+ancho+"px"});
	  $("#sub_compartir").animate({"left":"-="+ancho+"px"});
	}
  }
  
});