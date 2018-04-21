// ---------------------------------------------------------------------------
// ArticleDates job parameters page

$(document).on('change', 'input[name="job_params[normalize]"]',
  function(event, data) {
    toggleVisAndDisabled('#normalize_controls');
  });

// ---------------------------------------------------------------------------
// Graph support for the ArticleDates results page

function drawArticleDatesGraph() {
  // Get the elements we need
  var graphContainer = $('.article_dates_graph');
  var tableContainer = $('.article_dates_table');
  if (graphContainer.length === 0 || tableContainer.length === 0)
    return;

  var results = $.parseJSON(window.json_data);

  // Make a DataTable object
  var data = new google.visualization.DataTable();
  var rows = results.data;
  var percent = results.percent;

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
  if (percent) {
    options.vAxis.format = '###%';
  }

  var chart = new google.visualization.LineChart(graphContainer[0]);
  chart.draw(data, options);

  graphContainer.trigger('updatelayout');

  // Make a pretty table object
  var table = new google.visualization.Table(tableContainer[0]);
  table.draw(data, { page: 'enable', pageSize: 20, sortColumn: 0,
                     width: '20em' });
}

function setupArticleDatesGraph() {
  // Get the elements we need
  if ($('.article_dates_graph').length === 0 ||
      $('.article_dates_table').length === 0)
    return;

  // Load the external libraries we need
  if (google.charts === undefined)
    return;
  google.charts.load('current', {'packages':['corechart','table']});
  google.charts.setOnLoadCallback(drawArticleDatesGraph);
}

$(setupArticleDatesGraph);
