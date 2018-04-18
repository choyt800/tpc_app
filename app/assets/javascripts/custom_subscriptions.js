$(document).ready(function() {
  if (window.location.pathname.includes('custom_subscriptions')) {
    $("#custom_subscription_trial_period_days").datepicker({ minDate: 0, maxDate: "+6W", dateFormat: 'yy-mm-dd' });

    var allPlanInfo = JSON.parse($('#all-plan-info').attr('data-info'));
    $('#all-plan-info').data('original-plan-selects', $('.line-item[data-line-item=0]').children('.plan').children('select').html());
    $('.temporary-data').hide().append($('.line-item[data-line-item=0]').children('.plan').children('select').clone());

    var isEditPage = false;

    if (window.location.pathname.includes('edit')) {
      isEditPage = true;

      $('.custom-sub-lines').find('.line-item').each(function() {
        var line = $(this).data('line-item');
        var origPlan = $(this).find('select.plan').find('option:selected').val();
        planCategoryChange(line);
        $(this).find('select.plan').find('option[value=' + origPlan + ']').attr('selected', true);
        planChange(line);
      });
    }

    $('.custom-sub-lines, #custom_subscription_coupon').change(function() {
      $('#preview-invoice').attr('disabled', false);
      $('#create-subscription').attr('disabled', true);
    });

    $('#preview-invoice').click(function(e) {
      e.preventDefault();

      var serializedForm = {};
      $(".the-custom-sub-form").serializeArray().map(function(x){serializedForm[x.name] = x.value;});

      $('#preview-invoice').attr('disabled', true);
      $('span.discount, span.total').html('...')

      var previewURL = '/custom_subscriptions/preview'
      if (isEditPage) { previewURL = previewURL + '_update'; }

      $.ajax({
        url: previewURL,
        type: 'POST',
        data: serializedForm,
        success: function(data) {
          console.log(data)

          var sub = $('.subtotal').data('subtotal') * 100;

          if (isEditPage) {
            var total = sub;
            var discount = sub - 0;
            var date = new Date(data.next_payment_attempt * 1000);
            var dateString = date.getFullYear() + '-' + ("0" + (date.getMonth() + 1)).slice(-2) + '-' + date.getDate();

            $('span.next-invoice-date').html(dateString);
            $('span.next-invoice-amount').html('$' + (data.amount_due / 100.0).toFixed(2));
          } else {
            var total = data.amount_due;
            var discount = sub - total;
          }

          $('span.discount').html('$' + (discount / 100.0).toFixed(2));
          $('span.total').html('$' + (total / 100.0).toFixed(2));
          $('#create-subscription').attr('disabled', false);
        }
      });
    })

    $(document).on('change', 'select.quantity', function() {
      var line = $(this).parents('tr').data('line-item');
      amountChange(line);
    });

    $(document).on('change', 'select.plan-category', function() {
      var line = $(this).parents('tr').data('line-item');
      planCategoryChange(line);
    });

    $(document).on('change', 'select.plan', function() {
      var line = $(this).parents('tr').data('line-item');
      planChange(line);
    });

    $('#form-add-row').click(function(e) {
      e.preventDefault();

      handleAddRow();
    });

    $(document).on('change', '#custom_subscription_prorate', function() {
      if (this.checked) {
        $('#custom_subscription_charge_now').attr('disabled', false);
      } else {
        $('#custom_subscription_charge_now').attr('checked', false);
        $('#custom_subscription_charge_now').attr('disabled', true);
      }
    })

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

    function handleAddRow() {
      var newLineNumber = $('.custom-sub-lines').find('.line-item').length;
      var $newLine = $('.custom-sub-lines').find('.line-item:last').clone();

      $newLine.attr('data-line-item', newLineNumber);
      $.each($newLine.find("select"), function() {
        $(this).attr('name', $(this).attr('name').replace(/\d+/, newLineNumber));
        $(this).attr('id', $(this).attr('id').replace(/\d+/, newLineNumber));

        $(this).find('option').first().attr('selected', true);
      });

      $('.custom-sub-lines').find('.line-item:last').after($newLine);
      planCategoryChange(newLineNumber);
    }
  }
})
