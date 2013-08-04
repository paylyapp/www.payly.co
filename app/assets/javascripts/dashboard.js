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

$(function() {

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

  $('.field-more-fields').each(function() {
    var that = $(this);

    if(!$('input', that).is(':checked')) {
      that.next('.more-fields').hide();
    }

    $('input', that).change(function() {
      if($(this).is(':checked')) {
        that.next('.more-fields').slideDown();
      } else {
        that.next('.more-fields').slideUp();
      }
    });
  });

  $('.field-payment-methods').next('.more-fields').hide().next('.more-fields').hide();

  if($('.field-payment-methods input:checked').length > 0) {
    var input = $('.field-payment-methods input:checked');
    $('.more-fields[data-show="'+input.val()+'"]').show();
  }

  $('.field-payment-methods input').change(function() {
    var input = $(this);
    $('.more-fields').slideUp();
    $('.more-fields[data-show="'+input.val()+'"]').slideDown();
  });

});