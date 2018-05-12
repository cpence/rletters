// ---------------------------------------------------------------------------
// Support for saving an arbitrary D3 SVG to disk
//
// Make sure to also include the relevant partial: jobs/d3_svg/form

function downloadD3asSVG(element) {
  $('#d3-svg-content-type').attr('value', 'image/svg+xml;charset=utf-8');
  $('#d3-svg-filename').attr('value', 'download.svg');

  serializer = new XMLSerializer;
  $('#d3-svg-data').attr('value', serializer.serializeToString(element));

  $('#d3-svg-form').submit();
}
