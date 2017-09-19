# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
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
