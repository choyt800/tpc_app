# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $('.sortable').sortable({
    update: (event, ui) ->
      category = $(this).data('category')
      sortedIDs = $(this).sortable('toArray')
      console.log(category)
      console.log(sortedIDs)

      $.ajax(
        method: 'PUT'
        url: '/plans/change_order'
        data:
          category: category
          sortedIDs: sortedIDs
      ).fail((msg) ->
        console.log 'ERROR: ' + msg
        return
      ).done (msg) ->
        console.log 'Data Saved: ' + msg
        return

  });
  $('.sortable').disableSelection()
