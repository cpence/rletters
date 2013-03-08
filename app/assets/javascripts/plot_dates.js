// ---------------------------------------------------------------------------
// Graph support for the PlotDates results page

function createPlotDatesGraph() {
  var graphContainer = $.mobile.activePage.find('div.plot_dates_graph');
  if (graphContainer.length === 0)
    return;
  
  graphContainer.show();
  
  var data = new google.visualization.DataTable();
  data.addColumn('number', 'Year');
  data.addColumn('number', 'Documents');
  data.addRows($.parseJSON(graphContainer.html()));
      
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
                  hAxis: { format: '####' },
                  pointSize: 3 };
      
  var chart = new google.visualization.LineChart(graphContainer[0]);
  chart.draw(data, options);
  
  graphContainer.trigger('updatelayout');
}

function bindPlotDatesEvents() {
  $(document).on('pageshow', 'div[data-role=page]',
    function (event, data) { createPlotDatesGraph(); });
}
