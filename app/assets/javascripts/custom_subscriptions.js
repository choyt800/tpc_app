$(document).ready(function() {
  if (window.location.pathname.includes('custom_subscriptions')) {
    $("#custom_subscription_trial_period_days").datepicker({ minDate: 0, maxDate: "+6W", dateFormat: 'yy-mm-dd' });

    var allPlanInfo = JSON.parse($('#all-plan-info').attr('data-info'));
    $('#all-plan-info').data('original-plan-selects', $('.line-item[data-line-item=0]').children('.plan').children('select').html());
    $('.temporary-data').hide().append($('.line-item[data-line-item=0]').children('.plan').children('select').clone());

    $('.custom-sub-lines, #custom_subscription_coupon').change(function() {
      $('#preview-invoice').attr('disabled', false);
      $('#create-subscription').attr('disabled', true);
    });

    $('#preview-invoice').click(function(e) {
      e.preventDefault();

      var serializedForm = {};
      $("form").serializeArray().map(function(x){serializedForm[x.name] = x.value;});

      $('#preview-invoice').attr('disabled', true);
      $('span.discount, span.total').html('...')

      $.ajax({
        url: "/custom_subscriptions/preview",
        type: 'POST',
        data: serializedForm,
        success: function(data) {
          console.log(data)
          var sub = $('.subtotal').data('subtotal') * 100;
          var total = data.amount_due;
          var discount = sub - total;

          $('span.discount').html('$' + (discount / 100.0).toFixed(2));
          $('span.total').html('$' + (total / 100.0).toFixed(2));
          $('#create-subscription').attr('disabled', false);
        }
      });
    })

    $('select.quantity').change(function() {
      var line = $(this).parents('tr').data('line-item');
      amountChange(line);
    });

    $('select.plan-category').change(function() {
      var line = $(this).parents('tr').data('line-item');
      planCategoryChange(line);
    });

    $('select.plan').change(function() {
      var line = $(this).parents('tr').data('line-item');
      planChange(line);
    });

    function amountChange(line) {
      var $line = $('.line-item[data-line-item=' + line + ']');
      var qty = $line.children('.quantity').find(":selected").text();
      var rate = $line.children('.rate').data('raw-rate');
      var lineTotal = 0;
      var subTotal = 0;

      // calculate the new lineTotal
      if (qty && rate) {
        lineTotal = (qty * rate) / 100.0;
      }

      // display the new lineTotal
      $line.children('.amount').html('$' + lineTotal);

      // calculate the new subtotal
      $('.custom-sub-lines').find('.amount').each(function() {
        subTotal = subTotal + parseFloat($(this).html().replace('$', ''));
      })

      // display the new subtotal
      $('.subtotal').html('$' + subTotal);
      $('.subtotal').data('subtotal', subTotal);
    }

    function planCategoryChange(line) {
      var $line = $('.line-item[data-line-item=' + line + ']');
      var category = $line.children('.plan-category').find(':selected').text();
      var $origPlanSelects = $('.temporary-data').find('select');
      var plans = $origPlanSelects.html();

      // filter down the plans
      if (category != '') {
        var escaped_category = category.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1');
        var options = $(plans).filter("optgroup[label='" + escaped_category + "']").prepend($(plans)[0]).html();
        $line.children('.plan').children('select').html(options);
      } else {
        $line.children('.plan').children('select').html(plans);
      }
      planChange(line);
    }

    function planChange(line) {
      var $line = $('.line-item[data-line-item=' + line + ']');
      var planID = $line.find('.plan').find(":selected").attr('value');
      var $rate = $line.children('.rate')
      var plan = findPlanInInfo(planID);
      var $origPlanSelects = $('.temporary-data').find('select');

      if (planID) {
        var planIdsToDisable = findPlanIdsToDisable(plan);

        // get and set amount data
        $rate.html(plan.pretty_display);
        $rate.data('raw-rate', plan.amount);

        // disable non-interval-equivalent options in the rest of the form
        $origPlanSelects.filter(function () {
          $(this).find('option').filter(function() {
            if (planIdsToDisable.includes(parseInt($(this).attr('value')))) {
              $(this).attr('disabled', true);
            } else {
              $(this).attr('disabled', false);
            }
          });
        });

        $('.plan select').filter(function () {
          $(this).find('option').filter(function() {
            if (planIdsToDisable.includes(parseInt($(this).attr('value')))) {
              $(this).attr('disabled', true);
            } else {
              $(this).attr('disabled', false);
            }
          });
        });

      } else {
        // if everything is blank now, enable all the options
        $rate.html('$0 / month');
        $rate.removeData('raw-rate');

        if (planSelectsAreBlank()) {
          $origPlanSelects.filter(function () {
            $(this).find('option').filter(function() {
              $(this).attr('disabled', false);
            });
          });

          $('.plan select').filter(function () {
            $(this).find('option').filter(function() {
              $(this).attr('disabled', false);
            });
          });
        }
      }

      amountChange(line);
    }

    function findPlanInInfo(planID) {
      return allPlanInfo.filter(function(plan) {
        if (plan.id == planID) {
          return plan;
        }
      })[0];
    }

    function findPlanIdsToDisable(plan) {
      var tempPlanIds = [];
      allPlanInfo.filter(function(tempPlan) {
        if (!(plan.interval_count == tempPlan.interval_count && plan.interval == tempPlan.interval)) {
          tempPlanIds.push(tempPlan.id)
        }
      });
      return tempPlanIds;
    }

    function planSelectsAreBlank() {
      return $('.plan select').filter(function () {
        return $.trim($(this).val()).length == 0
      }).length == $('.plan select').length;
    }
  }
})
