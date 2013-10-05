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

  $('.field-total-amount .total').text((transactionAmount + shipping_amount).toFixed(2));

  $("input[name='transaction[transaction_amount]'], select[name='transaction[shipping_cost]']").change(function() {
    var transactionAmount = $("input[name='transaction[transaction_amount]']").val() * 1;
    var shipping_amount = $("select[name='transaction[shipping_cost]']").length > 0 ? $("select[name='transaction[shipping_cost]'] option:selected").attr("data-value") * 1 : 0;

    $('.field-total-amount .total').text((transactionAmount + shipping_amount).toFixed(2));
  });

  sameAs($('input#copy_billing_'));
});