
// Bind all of our various event handlers
$(document).on("mobileinit", function() {
  bindDatasetsEvents();
  bindNormalizeDocumentCountsEvents();
  bindPlotDatesEvents();
  bindSearchEvents();
  bindUserEvents();
  bindWordFrequencyEvents();
});
