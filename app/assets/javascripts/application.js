//= require jquery
//= require jquery_ujs
//= require foundation

//= require compute_word_frequencies
//= require datasets
//= require named_entities
//= require normalize_document_counts
//= require plot_dates
//= require user
//= require ready

// Load up the Google Visualization and Maps APIs
// FIXME: How does the user specify a Google Maps API key?
google.load('visualization', '1.0', {'packages':['corechart','table']});
google.load('maps', '3', {'other_params':'sensor=false'});
google.setOnLoadCallback(function() {
  google.maps.visualRefresh = true;
});

$(document).foundation();
