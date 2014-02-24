color = /(?:#([0-9a-f]{3}){1,2}\b|hsl\(\d{1,3}, ?\d{1,3}%, ?\d{1,3}%\))/i

describe 'StandingsTimeBar', ->
  describe 'render', ->
    it 'outputs markup based on the name and time', ->
      bar = new StandingsTimeBar name: 'Bob', time: '2.222', place: 4
      expect(bar.render()).to.match /Bob.*2\.222/

    it 'sets the bar height scaled to the fastest and slowest top racers', ->
      bar = new StandingsTimeBar time: 5.0, fastest: 2.5, slowest: 5.0
      expect(bar.render()).to.match /20%/
      bar = new StandingsTimeBar time: 3.75, fastest: 2.5, slowest: 5.0
      expect(bar.render()).to.match /60%/
      bar = new StandingsTimeBar time: 2.5, fastest: 2.5, slowest: 5.0
      expect(bar.render()).to.match /100%/

    it 'notes 1st-3rd place', ->
      bar = new StandingsTimeBar time: 2.1, fastest: 2.1, slowest: 5.0, place: 1
      output = bar.render()
      expect(output).to.match /1st/         # text
      expect(output).to.match /first-place/ # css class
      bar = new StandingsTimeBar time: 2.2, fastest: 2.1, slowest: 5.0, place: 2
      output = bar.render()
      expect(output).to.match /2nd/          # text
      expect(output).to.match /second-place/ # css class
      bar = new StandingsTimeBar time: 2.3, fastest: 2.1, slowest: 5.0, place: 3
      output = bar.render()
      expect(output).to.match /3rd/         # text
      expect(output).to.match /third-place/ # css class
      bar = new StandingsTimeBar time: 5.0, fastest: 2.1, slowest: 5.0, place: 4
      output = bar.render()
      expect(output).not.to.match /-place/
      bar = new StandingsTimeBar time: 5.0, fastest: 2.1, slowest: 5.0
      output = bar.render()
      expect(output).not.to.match /-place/

    it 'assigns color based on the name', ->
      bar1 = (new StandingsTimeBar name: 'Alex G').render()
      bar2 = (new StandingsTimeBar name: 'Alex G').render()
      bar3 = (new StandingsTimeBar name: 'Alan P').render()
      expect(bar1).to.be bar2
      expect(bar1).not.to.be bar3

describe 'HeatTimeBar', ->
  describe 'render', ->
    it 'outputs markup based on the lane, time, and name', ->
      bar = new HeatTimeBar name: 'Bob', time: '2.222', lane: 2
      output = bar.render()
      expect(output).to.match /Lane 2/
      expect(output).to.match /2\.222/
      expect(output).to.match /Bob/

    it 'sets the bar height scaled to the fastest and slowest top racers', ->
      bar = new HeatTimeBar time: 10, slowest: 10, fastest: 2
      expect(bar.render()).to.match /20%/
      bar = new HeatTimeBar time: 6, slowest: 10, fastest: 2
      expect(bar.render()).to.match /60%/
      bar = new HeatTimeBar time: 2, slowest: 10, fastest: 2
      expect(bar.render()).to.match /100%/

    it 'assigns a color on a gradient based on time', ->
      bar1 = (new HeatTimeBar time: 2, slowest: 3, fastest: 2).render()
      bar2 = (new HeatTimeBar time: 2, slowest: 3, fastest: 2).render()
      bar3 = (new HeatTimeBar time: 3, slowest: 3, fastest: 2).render()
      expect(bar1).to.match color
      expect(bar2).to.match color
      expect(bar3).to.match color
      color1 = bar1.match(color)[0]
      color2 = bar2.match(color)[0]
      color3 = bar3.match(color)[0]
      expect(color1).to.be color2
      expect(color1).not.to.be color3

describe 'PendingTimeBar', ->
  describe 'render', ->
    it 'outputs markup based on the name', ->
      bar = new PendingTimeBar name: 'Bob'
      expect(bar.render()).to.contain 'Bob'

    it 'sets the bar height scaled to the fastest and slowest top racers', ->
      bar = new PendingTimeBar {}
      expect(bar.render()).to.match /100%/

    it 'is gray', ->
      bar = new PendingTimeBar {}
      gray = /#([0-9a-f]{1,2})\1\1\b/i
      expect(bar.render()).to.match gray
