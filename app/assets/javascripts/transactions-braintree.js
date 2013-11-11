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
//= require jquery.siwa.min
//= require jquery.validate
//= require forms
//= require same-as

$(function() {
  $.stayInWebApp();

  var transactionAmount = $("input[name='transaction[transaction_amount]']").val() * 1;
  var shipping_amount = $("select[name='transaction[shipping_cost]']").length > 0 ? $("select[name='transaction[shipping_cost]'] option:selected").attr("data-value") * 1 : 0;
  var surcharge = $(".field-surcharge").length > 0 ? true : false

  function chargeSurcharge() {
    var value = transactionAmount + shipping_amount;
    var modifier = $(".field-surcharge").attr('data-surcharge-value');

    if( $(".field-surcharge").attr('data-surcharge-item') == 'percentage') {
      modifier = modifier / 100 + 1
      value = value * modifier
      modifier = value - (transactionAmount + shipping_amount)
    } else if( $(".field-surcharge").attr('data-surcharge-item') == 'dollar') {
      value = value + modifier
    }

    $(".field-surcharge .total").text(modifier.toFixed(2))
    $('.field-total-amount .total').text(value.toFixed(2));
  }

  $('.field-subtotal .total, .field-total-amount .total').text((transactionAmount + shipping_amount).toFixed(2));

  if(surcharge) {
    chargeSurcharge()
  }

  $("input[name='transaction[transaction_amount]'], select[name='transaction[shipping_cost]']").change(function() {
    transactionAmount = $("input[name='transaction[transaction_amount]']").val() * 1;
    shipping_amount = $("select[name='transaction[shipping_cost]']").length > 0 ? $("select[name='transaction[shipping_cost]'] option:selected").attr("data-value") * 1 : 0;

    $('.field-subtotal .total, .field-total-amount .total').text((transactionAmount + shipping_amount).toFixed(2));

    if(surcharge) {
      chargeSurcharge()
    }
  });

  sameAs($('input#copy_billing_'));
});