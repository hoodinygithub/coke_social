var playlist_valid = false
var playlist_ids = [];
var playlist_count = 0;
var playlist_items_req = 10;
var edit_playlist = false;

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

function add_item(id, title, artist_id, artist_name, album_id, album_name, image_src)
{
  if(!playlist_ids.contains(id))
  {
    li = '<li id="'+id+'" artist_id="'+artist_id+'" album_id="'+album_id+'">'
          //+ image_tag
          + '<img alt="'+id+'" class="icon avatar small" src="'+image_src+'" />'
          + '<div class="text">'
              + '<big><b>'+title+'</b></big><br/>'
              + '<b>album:</b> '+album_name+'<br/>'
              + '<b>by:</b> '+artist_name+''
          + '</div>'
          + '<br class="clearer" />'
          + '<a href="#" onclick="remove_item('+id+'); return false;"><img src="/images/close_grey.gif" class="close_x" alt="" /></a>'
        + '</li>';
        
    $('#playlist_item_list').append(li);
    playlist_ids.push(id);
    playlist_count = playlist_ids.length;
    update_counts();
  }
  validate_playlist();
  toggle_playlist_box();
}

function remove_item(id)
{
  if(playlist_ids.contains(id))
  {
    $('#' + id).remove();
    playlist_ids.remove(id);
    playlist_count = playlist_ids.length;
    update_counts();
    validate_playlist();
    toggle_playlist_box();
  }
}

function validate_playlist()
{
  if(playlist_count < playlist_items_req)
    playlist_valid = false;
  else
    playlist_valid = true;
}

function update_counts()
{
  $('#track_count').html(playlist_count);
  $('#remaining_track_count').html((playlist_count > playlist_items_req) ? 0 : (playlist_items_req - playlist_count))
}

function toggle_playlist_box()
{
  if(playlist_count > 0)
  {
    $('#empty_playlist').hide();
    $('#populated_playlist').show();
    $('#autofill_button').show();
    $('#autofill_button_ques').show();
    $('#save_button').show();
  }
  else
  {
    $('#populated_playlist').hide();
    $('#empty_playlist').show();
    $('#autofill_button').hide();
    $('#autofill_button_ques').hide();
    $('#save_button').hide();
  }    
}

function image_path(id, artist_id)
{
  return "http://assets.cyloop.com/storage?fileName=/.elhood.com-2/usr/"+artist_id+"/image/thumbnail/"+id+".sml.jpg";
}

function remove_search_result(id)
{
  $('#search_result_' + id).remove();
}

function get_song_list(id,scope)
{
  q = "item_id=" + id + "&scope=" + scope;
  jQuery.get('/playlist/create?' + q, function(data) {
      jQuery('#search_results_container').html(data);
  });
}

function get_search_results(term,scope)
{
  q = "term=" + term + "&scope=" + scope;
  jQuery.get('/playlist/create?' + q, function(data) {
      jQuery('#search_results_container').html(data);
  });
}

function open_save_popup()
{
  if(playlist_valid)
  {
    if(edit_playlist)
    {
      form = $('#update_playlist_form');
      form.find("input[name='item_ids']").attr("value", playlist_ids);
      form.submit();
    }
    else
    {
      img_src = $('#' + playlist_ids[0]).find('img').attr('src');
      $('#save_layer_avatar').attr('src', img_src.replace(/image\/thumbnail/i, "image/comments"));
      $('#save_mix_popup').fadeIn('fast');
    }
  }
  else
    $('#unable_popup').fadeIn('fast');
}


function submit_save_form()
{
  form = $('#save_playlist_form');
  
  if(playlist_valid)
  {
    name = form.find("input[name='name']").val();
    if(name != "")
    {
      form.find("input[name='item_ids']").attr("value", playlist_ids);
      form.submit();
    }
    else
    {
      $('#save_mix_popup').fadeOut('fast');
      //$('#unable_popup').fadeIn('fast');
    }
  }
  else
  {
    $('#save_mix_popup').fadeOut('fast');
    $('#unable_popup').fadeIn('fast');
    toggle_playlist_box();
  }
}

function init_draggable()
{
  // $(".draggable_item").draggable({revert: true, scroll: false, snap: true, helper: 'clone', appendTo: 'body', connectToSortable: true, cursorAt: {left: 100} });
  // $(".dotted_box").droppable({
  //       accept: ".draggable_item",
  //       hoverClass: "dragging",
  //       drop: function(event, ui) {
  //         alert('dropped');
  //         
  //       }
  // });
}

$(function() {
  init_draggable()
});
