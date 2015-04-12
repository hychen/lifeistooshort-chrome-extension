(function(){

var $  = document.getElementById.bind(document);
var $$ = document.querySelectorAll.bind(document);

var App = function($el){
  this.$el = $el;
  this.geekMode = false;
  this.YouthAgeEnd = 22;
  this.goldenAgeEnd = 55;
  this.manAvgDieAge = 75;
  this.femalAvgDieAge = 78;
  this.humanAvgDieAge = 100;
  this.quotes = [
    "What are 3 things that are going well until now?",
    "What are 3 things that could improve until now?",
    "If this were next year, what are three things you want to be different?",
    "If this were the end of your life, what are three things you want to be different?",
    "Have you found joy in your life?", 
    "Has your life brought joy to others?",
    "What level do you want to reach in your career?",
    "How much do you want to earn, by what stage? How is this related to your career goals?",
    "Is there any knowledge you want to acquire in particular?"
  
  ];
  this.randomQuote = _.random(0, this.quotes.length - 1);

  this.load();

  this.$el.addEventListener(
    'submit', this.submit.bind(this)
  );

  if (this.dob) {
    this.renderAgeLoop();
  } else {
    this.renderChoose();
  }
};

App.fn = App.prototype;

App.fn.load = function(){
  var value;

  if (value = localStorage.dob)
    this.dob = new Date(parseInt(value));
};

App.fn.save = function(){
  if (this.dob)
    localStorage.dob = this.dob.getTime();
};

App.fn.submit = function(e){
  e.preventDefault();

  var input = this.$$('input')[0];
  if ( !input.valueAsDate ) return;

  this.dob = input.valueAsDate;
  this.save();
  this.renderAgeLoop();
};

App.fn.renderChoose = function(){
  this.html(this.view('dob')());
};

App.fn.renderAgeLoop = function(){
  window.addEventListener('updateAge', this.renderLifeLoading.bind(this));
  this.interval = setInterval(this.renderAge.bind(this), 100);
};

App.fn.renderAge = function(){
  // career golden age.
  this.renderdAge = null;
  var geekMode  = this.geekMode;
  var now       = new Date
  var duration  = now - this.dob;
  var age       = (duration / 31556900000);
  var years     = this.goldenAgeEnd - age;
  var majorMinor = years.toFixed(9).toString().split('.');
  var majorMinorYear = majorMinor[0];
  var majorMinorMS = majorMinor[1];
  var majorMinorYear2base = parseInt(majorMinorYear).toString(2);
  var majorMinorMS2base = parseInt(majorMinorMS).toString(2);

  this.ageYear = age.toString().split('.')[0];
  if(this.renderedAgeYear != null && this.ageYear != this.renderedAgeYear){
    // redraw the life loading chart.
    window.dispatchEvent(new Event('updateAge'));
  }
  else if(!this.renderedAgeYear){
    window.dispatchEvent(new Event('updateAge'));
  }

  var title = 'Younth Years Left';
  if(this.YouthAgeEnd < this.ageYear && this.ageYear < this.goldenAgeEnd){
    title = 'Golden Years Left';
  }else if(this.ageYear > this.goldenAgeEnd){
    title = 'Survival Years Left';
  };

  requestAnimationFrame(function(){
    if(this.geekMode){
      this.html(this.view('age')({
        title             : title,
        year              : majorMinorYear2base,
        milliseconds      : majorMinorMS2base,
        quote             : this.quotes[this.randomQuote],
      }));
    }else{
      this.html(this.view('age')({
        title             : title,
        year              : majorMinorYear,
        milliseconds      : majorMinorMS,
        quote             : this.quotes[this.randomQuote],
      }));
    }
  }.bind(this));
};

App.fn.renderLifeLoading = function(){
  this.renderedAgeYear = this.ageYear;
  var ageYear = this.ageYear;
  var YouthAgeEnd = this.YouthAgeEnd;
  var goldenAgeEnd = this.goldenAgeEnd;
  var LifeEnd = this.manAvgDieAge;
  nv.addGraph(function() {
    var chart = nv.models.bulletChart();

    d3.select('#chart svg')
      .datum(exampleData())
      .transition().duration(1000)
      .call(chart);

    return chart;
  });

  function exampleData() {
    return {
        "ranges":[YouthAgeEnd, goldenAgeEnd, LifeEnd],  //Minimum, mean and maximum values.
        "rangeLabels":['Life End','Golden Age End','Youth Age End'],
        "measures":[ageYear],         //Value representing current measurement (the thick blue line in the example)
        "measureLabels":['Current Age'],
    };
  }
};

App.fn.$$ = function(sel){
  return this.$el.querySelectorAll(sel);
};

App.fn.html = function(html){
  this.$el.innerHTML = html;
};

App.fn.view = function(name){
  var $el = $(name + '-template');
  return Handlebars.compile($el.innerHTML);
};

window.app = new App($('app'))

})();
