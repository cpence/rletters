// ---------------------------------------------------------------------------
// AJAX support for datasets#index

function updateDatasetList() {
  var datasetList = $('div.dataset_list');
  if (datasetList.length === 0)
    return;

  var ajax_url = datasetList.attr('data-fetch-url');

  datasetList.load(ajax_url,
    function() {
      $(this).data('timeout', window.setTimeout(updateDatasetList, 4000));
      $(this).find('ul').listview().trigger('updatelayout');
    });
}

$(document).on('ready', function() { updateDatasetList(); });
