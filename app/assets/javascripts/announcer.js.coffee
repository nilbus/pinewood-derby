class window.Announcer
  constructor: (options) ->
    @admin = options.admin
    @callbacks = [@renderDashboard]
    @renderFunction = switch options.type
      when 'dashboard' then @render
      else                  @renderNotice
    @renderFunction(options.stats) if options.stats
    @connect()
    @initializeDomEvents()

  initializeDomEvents: ->
    @initializeButtonClickWithRender
      selector: '#start-race'
      url: '/races/new'
      method: 'get'
      replacementText: 'Starting…'
    @initializeButtonClickWithRender
      selector: '#redo'
      url: '/races/redo'
      method: 'put'
      replacementText: 'redoing…'
    @initializeButtonClickWithRender
      selector: '.cancel-heat'
      url: '/heats/cancel_current'
      method: 'post'
      click: (event) -> $(event.target).css(opacity: 0)
    @initializeHoverEventsForCancelHeat()

  initializeButtonClickWithRender: (options) ->
    button = $(options.selector)
    button.click (event) =>
      event.preventDefault()
      return if options.click?(event) == false
      @ajaxLoadingButton button, options.replacementText, (doneLoadingCallback) =>
        $.ajax
          url: options.url
          method: options.method || 'POST'
          dataType: 'json'
          success: (json) =>
            @renderFunction(json)
            doneLoadingCallback()

  ajaxLoadingButton: (button, replacementText, clickHandler) ->
    button = $(button)
    return console.log 'Ignored click while loading' if button.data 'loading'
    button.data 'loading', true
    button.data 'originalText', button.text() unless button.data 'originalText'
    doneLoadingCallback = ->
      button.text button.data 'originalText'
      button.data 'loading', false
    clickHandler(doneLoadingCallback)
    button.text(replacementText) if replacementText

  initializeHoverEventsForCancelHeat: ->
    hoverTargets = '.current-race,.cancel-heat'
    cancelHeatButton = $('.cancel-heat')
    $(document).on 'mouseenter', hoverTargets, ->
      cancelHeatButton.css(opacity: 1, cursor: 'pointer') if $('.current-race').length
    $(document).on 'mouseleave', hoverTargets, ->
      cancelHeatButton.css(opacity: 0, cursor: 'default')

  connect: ->
    @faye = window.faye = new Faye.Client '/faye', timeout: 30
    @faye.subscribe '/announce', (stats) =>
      console.log '/announce: ', stats
      @renderFunction JSON.parse(stats)

  render: (stats) ->
    callback.call(@, stats) for callback in @callbacks

  renderDashboard: (stats) ->
    return if @renderEquivalent(stats, @lastRenderedStats)
    @lastRenderedStats = stats
    @notifyOfChange() if @alreadyRendered
    @alreadyRendered = true
    @dashboard = $('#dashboard')
    return unless @dashboard.length
    @renderStandings      stats.contestant_times
    @renderMostRecentHeat stats.most_recent_heat
    @renderUpcomingHeats  stats.upcoming_heats
    @renderNotice         stats

  renderEquivalent: (stats1, stats2) ->
    stats1 = $.extend({}, stats1)
    stats2 = $.extend({}, stats2)
    for stats in [stats1, stats2]
      stats.device_status = null
      for heat in stats.upcoming_heats || []
        for contestant in heat.contestants || []
          contestant.run_id = null
    console.log('checking', window.s1=stats1, window.s2=stats2, _.isEqual(stats1, stats2))
    _.isEqual(stats1, stats2)

  renderStandings: (contestantTimes) ->
    container = @dashboard.find('#standings')
    standings = for contestant in contestantTimes
      "<div class='contestant'>" +
      "  <div class='name span2'>#{contestant.rank}</div>" +
      "  <div class='name span7'>#{contestant.name}</div>" +
      "  <div class='time span3'>#{contestant.average_time}</div>" +
      "</div>"
    if standings.length
      container.show().find('.contestants').html standings.join('\n')
    else
      container.hide()

  renderMostRecentHeat: (mostRecentHeat) ->
    container = @dashboard.find('#most-recent-heat')
    container.find('.name, .time').html('')
    for run in mostRecentHeat
      lane = container.find(".lane#{run.lane}")
      lane.find('.name').html(run.name)
      lane.find('.time').html(run.time)
    if mostRecentHeat.length
      container.show()
    else
      container.hide()

  renderUpcomingHeats: (upcomingHeats) ->
    container = @dashboard.find('#upcoming-heats')
    if upcomingHeats.length
      container.show()
    else
      container.hide()
    container.find('.name').html('')
    upcomingCounter = 0
    for heat in upcomingHeats
      upcomingCounter++
      heatContainer = container.find(".next#{upcomingCounter}")
      if heat.current
        heatContainer.addClass('current-race btn-success')
      else
        heatContainer.removeClass('current-race btn-success')
      for contestant in heat.contestants
        slot = heatContainer.find(".lane#{contestant.lane}")
        if contestant.postponable and @admin
          contestantLink = "<a href='/runs/#{contestant.run_id}/postpone' class='postponable' title='postpone'>#{contestant.name}</a>"
          slot.html contestantLink
        else
          slot.html contestant.name

  renderNotice: (stats) ->
    {notice, device_status} = stats
    if notice
      $('#faye-notification').show().html notice
    else
      $('#faye-notification').hide()
    if device_status == 'idle'
      $('#start-race,#redo').show()
    else
      $('#start-race,#redo').hide()
    if stats.derby_status == 'begin' && window.location.pathname == '/'
      window.location.href = '/board'

  notifyOfChange: ->
    $("body").stop().css("background-color", "#FFFF7C").animate({ backgroundColor: "#FFFFFF"}, 500)
