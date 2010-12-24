jQuery(document).ready(function($){

  // Form submit on enter
  password_field = $('#password');
  password_field.keypress(function(e) {
    if ((e.which && e.which == 13) || (e.keyCode && e.keyCode == 13)) {
      password_field.closest('form').submit();
    }
  });
});

