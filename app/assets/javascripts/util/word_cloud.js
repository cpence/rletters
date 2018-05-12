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

function redrawWordCloud(newWords) {
  window.wordCloudLayout.stop().words(newWords).start();
}

function toggleWordCloudRotation() {
  var newWords = window.wordCloudLayout.words();

  window.wordCloudRotated = !window.wordCloudRotated;
  setWordRotation(newWords, window.wordCloudRotated);
  redrawWordCloud(newWords);
}

function setWordCloudColor(color) {
  var newWords = window.wordCloudLayout.words();

  setWordColor(newWords, color);
  redrawWordCloud(newWords);
}

function setWordCloudFont(font) {
  var newWords = window.wordCloudLayout.words();

  setWordFont(newWords, font);
  redrawWordCloud(newWords);
}

function drawWordCloud(words, extents) {
  var text = window.wordCloudVis.selectAll('text').data(words);
  var size = window.wordCloudLayout.size();

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
  window.wordCloudVis
    .transition().delay(1e3).duration(750)
    .attr('transform', 'translate(' + [size[0] / 2, size[1] / 2] + ')scale(' + scale + ')');
}

function setupWordCloud() {
  var container = $('#word-cloud');
  if (container.length === 0) {
    return;
  }

  var data = $.parseJSON(window.json_data);
  var words = data['word_cloud_words'];
  var numWords = Object.keys(words).length;
  var size = [800, 600];

  // Build elements
  var svg = d3.select('#word-cloud').append('svg')
    .attr('width', size[0])
    .attr('height', size[1]);
  window.wordCloudVis = svg.append('g')
    .attr('transform', 'translate(' + size[0] / 2 + ',' + size[1] / 2 + ')');

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
    .on('end', drawWordCloud);

  window.wordCloudLayout = layout;
  window.wordCloudLayout.start();

  window.wordCloudRotated = true;
}

$(setupWordCloud);
