class window.Announcer
  constructor: (options) ->
    @callbacks = [@renderDashboard]
    @renderFunction = switch options.type
      when 'dashboard' then @render
      else                  @renderNotice
    @renderFunction(options.stats) if options.stats
    @connect()

  connect: ->
    @faye = window.faye = new Faye.Client '/faye', timeout: 5
    @faye.subscribe '/announce', (stats) =>
      console.log '/announce: ', stats
      @renderFunction JSON.parse(stats)

  render: (stats) ->
    callback.call(@, stats) for callback in @callbacks

  renderDashboard: (stats) ->
    @notifyOfChange() if @alreadyRendered
    @alreadyRendered = true
    @dashboard = $('#dashboard')
    return unless @dashboard.length
    @renderStandings      stats.contestant_times
    @renderMostRecentHeat stats.most_recent_heat
    @renderUpcomingHeats  stats.upcoming_heats
    @renderNotice         stats

  renderStandings: (contestant_times) ->
    container = @dashboard.find('#standings')
    standings = for contestant in contestant_times
      "<div class='contestant'>" +
      "  <div class='name span2'>#{contestant.rank}</div>" +
      "  <div class='name span7'>#{contestant.name}</div>" +
      "  <div class='time span3'>#{contestant.average_time}</div>" +
      "</div>"
    if standings.length
      container.show().find('.contestants').html standings.join('\n')
    else
      container.hide()

  renderMostRecentHeat: (most_recent_heat) ->
    container = @dashboard.find('#most-recent-heat')
    container.find('.name, .time').html('')
    for run in most_recent_heat
      lane = container.find(".lane#{run.lane}")
      lane.find('.name').html(run.name)
      lane.find('.time').html(run.time)
    if most_recent_heat.length
      container.show()
    else
      container.hide()

  renderUpcomingHeats: (upcoming_heats) ->
    container = @dashboard.find('#upcoming-heats')
    if upcoming_heats.length
      container.show()
    else
      container.hide()
    container.find('.name').html('')
    upcoming_counter = 0
    for heat in upcoming_heats
      upcoming_counter++
      heat_container = container.find(".next#{upcoming_counter}")
      if heat.current
        heat_container.addClass('current-race btn-success')
      else
        heat_container.removeClass('current-race btn-success')
      for contestant in heat.contestants
        slot = heat_container.find(".lane#{contestant.lane}")
        if contestant.postponable
          contestant_link = "<a href='/runs/#{contestant.run_id}/postpone' class='postponable'>#{contestant.name}</a>"
          slot.html contestant_link
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

  notifyOfChange: ->
    $("body").stop().css("background-color", "#FFFF7C").animate({ backgroundColor: "#FFFFFF"}, 500)
