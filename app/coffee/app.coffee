do ->
  $ = document.getElementById.bind(document)
  $$ = document.querySelectorAll.bind(document)

  App = ($el) ->
    @$el = $el
    @geekMode = false
    @YouthAgeEnd = 22
    @goldenAgeEnd = 55
    @manAvgDieAge = 75
    @femalAvgDieAge = 78
    @humanAvgDieAge = 100
    @quotes = [
      'What are 3 things that are going well until now?'
      'What are 3 things that could improve until now?'
      'If this were next year, what are three things you want to be different?'
      'If this were the end of your life, what are three things you want to be different?'
      'Have you found joy in your life?'
      'Has your life brought joy to others?'
      'What level do you want to reach in your career?'
      'How much do you want to earn, by what stage? How is this related to your career goals?'
      'Is there any knowledge you want to acquire in particular?'
    ]
    @randomQuote = _.random(0, @quotes.length - 1)
    @load()
    @$el.addEventListener 'submit', @submit.bind(this)
    if @dob
      @renderAgeLoop()
    else
      @renderChoose()
    return

  App.fn = App.prototype

  App.fn.load = ->
    value = undefined
    if value = localStorage.dob
      @dob = new Date(parseInt(value))
    return

  App.fn.save = ->
    if @dob
      localStorage.dob = @dob.getTime()
    return

  App.fn.submit = (e) ->
    e.preventDefault()
    input = @$$('input')[0]
    if !input.valueAsDate
      return
    @dob = input.valueAsDate
    @save()
    @renderAgeLoop()
    return

  App.fn.renderChoose = ->
    @html @view('dob')()
    return

  App.fn.renderAgeLoop = ->
    window.addEventListener 'updateAge', @renderLifeLoading.bind(this)
    @interval = setInterval(@renderAge.bind(this), 100)
    return

  App.fn.renderAge = ->
    # career golden age.
    @renderdAge = null
    geekMode = @geekMode
    now = new Date
    duration = now - @dob
    age = duration / 31556900000
    years = @goldenAgeEnd - age
    majorMinor = years.toFixed(9).toString().split('.')
    majorMinorYear = majorMinor[0]
    majorMinorMS = majorMinor[1]
    majorMinorYear2base = parseInt(majorMinorYear).toString(2)
    majorMinorMS2base = parseInt(majorMinorMS).toString(2)
    @ageYear = age.toString().split('.')[0]
    if @renderedAgeYear != null and @ageYear != @renderedAgeYear
      # redraw the life loading chart.
      window.dispatchEvent new Event('updateAge')
    else if !@renderedAgeYear
      window.dispatchEvent new Event('updateAge')
    title = 'Younth Years Left'
    if @YouthAgeEnd < @ageYear and @ageYear < @goldenAgeEnd
      title = 'Golden Years Left'
    else if @ageYear > @goldenAgeEnd
      title = 'Survival Years Left'
    requestAnimationFrame (->
      if @geekMode
        @html @view('age')(
          title: title
          year: majorMinorYear2base
          milliseconds: majorMinorMS2base
          quote: @quotes[@randomQuote])
      else
        @html @view('age')(
          title: title
          year: majorMinorYear
          milliseconds: majorMinorMS
          quote: @quotes[@randomQuote])
      return
    ).bind(this)
    return

  App.fn.renderLifeLoading = ->

    exampleData = ->
      {
        'ranges': [
          YouthAgeEnd
          goldenAgeEnd
          LifeEnd
        ]
        'rangeLabels': [
          'Life End'
          'Golden Age End'
          'Youth Age End'
        ]
        'measures': [ ageYear ]
        'measureLabels': [ 'Current Age' ]
      }

    @renderedAgeYear = @ageYear
    ageYear = @ageYear
    YouthAgeEnd = @YouthAgeEnd
    goldenAgeEnd = @goldenAgeEnd
    LifeEnd = @manAvgDieAge
    nv.addGraph ->
      chart = nv.models.bulletChart()
      d3.select('#chart svg').datum(exampleData()).transition().duration(1000).call chart
      chart
    return

  App.fn.$$ = (sel) ->
    @$el.querySelectorAll sel

  App.fn.html = (html) ->
    @$el.innerHTML = html
    return

  App.fn.view = (name) ->
    $el = $(name + '-template')
    Handlebars.compile $el.innerHTML

  window.app = new App($('app'))
  return
