
// Bind all of our various event handlers
$(document).on("mobileinit", function() {
  bindDatasetsEvents();
  bindNamedEntitiesEvents();
  bindNormalizeDocumentCountsEvents();
  bindPlotDatesEvents();
  bindSearchEvents();
  bindUserEvents();
  bindWordFrequencyEvents();
});
