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

  $('.field-payment-methods').next('.more-fields').hide().next('.more-fields').hide().next('.more-fields').hide();

  if($('.field-payment-methods input:checked').length > 0) {
    var input = $('.field-payment-methods input:checked');
    $('.more-fields[data-show="'+input.val()+'"]').show();
  }

  $('.field-payment-methods input').change(function() {
    var input = $(this);
    $('.more-fields').slideUp();
    $('.more-fields[data-show="'+input.val()+'"]').slideDown();
  });

  $('.add-shipping').click(function() {
    $(this).parent().before('<div class="field field-full-length field-text field-shipping-details"><div class="input"><input id="stack_shipping_cost_term" name="stack[shipping_cost_term][]" size="30" value="Domestic" type="text"><input id="stack_shipping_cost_value" name="stack[shipping_cost_value][]" size="30" value="10.95" type="text"><button type="button" data-action="remove" class="remove-shipping delete-action">Delete</button></div></div>');


    $('.remove-shipping').click(function() {
      $(this).parents('.field').remove();
      return false;
    });
    return false;
  });

  $('.remove-shipping').click(function() {
    $(this).parents('.field').remove();
    return false;
  });

  // custom data
  $('.add-custom-data').click(function() {
    $custom_data_length = $('.field-custom-data').length;

    $(this).parent().before('<div class="field field-full-length field-text field-custom-data"><div class="input"><input id="stack_custom_data_term" name="stack[custom_data_term][]" placeholder="Label" size="30" type="text" value=""><label><input id="stack_custom_data_value" name="stack[custom_data_value][]" type="checkbox" value="'+$custom_data_length+'"> Required</label><button type="button" data-action="remove" class="remove-custom-data delete-action">Delete</button></div></div>');

    $('.remove-custom-data').click(function() {
      $(this).parents('.field').remove();
      $('.field-custom-data').each(function(i,n) {
        $('input[type="checkbox"]').val(i)
      });
      return false;
    });
    return false;
  });
  $('.remove-custom-data').click(function() {
    $(this).parents('.field').remove();
    $('.field-custom-data').each(function(i,n) {
      $('input[type="checkbox"]').val(i)
    });
    return false;
  });

  $('button[data-action="change-input"]').each(function() {
    if( $(this).next('input, textarea').val() !== '' ) {

      $(this).next('input, textarea').remove();

      $(this).click(function() {
        var inputType = $(this).attr('data-input-type');
        var inputId = $(this).attr('data-input-id');
        var inputName = $(this).attr('data-input-name');

        if(inputType === 'textarea') {
          $(this).after( $('<textarea></textarea>').attr('id',inputId).attr('name', inputName) );
        } else {
          $(this).after( $('<input />').attr('type', inputType).attr('id',inputId).attr('name', inputName) );
        }

        $(this).remove();
      });
    } else {
      $(this).remove();
    }
  });

  $('.add-surcharge').click(function() {
    $(this).parent().before('<div class="field field-full-length field-text field-shipping-details"><div class="input"><input id="stack_surcharge_value" name="stack[surcharge_value][]" size="30" type="number"><select id="stack_surcharge_unit" name="stack[surcharge_unit][]"><option value="percentage">%</option><option value="dollar">$AUD</option></select><button type="button" data-action="remove" class="remove-surcharge delete-action">Delete</button></div></div>');


    $('.remove-surcharge').click(function() {
      $(this).parents('.field').remove();
      return false;
    });
    return false;
  });

  $('.remove-surcharge').click(function() {
    $(this).parents('.field').remove();
    return false;
  });


  rotate_sequence();
  $.stayInWebApp();

  if($('body').hasClass('js-pp-pin_payments')) {
    var $form = $('#new_transaction'),
    $submitButton = $form.find(":submit"),
    $errors = $form.find('.card_errors');

    function handlePinResponse(response) {
      var $form = $('#new_transaction');

      if (response.response) {
        // Add the card token and ip address of the customer to the form
        // You will need to post these to Pin when creating the charge.
        $('<input>')
          .attr({type: 'hidden', name: 'transaction[card_token]'})
          .val(response.response.token)
          .appendTo($form);
        $('<input>')
          .attr({type: 'hidden', name: 'transaction[buyer_ip_address]'})
          .val(response.ip_address)
          .appendTo($form);

        // Resubmit the form
        $form.get(0).submit();

      } else {
        var $errorList = $errors.find('ul');

        $errors.find('h3').text(response.error_description);
        $errorList.empty();

        $.each(response.messages, function(index, errorMessage) {
          $('<li>').text(errorMessage.message).appendTo($errorList);
        });

        $errors.show();
        $(window).scrollTop(0);
        $submitButton.removeAttr('disabled');
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
          expiry_month: $('#card_expiry_month').val(),
          expiry_year: $('#card_expiry_year').val(),
          cvc: $('input[data-encrypted-name="cvv"]').val(),
          address_line1: $('#transaction_billing_address_line1').val(),
          address_line2: $('#transaction_billing_address_line2').val(),
          address_city: $('#transaction_billing_address_city').val(),
          address_state: $('#transaction_billing_address_state').val(),
          address_postcode: $('#transaction_billing_address_postcode').val(),
          address_country: $('#transaction_billing_address_country').val()
        };

        Pin.createToken(card, handlePinResponse);
      }
    })

    var transactionAmount = $("input[name='transaction[transaction_amount]']").val() * 1;
    var shipping_amount = $("select[name='transaction[shipping_cost]']").length > 0 ? $("select[name='transaction[shipping_cost]'] option:selected").attr("data-value") * 1 : 0;
    var surcharge = $(".field-surcharge").length > 0 ? true : false

    function chargeSurcharge() {
      var value = transactionAmount + shipping_amount;
      var modifier = $(".field-surcharge").attr('data-surcharge-value') * 1;

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
  }

  if($('body').hasClass('js-pp-stripe')) {

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

        $('<input>').attr({type: 'hidden', name: 'transaction[card_token]'}).val(token).appendTo($form);

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
          address_line1: $('#transaction_billing_address_line1').val(),
          address_line2: $('#transaction_billing_address_line2').val(),
          address_city: $('#transaction_billing_address_city').val(),
          address_state: $('#transaction_billing_address_state').val(),
          address_postcode: $('#transaction_billing_address_postcode').val(),
          address_country: $('#transaction_billing_address_country').val()
        };

        Stripe.createToken(card, handleResponse);
      }
    });

    var transactionAmount = $("input[name='transaction[transaction_amount]']").val() * 1;
    var shipping_amount = $("select[name='transaction[shipping_cost]']").length > 0 ? $("select[name='transaction[shipping_cost]'] option:selected").attr("data-value") * 1 : 0;
    var surcharge = $(".field-surcharge").length > 0 ? true : false

    function chargeSurcharge(amount) {
      var value = amount;
      var modifier = $(".field-surcharge").attr('data-surcharge-value') * 1;

      if( $(".field-surcharge").attr('data-surcharge-item') == 'percentage') {
        modifier = modifier / 100 + 1;
        value = value * modifier;
        modifier = value - amount;
      } else if( $(".field-surcharge").attr('data-surcharge-item') == 'dollar') {
        value = value + modifier;
      }

      $(".field-surcharge .total").text(modifier.toFixed(2))
      $('.field-total-amount .total').text(value.toFixed(2));
    }

    $('.field-subtotal .total, .field-total-amount .total').text((transactionAmount + shipping_amount).toFixed(2));

    if(surcharge) {
      chargeSurcharge( (transactionAmount + shipping_amount) )
    }

    $("input[name='transaction[transaction_amount]'], select[name='transaction[shipping_cost]']").change(function() {
      transactionAmount = $("input[name='transaction[transaction_amount]']").val() * 1;
      shipping_amount = $("select[name='transaction[shipping_cost]']").length > 0 ? $("select[name='transaction[shipping_cost]'] option:selected").attr("data-value") * 1 : 0;

      $('.field-subtotal .total, .field-total-amount .total').text((transactionAmount + shipping_amount).toFixed(2));

      if(surcharge) {
        chargeSurcharge( (transactionAmount + shipping_amount) )
      }
    });

    sameAs($('input#copy_billing_'));
  }

  if($('body').hasClass('js-pp-braintree')) {

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
  }

});