$(document).ready(function(){
	
  //globos ayuda
  $("a.tooltip").mouseover(function() {
    $(this).attr("title","");
	idtip = "#"+$(this).attr("rel");
    left = $(this).position().left;
	ancho = $(idtip).width() / 2;
	left = left - ancho+8;
	$(idtip).show().css({"top":29,"left":left}); 
	$(this).addClass("activo");
  }).mouseout(function() {
	$(idtip).hide();
	$(this).removeClass("activo");
  });
  
  //cancion slide
  function slidecancion(){
    $(".cancion ul").liScroll({travelocity: 0.02});
  }
  setTimeout(slidecancion,3000); //retraso el inicio 3 secs

  
});