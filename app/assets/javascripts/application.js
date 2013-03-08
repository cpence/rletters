//= require jquery
//= require jquery_ujs
//= require jquery.mobile

//= require datasets
//= require plot_dates
//= require search
//= require user
//= require word_frequency

// Configure defaults for jQuery Mobile on all pages
$(document).bind("mobileinit", function(){
  bindDatasetsEvents();
  bindPlotDatesEvents();
  bindSearchEvents();
  bindUserEvents();
  bindWordFrequencyEvents();
});

// Load up the Google Visualization API
google.load('visualization', '1.0', {'packages':['corechart']});
