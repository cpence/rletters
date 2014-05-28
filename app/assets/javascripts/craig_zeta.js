// ---------------------------------------------------------------------------
// Graph support for the CraigZeta results page
google.load('visualization', '1.0', {'packages':['corechart','table']});

function createCraigZetaGraph() {
  // Get the elements we need
  var dataContainer = $('#cz-graph-data');
  var graphContainer = $('#cz-graph');
  var nameOne = $('#cz-dataset-one');
  var nameTwo = $('#cz-dataset-two');

  if (graphContainer.length === 0 || dataContainer.length === 0 ||
      nameOne.length === 0 || nameTwo.length === 0)
    return;

  // Make a DataTable object for the graph
  var data = new google.visualization.DataTable();
  var rows = $.parseJSON(dataContainer.html());

  data.addColumn('number', I18n.t('jobs.analysis.craig_zeta.marker_column', {name: nameOne.html()}));
  data.addColumn('number', I18n.t('jobs.analysis.craig_zeta.marker_column', {name: nameTwo.html()}));
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
                  hAxis: { title: I18n.t('jobs.analysis.craig_zeta.marker_column', {name: nameOne.html()}) },
                  vAxis: { title: I18n.t('jobs.analysis.craig_zeta.marker_column', {name: nameTwo.html()}) },
                  pointSize: 3 };

  var chart = new google.visualization.ScatterChart(graphContainer[0]);
  chart.draw(data, options);

  graphContainer.trigger('updatelayout');
}

function createCraigZetaTable() {
  // Get the elements we need
  var dataContainer = $('#cz-table-data');
  var tableContainer = $('#cz-table');
  if (tableContainer.length === 0 || dataContainer.length === 0)
    return;

  // Make a DataTable object for the table
  var data = new google.visualization.DataTable();
  var rows = $.parseJSON(dataContainer.html());

  // Add the data
  data.addColumn('string', I18n.t('jobs.analysis.craig_zeta.word_column'));
  data.addColumn('number', I18n.t('jobs.analysis.craig_zeta.score_column'));
  data.addRows(rows);

  // Make a pretty table object
  var table = new google.visualization.Table(tableContainer[0]);
  table.draw(data, { page: 'enable', pageSize: 20, sort: 'disable', width: '20em' });
}

$(createCraigZetaGraph);
$(createCraigZetaTable);
