// ---------------------------------------------------------------------------
// AJAX support for datasets#index

function updateDatasetList() {
  var datasetList = $('#dataset-list');
  if (datasetList.length === 0)
    return;

  var ajax_url = datasetList.attr('data-fetch-url');

  datasetList.load(ajax_url,
    function() {
      $(this).data('timeout', window.setTimeout(updateDatasetList, 4000));
    });
}

$(updateDatasetList);
