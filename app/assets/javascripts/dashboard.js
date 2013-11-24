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
//= require raphael
//= require morris

$(function() {
  $.stayInWebApp();

  if($('.js-field-charge-type select').val() == "any") {
    $('.js-field-charge-amount').hide();
  }

  $('.js-field-charge-type select').change(function() {
    if($(this).val() == "any") {
      $('.js-field-charge-amount').slideUp();
    } else {
      $('.js-field-charge-amount').slideDown();
    }
  });

  $('.js-more-fields-control').each(function() {
    var that = $(this);

    if(!$('input[type="checkbox"]', that).is(':checked')) {
      $('.js-more-fields-panel[data-section="'+that.attr('data-section')+'"]').hide();
    }

    $('input[type="checkbox"]', that).change(function() {
      if($(this).is(':checked')) {
        $('.js-more-fields-panel[data-section="'+that.attr('data-section')+'"]').slideDown();
      } else {
        $('.js-more-fields-panel[data-section="'+that.attr('data-section')+'"]').slideUp();
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



  $('.js-shipping-cost-list').each(function() {
    var that = $(this);
    var shippingCostItem = $('.js-shipping-cost-item').clone();
    $('.js-shipping-cost-item').remove();

    $('.add-shipping').click(function(e) {
      e.preventDefault();
      var item = shippingCostItem.find('.field').clone();

      item.find('.remove-shipping').click(function() {
        $(this).parents('.field').remove();
        return false;
      });

      that.append(item);
    });

    $('.remove-shipping').click(function() {
      $(this).parents('.field').remove();
      return false;
    });
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

  // var m_names = new Array("Jan", "Feb", "Mar",
  // "Apr", "May", "Jun", "Jul", "Aug", "Sep",
  // "Oct", "Nov", "Dec");

  // var d = new Date();

  // new Morris.Line({
  //   // ID of the element in which to draw the chart.
  //   element: 'weekLineChart',
  //   // Chart data records -- each entry in this array corresponds to a point on
  //   // the chart.
  //   data: weeklyData,
  //   // The name of the data record attribute that contains x-values.
  //   xkey: ['date'],
  //   // A list of names of data record attributes that contain y-values.
  //   ykeys: ['count'],
  //   // Labels for the ykeys -- will be displayed when you hover over the
  //   // chart.
  //   labels: ['count'],
  //   lineColors: ['#2ECC71'],
  //   parseTime: true,
  //   hideHover: "always",
  //   xLabelFormat: function (x) {
  //     var date = new Date(x);
  //     var todayDate = new Date();
  //     var curr_date = date.getDate();
  //     var curr_month = date.getMonth();
  //     var curr_year = date.getFullYear();
  //     if (todayDate.getDate() == curr_date && todayDate.getMonth() == curr_month && todayDate.getFullYear() == curr_year ) return "Today";
  //     return curr_date + " " + m_names[curr_month];
  //   },
  //   yLabelFormat: function (y) {
  //     return '$' + y.toFixed(2).toString();
  //   }
  // });

  // new Morris.Line({
  //   // ID of the element in which to draw the chart.
  //   element: 'monthLineChart',
  //   // Chart data records -- each entry in this array corresponds to a point on
  //   // the chart.
  //   data: monthlyData,
  //   // The name of the data record attribute that contains x-values.
  //   xkey: ['date'],
  //   // A list of names of data record attributes that contain y-values.
  //   ykeys: ['count'],
  //   // Labels for the ykeys -- will be displayed when you hover over the
  //   // chart.
  //   labels: ['count'],
  //   lineColors: ['#2ECC71'],
  //   parseTime: true,
  //   hideHover: "always",
  //   xLabelFormat: function (x) {
  //     var date = new Date(x);
  //     var todayDate = new Date();
  //     var curr_date = date.getDate();
  //     var curr_month = date.getMonth();
  //     var curr_year = date.getFullYear();
  //     if (todayDate.getDate() == curr_date && todayDate.getMonth() == curr_month && todayDate.getFullYear() == curr_year ) return "<b>Today</b>";
  //     return curr_date + " " + m_names[curr_month];
  //   },
  //   yLabelFormat: function (y) {
  //     return '$' + y.toFixed(2).toString();
  //   }
  // });

});