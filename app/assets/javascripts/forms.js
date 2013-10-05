
$.validator.setDefaults(
  {
    ignore: '.ignore'
  , errorElement: 'span'
  , onkeyup: false
  , errorPlacement: function(error, element) {
      if( !$(element).parents('.field').find('.error-text--' + error[0].innerHTML).is(':visible') ) {
        $(element).parents('.field').removeClass('field-error').find('.field-error-text').hide()
        $(element).parents('.field').addClass('field-error').find('.error-text--' + error[0].innerHTML).css('display','block')
      }
    }
  , unhighlight: function(element) {
      $(element).parents('.field').removeClass('field-error').find('.field-error-text').hide()
    }
  }
)

// Extend messages to reduce to the keyword
$.extend(
  $.validator.messages, {
    required: "required"
  , remote: "remote"
  , email: "email"
  , url: "url"
  , date: "date"
  , dateISO: "dateISO"
  , number: "number"
  , digits: "digits"
  , creditcard: "creditcard"
  , equalTo: "equalTo"
  , maxlength: "maxlength"
  , minlength: "minlength"
  , rangelength: "rangelength"
  , range: "range"
  , max: "max"
  , min: "min"
  }
)

// validate all forms
$('form').each(function() {
  $(this).validate()


})