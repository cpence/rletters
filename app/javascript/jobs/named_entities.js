import './named_entities.scss';

if (window.google !== undefined) {

google.load('maps', '3');

var global_named_entity_map;
var global_named_entity_markers = [];
var global_named_entity_bounds;

function lookUpMarkers() {
  var dataContainer = window.jQuery('#ne-map-data');
  if (dataContainer.length === 0 || global_named_entity_markers.length > 0)
    return;

  var points = window.jQuery.parseJSON(dataContainer.html());
  var geocoder = new google.maps.Geocoder();
  global_named_entity_bounds = new google.maps.LatLngBounds();

  window.jQuery.each(points, function(index, value) {
    geocoder.geocode({ 'address': value }, function(results, status) {
      if (status == google.maps.GeocoderStatus.OK) {
        var arr = [results[0].geometry.location, value];

        global_named_entity_markers.push(arr);
        global_named_entity_bounds.extend(arr[0]);

        // If we get some async results *after* the map is opened up, we still
        // want to add them
        if (global_named_entity_map) {
          var marker = new google.maps.Marker({
              map: global_named_entity_map,
              position: arr[0],
              title: arr[1]
          });
          global_named_entity_map.fitBounds(global_named_entity_bounds);
        }
      }
    });
  });
}

function createNamedEntitiesMap() {
  // Get the elements we need
  var mapContainer = window.jQuery('#ne-map');
  if (mapContainer.length === 0)
    return;

  var width = mapContainer.width();
  var height = width;
  if (height > 500) {
    height = 500;
  }
  mapContainer.height(height);

  var mapOptions = {
    center: new google.maps.LatLng(0, 0),
    zoom: 3,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  var map = new google.maps.Map(mapContainer[0], mapOptions);

  window.jQuery.each(global_named_entity_markers, function(index, value) {
    var marker = new google.maps.Marker({
        map: map,
        position: value[0],
        title: value[1]
    });
  });

  map.fitBounds(global_named_entity_bounds);
  global_named_entity_map = map;
}

window.jQuery(lookUpMarkers);
window.jQuery(document).on('show.bs.collapse', '#accordion', function() {
  var openAnchor = window.jQuery(this).find('a[data-toggle=collapse]:not(.collapsed)');
  if (openAnchor.attr('href') == '#collapse3') {
    // This is the ID of the map collapse panel
    createNamedEntitiesMap();
    google.maps.event.trigger(global_named_entity_map, 'resize');
  }
});

}
