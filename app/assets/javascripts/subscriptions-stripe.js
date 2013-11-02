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

  // Firstly, set the publishable key
  //
  // This can either be your live publishable key or test publishable key, depending
  // on which script you included above

  // Now we can call Pin.js on form submission to retrieve a card token and submit
  // it to the server

  var $form = $('#new_transaction'),
      $errors = $form.find('.payment-errors'),
      $submitButton = $form.find(":submit");

  function handleResponse(status, response) {
    var $form = $('#new_transaction');

    if (response.error) {
      // Show the errors on the form
      $errors.text(response.error.message);
      $form.find('button').prop('disabled', false);
    } else {
      var token = response.id;

      $('<input>').attr({type: 'hidden', name: 'subscription[card_token]'}).val(token).appendTo($form);

      $form.get(0).submit();
    }
  }

  $form.submit(function(e) {
    if($form.valid()) {
      e.preventDefault();
      $errors.hide();

      $submitButton.attr({disabled: true});

      var card = {
        name: $('#card_name').val(),
        number: $('input[data-encrypted-name="number"]').val(),
        exp_month: $('#card_expiry_month').val(),
        exp_year: $('#card_expiry_year').val(),
        cvc: $('input[data-encrypted-name="cvv"]').val(),
        address_line1: $('#transaction_billling_address_line1').val(),
        address_line2: $('#transaction_billling_address_line2').val(),
        address_city: $('#transaction_billling_address_city').val(),
        address_state: $('#transaction_billling_address_state').val(),
        address_postcode: $('#transaction_billling_address_postcode').val(),
        address_country: $('#transaction_billing_address_country').val()
      };

      Stripe.createToken(card, handleResponse);
    }
  });

  //move this into a submit handler for this form
  var transactionAmount = $("input[name='subscription[transaction_amount]']").val() * 1;
  var shipping_amount = $("select[name='subscription[shipping_cost]']").length > 0 ? $("select[name='subscription[shipping_cost]'] option:selected").attr("data-value") * 1 : 0;

  $('.field-total-amount .total').text((transactionAmount + shipping_amount).toFixed(2));

  $("input[name='subscription[transaction_amount]'], select[name='subscription[shipping_cost]']").change(function() {
    var transactionAmount = $("input[name='subscription[transaction_amount]']").val() * 1;
    var shipping_amount = $("select[name='subscription[shipping_cost]']").length > 0 ? $("select[name='subscription[shipping_cost]'] option:selected").attr("data-value") * 1 : 0;

    $('.field-total-amount .total').text((transactionAmount + shipping_amount).toFixed(2));
  });

  sameAs($('input#copy_billing_'));
});
