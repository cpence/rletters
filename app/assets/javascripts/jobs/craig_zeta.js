// ---------------------------------------------------------------------------
// Graph support for the CraigZeta results page

function drawCraigZetaGraph() {
  // Get the elements we need
  var graphContainer = $('#cz-graph');
  var tableContainer = $('#cz-table');
  if (graphContainer.length === 0 || tableContainer.length === 0)
    return;

  var results = $.parseJSON(window.json_data);

  // Make a DataTable object for the graph
  var data = new google.visualization.DataTable();
  var rows = results.graph_points;

  data.addColumn('number', results.marker_1_header);
  data.addColumn('number', results.marker_2_header);
  data.addColumn({ type: 'string', role: 'tooltip' });
  data.addRows(rows);

  // Make the scatter chart object
  var w = $(window).width();
  if (w > 750) {
    w = 750;
  }

  var h;
  if (w > 480) {
    h = 480;
  } else {
    h = w;
  }

  var options = { width: w, height: h,
                  legend: { position: 'none' },
                  hAxis: { title: results.marker_1_header },
                  vAxis: { title: results.marker_2_header },
                  pointSize: 3 };

  var chart = new google.visualization.ScatterChart(graphContainer[0]);
  chart.draw(data, options);

  graphContainer.trigger('updatelayout');

  // Make a DataTable object for the table
  data = new google.visualization.DataTable();
  rows = results.zeta_scores;

  // Add the data
  data.addColumn('string', results.word_header);
  data.addColumn('number', results.score_header);
  data.addRows(rows);

  // Make a pretty table object
  var table = new google.visualization.Table(tableContainer[0]);
  table.draw(data, { page: 'enable', pageSize: 20, sort: 'disable',
                     width: '20em' });
}

function setupCraigZetaGraph() {
  // Get the elements we need
  if ($('#cz-graph').length === 0 || $('#cz-table').length === 0)
    return;

  // Load the external libraries we need
  if (google.charts === undefined)
    return;
  google.charts.load('current', {'packages':['corechart','table']});
  google.charts.setOnLoadCallback(drawCraigZetaGraph);
}

$(setupCraigZetaGraph);
