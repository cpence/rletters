// ---------------------------------------------------------------------------
// Support for drawing an interactive, configurable word cloud in D3

function setWordRotation(words, rotate) {
  for (var i = 0 ; i < words.length ; i++) {
    if (rotate) {
      words[i].rotate = (~~(Math.random() * 6) - 3) * 30;
    } else {
      words[i].rotate = 0;
    }
  }
}

function setWordColor(words, color) {
  var numWords = words.length;

  switch (color) {
    case 'greens':
      interpolator = d3.interpolateGreens;
      break;
    case 'reds':
      interpolator = d3.interpolateReds;
      break;
    case 'greys':
      interpolator = d3.interpolateGreys;
      break;
    case 'oranges':
      interpolator = d3.interpolateOranges;
      break;
    case 'purples':
      interpolator = d3.interpolatePurples;
      break;
    default:
      interpolator = d3.interpolateBlues;
      break;
  }

  var colorScale = d3.scaleSequential(interpolator)
    .domain([0, numWords]);

  var colorPositions = [];
  for (var i = 0 ; i < numWords ; i++) {
    colorPositions.push(i);
  }
  colorPositions = $.shuffle(colorPositions);

  for (var i = 0 ; i < numWords ; i++) {
    words[i].color = colorScale(colorPositions[i]);
  }
}

function setWordFont(words, font) {
  for (var i = 0 ; i < words.length ; i++) {
    words[i].font = font;
  }
}

function redrawWordCloud(layout, newWords) {
  layout.stop().words(newWords).start();
}

function toggleWordCloudRotation(container) {
  var layout = container.data('layout');
  var rotated = container.data('rotated');

  var newWords = layout.words();

  setWordRotation(newWords, !rotated);
  container.data('rotated', !rotated);
  redrawWordCloud(layout, newWords);
}

function setWordCloudColor(container, color) {
  var layout = container.data('layout');
  var newWords = layout.words();

  setWordColor(newWords, color);
  redrawWordCloud(layout, newWords);
}

function setWordCloudFont(container, font) {
  var layout = container.data('layout');
  var newWords = layout.words();

  setWordFont(newWords, font);
  redrawWordCloud(layout, newWords);
}

function downloadWordCloud(container) {
  var svg = container.data('svg');
  downloadD3asSVG(svg.node());
}

function drawWordCloud(words, extents) {
  var vis = $(this).data('vis');
  var layout = $(this).data('layout');

  var text = vis.selectAll('text').data(words);
  var size = layout.size();

  // Automatically scale to keep the words visible
  var scale = 1;
  if (extents) {
    scale = Math.min(size[0] / Math.abs(extents[1].x - size[0] / 2),
                     size[0] / Math.abs(extents[0].x - size[0] / 2),
                     size[1] / Math.abs(extents[1].y - size[1] / 2),
                     size[1] / Math.abs(extents[0].y - size[1] / 2)) / 2;
  }

  // Animated transitions for font size, transform position, color
  text.transition().duration(1e3)
    .attr('transform', function(d) {
      return 'translate(' + [d.x, d.y] + ')rotate(' + d.rotate + ')';
    })
    .style('font-size', function(d) { return d.size + 'px'; })
    .style('fill', function(d) { return d.color; });

  // Switch font family directly
  text.style('font-family', function(d) { return d.font; });

  // Set all the relevant attributes on construction
  text.enter()
    .append('text')
      .text(function(d) { return d.text; })
      .attr('text-anchor', 'middle')
      .attr('transform', function(d) {
        return 'translate(' + [d.x, d.y] + ')rotate(' + d.rotate + ')';
      })
      .style('font-family', function(d) { return d.font; })
      .style('fill', function(d) { return d.color; })
      .style('font-size', '1px')
        .transition().duration(1e3)
        .style('font-size', function(d) { return d.size + 'px'; })

  // Animated transition for scaling
  vis.transition().delay(1e3).duration(750)
    .attr('transform', 'translate(' + [size[0] / 2, size[1] / 2] + ')scale(' + scale + ')');
}

function setupWordCloud(container) {
  var words = container.data('word-cloud');
  var numWords = Object.keys(words).length;

  var containerWidth = container.innerWidth();
  var size = [containerWidth, containerWidth * 0.7];

  // Build elements
  var svg = d3.select(container.get(0)).append('svg')
    .attr('width', size[0])
    .attr('height', size[1]);
  var vis = svg.append('g')
    .attr('transform', 'translate(' + size[0] / 2 + ',' + size[1] / 2 + ')');

  container.data('svg', svg);
  container.data('vis', vis);
  container.data('rotated', true);

  // Normalize the words to the largest one present
  var max = 0;
  for (w in words) {
    if (words[w] > max) {
      max = words[w];
    }
  }

  // Build the word data
  wordData = Object.keys(words).map(function(w) {
    return {
      text: w,
      size: words[w] / max * 100
    }
  });

  setWordColor(wordData, 'blues');
  setWordRotation(wordData, true);
  setWordFont(wordData, 'sans-serif');

  // Start the layout engine
  var layout = d3.layout.cloud()
    .size(size)
    .words(wordData)
    .rotate(function(d) { return d.rotate; })
    .font(function(d) { return d.font; })
    .fontSize(function(d) { return d.size; })
    .on('end', drawWordCloud.bind(container));

  container.data('layout', layout);
  layout.start();

  // Hook up our controls
  container.on('blur', '.word-cloud-font', function() {
    setWordCloudFont(container, $(this).val());
  });
  container.on('change', '.word-cloud-color', function() {
    setWordCloudColor(container, this.value);
  });
  container.on('click', '.word-cloud-rotate', function() {
    toggleWordCloudRotation(container);
  });
  container.on('click', '.word-cloud-download', function() {
    downloadWordCloud(container);
  });
}

function detectWordClouds() {
  $('.word-cloud').each(function(idx, elt) {
    setupWordCloud($(elt));
  })
}

$(detectWordClouds);
