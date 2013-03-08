
// Bind all of our various event handlers
$(document).on("mobileinit", function() {
  bindDatasetsEvents();
  bindPlotDatesEvents();
  bindSearchEvents();
  bindUserEvents();
  bindWordFrequencyEvents();  
});
