// ---------------------------------------------------------------------------
// Collapsible list for facets, <= 768px

function createCollapsibleList() {
  var leftColumn = $.mobile.activePage.find('div.leftcolumn');
  var toolsList = $.mobile.activePage.find('ul.toolslist')
  var facetList = $.mobile.activePage.find('ul.facetlist');
  
  if (leftColumn.length == 0) {
    return;
  }
  
  if (toolsList.length) {
    var toolsButtonText = $.mobile.activePage.find('li.toolsheader').text();
    var toolsCollapse = $(document.createElement('div')).attr('class', 'toolscollapse').append($(document.createElement('h3')).text(toolsButtonText));
    toolsList.clone().appendTo(toolsCollapse);
    toolsCollapse.appendTo(leftColumn);
    toolsCollapse.collapsible({theme:'c',refresh:true,collapsed:false}).trigger('updatelayout');
  }
  
  if (facetList.length) {
    var facetButtonText = $.mobile.activePage.find('li.filterheader').text();
    var facetCollapse = $(document.createElement('div')).attr('class', 'facetcollapse').append($(document.createElement('h3')).text(facetButtonText));
    facetList.clone().appendTo(facetCollapse);
    facetCollapse.appendTo(leftColumn);
    facetCollapse.collapsible({theme:'c',refresh:true,collapsed:true}).trigger('updatelayout');
  }
}
function destroyCollapsibleList() {
  var toolsCollapse = $.mobile.activePage.find('div.toolscollapse');
  var facetCollapse = $.mobile.activePage.find('div.facetcollapse');
  
  if (toolsCollapse.length) {
    var parent = toolsCollapse.parent();
    toolsCollapse.remove();
    parent.trigger('updatelayout');
  }
  if (facetCollapse.length) {
    var parent = facetCollapse.parent();
    facetCollapse.remove();
    parent.trigger('updatelayout');
  }
}

function checkCollapsibleList() {
  var width = $(window).width();
  var toolsCollapse = $.mobile.activePage.find('div.toolscollapse');
  var facetCollapse = $.mobile.activePage.find('div.facetcollapse');
  
  if (width <= 768 && (facetCollapse.length == 0 && toolsCollapse.length == 0))
    createCollapsibleList();
  else if (width > 768)
    destroyCollapsibleList();
}

function bindSearchEvents() {
  // We need to look for page resizes on both window-resize, and on any time
  // a new page is shown
  $(window).resize( function() { checkCollapsibleList(); });
  $('body').on('pageshow', 'div[data-role=page]',
    function (event, ui) { checkCollapsibleList(); });
}
