(function(){

var $  = document.getElementById.bind(document);
var $$ = document.querySelectorAll.bind(document);

var App = function($el){
  this.$el = $el;
  this.geekMode = true;
  this.goldenAgeStart = 18;
  this.goldenAgeEnd = 55;
  this.manAvgDieAge = 75;
  this.femalAvgDieAge = 78;
  this.humanAvgDieAge = 100;
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

  var title = 'Golden Years Left';
  if(this.ageYear > this.goldenAgeEnd){
    title = 'Survival Years Left';
  };

  requestAnimationFrame(function(){
    if(this.geekMode){
      this.html(this.view('age')({
        title             : title,
        year              : majorMinorYear2base,
        milliseconds      : majorMinorMS2base,
      }));
    }else{
      this.html(this.view('age')({
        year              : majorMinorYear,
        milliseconds      : majorMinorMS,
      }));
    }
  }.bind(this));
};

App.fn.renderLifeLoading = function(){
  this.renderedAgeYear = this.ageYear;
  var ageYear = this.ageYear; 
  var goldenAgeStart = this.goldenAgeStart;
  var goldenAgeEnd = this.goldenAgeEnd;
  var manAvgDieAge = this.manAvgDieAge;
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
        "ranges":[goldenAgeStart, goldenAgeEnd, manAvgDieAge],  //Minimum, mean and maximum values.
        "rangeLabels":['Die','Golden Age End','Golden Age Start'],
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
