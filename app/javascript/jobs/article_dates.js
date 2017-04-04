import './article_dates.scss';

// ---------------------------------------------------------------------------
// ArticleDates job parameters page
window.jQuery(document).on('change', 'input[name="job_params[normalize]"]',
  function(event, data) {
    toggleVisAndDisabled('#normalize_controls');
  });

// ---------------------------------------------------------------------------
// Graph support for the ArticleDates results page
if (window.google !== undefined) {

google.load('visualization', '1.0', {'packages':['corechart','table']});

function createArticleDatesGraph() {
  // Get the elements we need
  var graphContainer = window.jQuery('.article_dates_graph');
  var tableContainer = window.jQuery('.article_dates_table');
  if (graphContainer.length === 0 || tableContainer.length === 0)
    return;

  var results = window.jQuery.parseJSON(window.json_data);

  // Make a DataTable object
  var data = new google.visualization.DataTable();
  var rows = results.data;
  var percent = results.percent;

  data.addColumn('number', results.year_header);
  data.addColumn('number', results.value_header);
  data.addRows(rows);

  // Make the line chart object
  var w = window.jQuery(window).width();
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

window.jQuery(createArticleDatesGraph);

}
