# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  if window.location.href.indexOf("keycard_checkouts") >= 0
    handle_plan_category_change()
    $('#keycard_checkout_payment_type').change ->
      payment_type_conditional()

payment_type_conditional = ->
  payment_type = $('#keycard_checkout_payment_type :selected').text()
  if payment_type == 'Stripe'
    $('#keycard_checkout_deposit').parent().removeClass('hidden');
  else
    $('#keycard_checkout_deposit').parent().addClass('hidden');

handle_plan_category_change = ->
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

    if category == 'Non-Stripe'
      $('#membership_payment_type option[value="Stripe"]').attr('disabled', 'disabled')
    else
      $('#membership_payment_type option[value="Stripe"]').removeAttr('disabled')
