class TimeBar
  render: ->
    "#{@upperText} #{@centerText} (#{@heightPercentage}%) #{@lowerText}"

  heightForRange: (value, rangeMin, rangeMax) ->
    minimumHeight = 20
    value = rangeMin if value < rangeMin
    value = rangeMax if value > rangeMax
    return minimumHeight + (100 - minimumHeight) * (value - rangeMin) / (rangeMax - rangeMin)

class window.StandingsTimeBar extends TimeBar
  constructor: ({name, time, place, fastest, slowest}) ->
    @upperText = name
    @centerText = time
    @lowerText = place
    @heightPercentage = @heightForRange(slowest + fastest - time, fastest, slowest)

  render: ->
    super()

class window.HeatTimeBar extends TimeBar
  constructor: ({lane, time, name}) ->
    @upperText = "Lane #{lane}"
    @centerText = time
    @lowerText = name
    @heightPercentage = @heightForRange(12 - time, 2, 10)

class window.PendingTimeBar extends TimeBar
  constructor: ({name: @lowerText}) ->
    @centerText = '?'
    @heightPercentage = 100
