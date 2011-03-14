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

  // song slider
  $('.cancion ul').liScroll({travelocity: 0.05});

});
