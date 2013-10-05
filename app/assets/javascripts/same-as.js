/*
  sameAs is a form based plugin that helps mimic the fields of those selected

  params
  $el: the form element that must be checked

*/

function onChangeInput ($el, $input, $sameAs) {
  if ( $sameAs.is(':checked') ) {
    $($input).val( $el.val() )
  }
}

function sameAs ($el) {

  var $inputs = $('input[data-same-as-activation="'+$el.attr('name')+'"]')

  $inputs.each(function() {
    var $input = $(this)

    $('input[name="' + $input.attr('data-same-as-field') + '"]').change(function() {
      onChangeInput($(this), $input, $el)
      return true
    });
  });

  $el.change(function() {
    if($el.is(':checked') ) {
      $inputs.each(function() {
        var $input = $(this)
        $($input).val( $('input[name="' + $input.attr('data-same-as-field') + '"]').val() )
      })
    }
  })

}