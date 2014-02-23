class TimeBar
  render: ->
    classAttribute = " class=\"#{@class}\">" if @class
    "<div#{classAttribute or ''}>#{@upperText or ''} #{@centerText or ''} (#{@heightPercentage}%) #{@lowerText or ''}</div>"

  heightForRange: (value, rangeMin, rangeMax) ->
    minimumHeight = 20
    value = rangeMin if value < rangeMin
    value = rangeMax if value > rangeMax
    return minimumHeight + (100 - minimumHeight) * (value - rangeMin) / (rangeMax - rangeMin)

class window.StandingsTimeBar extends TimeBar
  constructor: ({name, time, place, fastest, slowest}) ->
    @upperText = name
    @centerText = @placeOrdinal(place)
    @lowerText = time
    @heightPercentage = @heightForRange(slowest + fastest - time, fastest, slowest)
    @class = @placeClass(place)

  placeOrdinal: (place) ->
    switch place
      when 1 then '1st'
      when 2 then '2nd'
      when 3 then '3rd'
      else ''

  placeClass: (place) ->
    switch place
      when 1 then 'first-place'
      when 2 then 'second-place'
      when 3 then 'third-place'
      else ''

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
