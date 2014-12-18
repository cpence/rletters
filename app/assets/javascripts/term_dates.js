// ---------------------------------------------------------------------------
// Graph support for the TermDates results page
google.load('visualization', '1.0', {'packages':['corechart','table']});

function createTermDatesGraph() {
  // Get the elements we need
  var graphContainer = $('.term_dates_graph');
  var tableContainer = $('.term_dates_table');
  if (graphContainer.length === 0 || tableContainer.length === 0)
    return;

  var results = $.parseJSON(window.json_data);

  // Make a DataTable object
  var data = new google.visualization.DataTable();
  var rows = results.data;

  data.addColumn('number', results.year_header);
  data.addColumn('number', results.value_header);
  data.addRows(rows);

  // Make the line chart object
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
                  hAxis: { format: '####',
                           title: results.year_header },
                  vAxis: { title: results.value_header },
                  pointSize: 3 };

  var chart = new google.visualization.LineChart(graphContainer[0]);
  chart.draw(data, options);

  graphContainer.trigger('updatelayout');

  // Make a pretty table object
  var table = new google.visualization.Table(tableContainer[0]);
  table.draw(data, { page: true, pageSize: 20, sortColumn: 0, width: '20em' });
}

$(document).ready(createTermDatesGraph);
