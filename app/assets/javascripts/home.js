// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery.siwa.min
//= require jquery.validate
//= require forms

$(function() {
  function rotate_image($current_image, $next_image) {
    $current_image.fadeOut(500, function() {
      $next_image.fadeIn(500);
      rotate_sequence();
    });
  }

  function rotate_sequence() {
    var $current_image, $next_image, $carousel;

    $carousel = $('.image-rotation');

    $current_image = $('img:visible', $carousel);

    if( $current_image.next('img').length > 0 ) {
      $next_image = $current_image.next('img');
    } else {
      $next_image = $('img:first', $carousel);
    }

    setTimeout(function() {
      rotate_image($current_image, $next_image);
    }, 5000);
  }

  rotate_sequence();
  $.stayInWebApp();

});