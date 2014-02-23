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

    it 'assigns color based on the place'

describe 'HeatTimeBar', ->
  describe 'render', ->
    it 'outputs markup based on the lane, time, and name', ->
      bar = new HeatTimeBar name: 'Bob', time: '2.222', lane: 2
      output = bar.render()
      expect(output).to.match /Lane 2/
      expect(output).to.match /2\.222/
      expect(output).to.match /Bob/

    it 'sets the bar height scaled to the fastest and slowest top racers', ->
      bar = new HeatTimeBar time: 10
      expect(bar.render()).to.match /20%/
      bar = new HeatTimeBar time: 6
      expect(bar.render()).to.match /60%/
      bar = new HeatTimeBar time: 2
      expect(bar.render()).to.match /100%/

    it 'notes 1st-3rd place'

    it 'assigns a color on a gradient based on time'

describe 'PendingTimeBar', ->
  describe 'render', ->
    it 'outputs markup based on the name', ->
      bar = new PendingTimeBar name: 'Bob'
      expect(bar.render()).to.contain 'Bob'

    it 'sets the bar height scaled to the fastest and slowest top racers', ->
      bar = new PendingTimeBar {}
      expect(bar.render()).to.match /100%/

    it 'is gray'
