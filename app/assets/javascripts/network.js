//= require d3

function createNetworkGraph() {
  // Get the elements we need
  var nodesContainer = $('.network_graph_nodes');
  var linksContainer = $('.network_graph_links');
  var graphContainer = $('.network_graph');
  if (graphContainer.length === 0 || nodesContainer.length === 0 ||
      linksContainer.length === 0)
    return;

  // Make the vis object
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

  // Tunable for graph complexity (10_000 = default from mbostock, for
  // 100 nodes (N^2))
  var n = 10000;
  var nodes = $.parseJSON(nodesContainer.html());
  var links = $.parseJSON(linksContainer.html());

  // Thanks to https://gist.github.com/sfrdmn/1437516 for this mouseover code,
  // tweaked for our purposes
  var mouseOverFunction = function() {
    var circle = d3.select(this);
    circle.attr('fill', 'red');

    d3.select('.network_graph_box').style('display', 'block');
    d3.select('.network_graph_box p').html(
      '<b>Word Stem:</b> ' + circle.data()[0].name + '<br>' +
      'Forms in dataset: ' + circle.data()[0].forms.join(' '));
  }

  var mouseOutFunction = function() {
    var circle = d3.select(this);
    circle.attr('fill', 'black');

    d3.select('.network_graph_box').style('display', 'none');
  }

  var mouseMoveFunction = function() {
    var coord = d3.mouse(this);
    d3.select('.network_graph_box')
      .style('left', coord[0] + 15 + 'px')
      .style('top', coord[1] + 'px');
  }

  var zoom = function() {
    svg.attr('transform', 'translate(' + d3.event.translate + ')scale(' + d3.event.scale + ')');
  }

  // The layout code here follows http://bl.ocks.org/mbostock/1667139
  var force = d3.layout.force()
    .nodes(nodes)
    .links(links)
    .linkDistance(function(d, idx) { return 40.0 * (1.0 - d.strength); })
    .size([w, h]);

  var svg = d3.select(".network_graph")
    .insert('svg', ':first-child')
    .on('mousemove', mouseMoveFunction)
    .attr('width', w)
    .attr('height', h)
  .append('g')
    .call(d3.behavior.zoom().on('zoom', zoom))
  .append('g')

  svg.append('rect')
    .attr('class', 'overlay')
    .attr('width', w)
    .attr('height', h);

  setTimeout(function() {

    // Run the layout a fixed number of times
    force.start();
    for (var i = n ; i > 0 ; i--) force.tick();
    force.stop();

    svg.selectAll('line')
      .data(links)
    .enter().append('line')
      .attr('stroke-width', function(d) { return (d.strength * 1.75 + 0.25).toString() + 'px'; })
      .attr('x1', function(d) { return d.source.x; })
      .attr('y1', function(d) { return d.source.y; })
      .attr('x2', function(d) { return d.target.x; })
      .attr('y2', function(d) { return d.target.y; });

    // Get the maximum node weight
    var max_weight = 0;
    for (var i = 0 ; i < force.nodes().length ; i++) {
      if (force.nodes()[i].weight > max_weight) {
        max_weight = force.nodes()[i].weight;
      }
    }

    svg.selectAll('circle')
      .data(nodes)
    .enter().append('circle')
      .attr('cx', function(d) { return d.x; })
      .attr('cy', function(d) { return d.y; })
      .on('mouseover', mouseOverFunction)
      .on('mouseout', mouseOutFunction)
      .attr('r', function(d) { return (d.weight - 1) / (max_weight - 1) * 4.0 + 3.0; });

  }, 10);
}

$(createNetworkGraph);
