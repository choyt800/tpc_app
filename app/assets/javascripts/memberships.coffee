# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $(document).ready ->
    $('#membership_plan_id').parent().hide()
    plans = $('#membership_plan_id').html()
    $('#membership_plan_category_id').change ->
      category = $('#membership_plan_category_id :selected').text()
      escaped_category = category.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1')
      options = $(plans).filter("optgroup[label='#{escaped_category}']").html()
      if options
        $('#membership_plan_id').html(options)
        $('#membership_plan_id').parent().show()
      else
        $('#membership_plan_id').empty()
        $('#membership_plan_id').parent().hide()

    $('#membership_payment_type').change ->
      payment_type = $('#membership_payment_type :selected').text()
      if payment_type == 'Stripe'
        # Show trial period days
        # Hide average_monthly_payment
        $('#membership_trial_period_days').parent().removeClass('hidden');
        $('#membership_coupon').parent().removeClass('hidden');
        $('#membership_average_monthly_payment').parent().addClass('hidden');
      else
        # Hide trial period days
        # Show average_monthly_payment
        $('#membership_trial_period_days').parent().addClass('hidden');
        $('#membership_coupon').parent().addClass('hidden');
        $('#membership_average_monthly_payment').parent().removeClass('hidden');
