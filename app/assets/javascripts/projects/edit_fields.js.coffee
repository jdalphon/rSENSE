$ ->
  if namespace.controller is "projects" and namespace.action is "edit_fields"
    
    ###
    # Controls for uploading template file.
    ###
    ($ '#template_file_upload').click ->
      ($ '#template_file_input').click()
      false
    ($ '#template_file_input').change ->
      ($ '#template_file_form').submit()
    
    ###
    # Switch to manual entry view
    ###
    ($ '#set_up_manually').click () ->
      ($ '.field_edit_options').hide()
      ($ '#manual_setup').show()
    
    
    ($ '#new_field').change ->
      ($ '#fields_form_submit').click()

    ($ '#fields_table').keypress (e) ->
      code = e.keyCode || e.which
      if code == 13
        e.preventDefault()
        ($ '#fields_form_submit').click()
      
    ($ '.field_delete').click (e) ->
      e.preventDefault()
      root = ($ @).parents('tr')
      $.ajax
        url: ($ @).attr('href')
        dataType: 'json'
        type: 'DELETE'
        data:
          field: ($ @).attr('fid')
        success: (msg) ->
          if root.hasClass('location')
            root.parents('table').find('tr.location').each ->
              ($ this).remove()
          else
            root.remove()
        error:(msg) ->
          console.log msg
