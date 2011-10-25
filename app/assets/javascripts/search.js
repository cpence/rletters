// ---------------------------------------------------------------------------
// Collapsible list for facets, <= 768px

function createCollapsibleList() {
  var leftColumn = $('div.ui-page-active').find('div.leftcolumn');
  var toolsList = $('div.ui-page-active').find('ul.toolslist')
  var facetList = $('div.ui-page-active').find('ul.facetlist');
  
  if (leftColumn.length == 0) {
    return;
  }
  
  if (toolsList.length) {
    var toolsButtonText = $('div.ui-page-active').find('li.toolsheader').text();
    var toolsCollapse = $(document.createElement('div')).attr('class', 'toolscollapse').append($(document.createElement('h3')).text(toolsButtonText));
    toolsList.clone().appendTo(toolsCollapse);
    toolsCollapse.appendTo(leftColumn);
    toolsCollapse.collapsible({theme:'c',refresh:true,collapsed:false});
  }
  
  if (facetList.length) {
    var facetButtonText = $('div.ui-page-active').find('li.filterheader').text();
    var facetCollapse = $(document.createElement('div')).attr('class', 'facetcollapse').append($(document.createElement('h3')).text(facetButtonText));
    facetList.clone().appendTo(facetCollapse);
    facetCollapse.appendTo(leftColumn);
    facetCollapse.collapsible({theme:'c',refresh:true,collapsed:true});
  }
}
function destroyCollapsibleList() {
  var toolsCollapse = $('div.ui-page-active').find('div.toolscollapse');
  var facetCollapse = $('div.ui-page-active').find('div.facetcollapse');
  
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
  var toolsCollapse = $('div.ui-page-active').find('div.toolscollapse');
  var facetCollapse = $('div.ui-page-active').find('div.facetcollapse');
  
  if (width <= 768 && (facetCollapse.length == 0 && toolsCollapse.length == 0))
    createCollapsibleList();
  else if (width > 768)
    destroyCollapsibleList();
}

// We need to look for page resizes on both window-resize, and on any time
// a new page is shown
$(window).resize( function() { checkCollapsibleList(); });
$('div[data-role=page]').live('pageshow', function (event, ui) { checkCollapsibleList(); });
