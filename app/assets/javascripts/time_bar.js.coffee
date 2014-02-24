class TimeBar
  render: ->
    classAttribute = @class and " class=\"#{@class}\">" or ''
    styleAttribute = " style=\"background-color: #{@color()}\""
    @upperText  ?= ''
    @centerText ?= ''
    @lowerText  ?= ''
    "<div#{classAttribute}#{styleAttribute}>#{@upperText} #{@centerText} (#{@heightPercentage}%) #{@lowerText}</div>"

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

  color: ->
    'x'

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
  constructor: ({lane, @time, name, @fastest, @slowest}) ->
    @time    ?= 0
    @fastest ?= 0
    @slowest ?= 0
    @upperText = "Lane #{lane}"
    @centerText = @time
    @lowerText = name
    @heightPercentage = @heightForRange(@slowest + @fastest - @time, @fastest, @slowest)

  color: ->
    hueMin = 120 # green
    hueMax = 220 # blue
    percentage = if @fastest == @slowest
      1.0
    else
      (@time - @slowest) / (@fastest - @slowest)
    hue = hueMin + (hueMax - hueMin) * percentage
    "hsl(#{hue}, 71%, 41%)"


class window.PendingTimeBar extends TimeBar
  constructor: ({name: @lowerText}) ->
    @centerText = '?'
    @heightPercentage = 100

  color: ->
    '#ddd'
