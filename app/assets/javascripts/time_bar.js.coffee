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
  constructor: ({@name, time, place, fastest, slowest}) ->
    @name ?= ''
    time    = Number(time)
    fastest = Number(fastest)
    slowest = Number(slowest)
    @upperText = @name
    @centerText = @placeOrdinal(place)
    @lowerText = time
    @heightPercentage = @heightForRange(slowest + fastest - time, fastest, slowest)
    @class = @placeClass(place)

  colors: [
    "AliceBlue", "AntiqueWhite", "Aqua", "Aquamarine", "Azure", "Beige",
    "Bisque", "Black", "BlanchedAlmond", "Blue", "BlueViolet", "Brown",
    "BurlyWood", "CadetBlue", "Chartreuse", "Chocolate", "Coral",
    "CornflowerBlue", "Cornsilk", "Crimson", "Cyan", "DarkBlue", "DarkCyan",
    "DarkGoldenRod", "DarkGray", "DarkGreen", "DarkKhaki", "DarkMagenta",
    "DarkOliveGreen", "DarkOrange", "DarkOrchid", "DarkRed", "DarkSalmon",
    "DarkSeaGreen", "DarkSlateBlue", "DarkSlateGray", "DarkTurquoise",
    "DarkViolet", "DeepPink", "DeepSkyBlue", "DimGray", "DodgerBlue",
    "FireBrick", "FloralWhite", "ForestGreen", "Fuchsia", "Gainsboro",
    "GhostWhite", "Gold", "GoldenRod", "Gray", "Green", "GreenYellow",
    "HoneyDew", "HotPink", "IndianRed ", "Indigo", "Ivory", "Khaki",
    "Lavender", "LavenderBlush", "LawnGreen", "LemonChiffon", "LightBlue",
    "LightCoral", "LightCyan", "LightGoldenRodYellow", "LightGray",
    "LightGreen", "LightPink", "LightSalmon", "LightSeaGreen", "LightSkyBlue",
    "LightSlateGray", "LightSteelBlue", "LightYellow", "Lime", "LimeGreen",
    "Linen", "Magenta", "Maroon", "MediumAquaMarine", "MediumBlue",
    "MediumOrchid", "MediumPurple", "MediumSeaGreen", "MediumSlateBlue",
    "MediumSpringGreen", "MediumTurquoise", "MediumVioletRed", "MidnightBlue",
    "MintCream", "MistyRose", "Moccasin", "NavajoWhite", "Navy", "OldLace",
    "Olive", "OliveDrab", "Orange", "OrangeRed", "Orchid", "PaleGoldenRod",
    "PaleGreen", "PaleTurquoise", "PaleVioletRed", "PapayaWhip", "PeachPuff",
    "Peru", "Pink", "Plum", "PowderBlue", "Purple", "Red", "RosyBrown",
    "RoyalBlue", "SaddleBrown", "Salmon", "SandyBrown", "SeaGreen", "SeaShell",
    "Sienna", "Silver", "SkyBlue", "SlateBlue", "SlateGray", "Snow",
    "SpringGreen", "SteelBlue", "Tan", "Teal", "Thistle", "Tomato",
    "Turquoise", "Violet", "Wheat", "White", "WhiteSmoke", "Yellow",
    "YellowGreen"
  ]

  hash = (str) ->
    val = 0
    for i in [0...str.length]
      val += str.charCodeAt i
    val

  color: ->
    @colors[hash(@name) % @colors.length]

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
    @time    = Number(@time)
    @fastest = Number(@fastest)
    @slowest = Number(@slowest)
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
