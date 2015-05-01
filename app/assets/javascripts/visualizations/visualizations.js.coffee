###
  * Copyright (c) 2011, iSENSE Project. All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions are met:
  *
  * Redistributions of source code must retain the above copyright notice, this
  * list of conditions and the following disclaimer. Redistributions in binary
  * form must reproduce the above copyright notice, this list of conditions and
  * the following disclaimer in the documentation and/or other materials
  * provided with the distribution. Neither the name of the University of
  * Massachusetts Lowell nor the names of its contributors may be used to
  * endorse or promote products derived from this software without specific
  * prior written permission.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  * ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR
  * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
  * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  * DAMAGE.
  *
###
$ ->
  if namespace.controller is 'visualizations' and
  namespace.action in ['displayVis', 'embedVis', 'show']
    window.globals ?= {}
    globals.configs ?= {}
    globals.options ?= {}
    globals.configs.ctrlsOpen ?= true

    globals.curVis = null
    globals.VIS_MARGIN_WIDTH = 20
    globals.VIS_MARGIN_HEIGHT = 70

    ###
    CoffeeScript version of runtime.
    ###
    # Toggle control panel
    resizeVis = (toggleControls = true, aniLength = 600, init = false) ->
      newHeight = $(window).height()
      embed = globals.options? and globals.options.isEmbed?
      presentation = globals.options and globals.options.presentation?

      unless embed then newHeight -= $('.navbar').height()
      $('#vis-wrapper').height(newHeight)

      visWrapperSize = $('#vis-wrapper').innerWidth()
      visWrapperHeight = $('#vis-wrapper').outerHeight()
      visHeaderHeight = $('#vis-title-bar').outerHeight() +
        $('#vis-tab-list').outerHeight()
      controlOpac = $('#vis-ctrls').css 'opacity'
      controlSize = visWrapperSize * .2
      controlOpac = 1.0

      if init and globals.options.startCollapsed?
        globals.configs.ctrlsOpen = false

      if toggleControls and $('#vis-ctrl-container').width() > 0 or
      !globals.configs.ctrlsOpen
        controlSize = 0
        controlOpac = 0.0

      $('#ctrls-menu-btn').toggleClass('down', globals.configs.ctrlsOpen)

      # New width should take into account visibility of tools
      newWidth = visWrapperSize
      if globals.configs.ctrlsOpen then newWidth -= controlSize

      # Adjust heights
      $('#vis-container').height(visWrapperHeight)
      $('#vis-ctrl-container').height(visWrapperHeight)
      newHeight = visWrapperHeight
      unless presentation then newHeight -= visHeaderHeight
      $('#vis-container > .tab-content').height(newHeight)

      # Animate the collapsing controls and the expanding vis
      $('#vis-ctrl-container').animate({width: controlSize}, aniLength,
        'linear')
      $('#vis-ctrls').animate({width: controlSize, opacity: controlOpac},
        aniLength, 'linear')

      # Only adjust with tools are visible
      $('#vis-container').animate({width: newWidth}, aniLength, 'linear')
      globals.curVis.resize(newWidth, newHeight, aniLength)

    # Resize vis on page resize
    $(window).resize () ->
      resizeVis(false, 0)

    ### Hide all vis canvases to start ###
    $(can).hide() for can in ['#map-canvas', '#timeline-canvas',
      '#scatter-canvas', '#bar-canvas', '#histogram-canvas', '#pie-canvas',
      '#table-canvas', '#summary-canvas','#viscanvas','#photos-canvas']

    # Restore saved globals
    if data.savedGlobals?
      savedGlobals = JSON.parse(data.savedGlobals)
      savedConfigs = savedGlobals['globals']
      $.extend(globals.configs, savedConfigs)

      # Restore vis specific configs
      for visName in data.allVis
        vis  = eval "globals.#{visName.toLowerCase()}"
        if vis? and savedGlobals[visName]?
          $.extend(vis.configs, savedGlobals[visName])

      delete data.savedGlobals

    ### Set Defaults ###
    # Set defaults for grouping
    globals.configs.groupById ?= data.DATASET_NAME_FIELD
    data.setGroupIndex(globals.configs.groupById)
    data.groupSelection ?= for vals, keys in data.groups
      Number(keys)

    # Set default for logY
    globals.configs.logY ?= 0

    # Set default field selection (we use [..] syntax to indicate array)
    if data.normalFields.length > 1
      globals.configs.fieldSelection ?= data.normalFields[1..1]
    else
      globals.configs.fieldSelection ?= data.normalFields[0..0]

    ### Generate tabs ###
    for vis of data.allVis
      ctx = {}
      dark = "#{data.allVis[vis]}_dark"
      light = "#{data.allVis[vis]}_light"

      enabled = data.allVis[vis] in data.relVis
      lower = data.allVis[vis].toLowerCase()
      ctx.id = 'vis-tab-' + lower
      ctx.name = data.allVis[vis]
      ctx.canvas = lower + '-canvas'
      ctx.icon = if enabled then window.icons[dark] else window.icons[light]

      tab = HandlebarsTemplates['visualizations/vis-tab'](ctx)
      $('#vis-tab-list').append(tab)

      unless enabled
        $("#vis-tab-#{ctx.name.toLowerCase()}").addClass('strikethrough')

    ### Launch a default vis ###
    cvis = defaultVis
    globals.configs.curVis = 'globals.' + cvis
    ccanvas = cvis + '-canvas'

    # Pointer to the actual vis
    globals.curVis = eval(globals.configs.curVis)

    # Start up vis
    globals.curVis.start()

    # Highlight the starting tab
    $("#vis-tab-list a[href='##{ccanvas}']").tab('show')

    # Initialize View
    resizeVis(false, 0, true)

    ### Change vis click handler ###
    $('#vis-tab-list a').click (e) ->
      e.preventDefault()
      $(this).tab('show')

      oldVis = globals.curVis

      href = $(this).attr('href')

      start = href.indexOf('#')
      end = href.indexOf('-canvas')
      start = start + 1

      link = href.substr(start, end - start)

      globals.configs.curVis = 'globals.' + link
      globals.curVis = eval(globals.configs.curVis)

      if oldVis is globals.curVis
        return

      oldVis.end() if oldVis?
      globals.curVis.start()
      resizeVis(false, 0, true)

    $('#ctrls-menu-btn').click ->
      globals.configs.ctrlsOpen = !globals.configs.ctrlsOpen
      resizeVis()

    # Deal with full screen
    $('#fullscreen-vis').click (e) ->
      fullscreenEnabled = document.fullscreenEnabled or
        document.mozFullScreenEnabled ordocument.webkitFullscreenEnabled
      fullscreenElement = document.fullscreenElement or
        document.mozFullScreenElement or document.webkitFullscreenElement
      icon = $('#fullscreen-vis').find('i')
      if !fullscreenElement
        globals.fullscreen = true
        icon.removeClass('icon-resize-full')
        icon.addClass('icon-resize-small')
        fullscreenVis = $('#vis-container')[0]
        browserFullscreenMethod = fullscreenVis.webkitRequestFullScreen or
          fullscreenVis.mozRequestFullScreen or
          fullscreenVis.requestFullScreen or
          fullscreenVis.msRequestFullscreen
        browserFullscreenMethod.call(fullscreenVis)
      else
        globals.fullscreen = false
        icon.removeClass('icon-resize-small')
        icon.addClass('icon-resize-full')
        if document.webkitExitFullscreen
          document.webkitExitFullscreen()
        else if document.mozCancelFullScreen
          document.mozCancelFullScreen()
        else if (document.cancelFullScreen)
          document.cancelFullScreen()
        else if (document.msExitFullscreen)
          document.msExitFullscreen()

    events = 'webkitfullscreenchange mozfullscreenchange fullscreenchange'
    $(document).on events, ->
      if $('#fullscreen-vis').attr('title') == 'Maximize'
        $('#fullscreen-vis').attr('title', 'Minimize')
      else if $('#fullscreen-vis').attr('title') == 'Minimize'
        $('#fullscreen-vis').attr('title', 'Maximize')
        window.globals.fullscreen = false

      $(window).trigger('resize')

    $.fn.carousel.defaults =
      interval: false,
      pause: 'hover'


  #logging code
  if namespace.controller is 'visualizations' and namespace.action in ['show']

    #Quick and dirty get last time value in array.
    Array.prototype.last_time = () ->
      if this.length > 0
        return this[this.length-1].time
      else
        return new Date().getTime()
    
    Array.prototype.next_offset_time = (index) ->
      if this.length >= index
        return this[index].offset_time
      else
        return 0
    
    #Check if logging is turned on
    if $('#should_log').data('should_log')
      
      #Create the global logging object
      window.logging = 
        start_time: new Date().getTime()
        user_id: 1
        clicks: new Array()
      window.playing = false
      
      #Global log event function
      window.log_click_event = (e) ->
  #       console.log e
        if !playing
          time = new Date().getTime()
          target = $($(e)[0].target)

          #Create the clicks object
          click =
            time: time
            offset_time: time - logging.clicks.last_time()
            log_id: target.data('log-id')
            class_name: target.attr('class')
            id_name: target.attr('id')
            submit_time: ''
            type: e.type
            value: if e.type == 'change' then Number.parseFloat(e.originalEvent.target.value) else ''
          console.log click  
          #Add the new click to the log  
          logging['clicks'].push(click)    
      
      
#       #Add click event for clicks on anything with data-log-id set.
#       $('[data-log-id]').click (e) ->
#         log_click_event(e)
#       $('select').change (e) =>
#         log_click_event(e)
            
        
      $('#playback').click (e) ->
        playing = true
        window.scrollTo(0,0)
        alert('click to continue');
        imported = $('#imported_log_data').data('log_data')
        run = (index, max_index) =>
          item = $("[data-log-id=#{imported.clicks[index].log_id}]")
          
          type = imported.clicks[index].type
          
          if type == 'click'
            item.click()
          else if type == 'change'
            value = imported.clicks[index].value
            item.val(value)
            item.change()
          else if type == 'hover'
            evt = imported.clicks[index]
            series = evt.value.series
            point = evt.value.point
            globals.curVis.chart.series[evt.value.series].data[evt.value.point].setState('hover')
            globals.curVis.chart.tooltip.refresh(globals.curVis.chart.series[series].data[point])
          setTimeout(run, imported.clicks.next_offset_time(index), index+1, max_index)
        run(0, imported.clicks.length)

      $('#submit_logging').click (e) ->
        e.preventDefault()
        $('#log_data').val(JSON.stringify(logging))
        logging.submit_time = new Date().getTime()
        $('#logging_form').submit()

      #Clicks should be on whole div, not internal parts.
      $('.vis-ctrl-title, .vis-ctrl-icon').click (e) ->
        e.stopPropagation()
        $(this).parents('div').click()
      $('.vis-tab-child').click (e) ->
        e.stopPropagation()
        $(this).parents('a').click()
      $('i.ignore-click').click (e) ->
        e.stopPropagation()
        $(this).parents('button').click()
