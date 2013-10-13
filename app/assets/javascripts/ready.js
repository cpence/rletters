
// Bind all of our various event handlers
// FIXME: no longer need to do all this this way for Foundation
$(document).on("ready", function() {
  bindDatasetsEvents();
  bindNamedEntitiesEvents();
  bindNormalizeDocumentCountsEvents();
  bindPlotDatesEvents();
  bindUserEvents();
  bindWordFrequencyEvents();
});
