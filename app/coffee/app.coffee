'use strict'

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
    @monthChartData =
      ranges: [
        10
        20
        moment().endOf('month').format('DD')
      ]
      rangeLabels: [
        "Late of Month"
        "Middle of Month"
        "Early of Month"
      ]
      'measures': [moment().format('DD')]
      'measureLabels': [ 'Current Day' ]
    @currentMonthLabel = moment().format('MMM')

    @randomQuote = _.random(0, @quotes.length - 1)
    do @load
    @$el.addEventListener 'submit', @submit.bind(this)
    if @dob
      do @renderAgeLoop
    else
      do @renderChoose
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
    if not input.valueAsDate
      return
    @dob = input.valueAsDate
    do @save
    do @renderAgeLoop
    return

  App.fn.renderChoose = ->
    @html @view('dob')()
    return

  App.fn.renderAgeLoop = ->
    window.addEventListener 'updateAge', @renderLifeLoading.bind(this)
    @interval = setInterval(@renderAge.bind(this), 100)
    return

  App.fn.renderMonthLoop = ->
    #window.addEventListener 'updateMonth', @renderLifeLoading.bind(this)
    @interval = setInterval(@renderMonthText.bind(this), 100)

    @renderChart 'month-chart', @monthChartData

  App.fn.renderMonthText = ->
    now = do moment
    currentMonth = moment().endOf 'month'
    remainingD = currentMonth.diff now, 'days'
    remainingMS = currentMonth.diff now
    title = "Days in #{@currentMonthLabel} Left"

    requestAnimationFrame ( ->
      @updateView 'month-bar', Handlebars.compile($('month-template').innerHTML)(
        title: title
        days: remainingD
        milliseconds: remainingMS
      )
    ).bind(this)

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
    if @renderedAgeYear isnt null and @ageYear isnt @renderedAgeYear
      # redraw the life loading chart.
      window.dispatchEvent new Event('updateAge')
    else if !@renderedAgeYear
      window.dispatchEvent new Event('updateAge')
    title = 'Youth Years Left'
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

  App.fn.renderChart = (id, data) ->
    nv.addGraph ->
      chart = nv.models.bulletChart()
      d3.select("#month-chart svg")
        .datum(data)
        .transition()
        .duration(1000)
        .call chart
      chart

  App.fn.$$ = (sel) ->
    @$el.querySelectorAll sel

  App.fn.html = (html) ->
    @$el.innerHTML = html

  App.fn.view = (name) ->
    $el = $(name + '-template')
    Handlebars.compile $el.innerHTML

  App.fn.updateView = (id, html) ->
    $(id).innerHTML = html

  window.app = new App($('app'))
  do app.renderMonthLoop

  return
