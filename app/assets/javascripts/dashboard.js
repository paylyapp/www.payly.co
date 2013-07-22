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
//= require jquery_ujs
//= require libraries/bootstrap/bootstrap.js
//= require libraries/bootstrap-select/bootstrap-select.min.js
//= require parsley

$(function() {
  $('select').selectpicker();


  if($('select[name="stack[charge_type]"]').val() == "any") {
    $('.field-charge-amount').hide();
  }

  $('select[name="stack[charge_type]"]').change(function() {
    if($(this).val() == "any") {
      $('.field-charge-amount').slideUp();
    } else {
      $('.field-charge-amount').slideDown();
    }
  });

  if(!$('.field-invoice input').is(':checked')) {
    $('.invoice-details').hide();
  }

  $('.field-invoice input').change(function() {
    if($(this).is(':checked')) {
      $('.invoice-details').slideDown();
    } else {
      $('.invoice-details').slideUp();
    }
  });

});