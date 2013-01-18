$ ->
  $('#contestant_name').focus()
  $('#contestants').on 'hover', '.contestant:has(.retire)', (event) ->
    if event.type == 'mouseenter'
      $(this).find('.retire').show()
    else
      $(this).find('.retire').hide()
