// ---------------------------------------------------------------------------
// AJAX support for datasets#index

function updateDatasetList() {
  var datasetList = window.jQuery('#dataset-list');
  if (datasetList.length === 0)
    return;

  var ajax_url = datasetList.attr('data-fetch-url');

  datasetList.load(ajax_url,
    function() {
      window.jQuery(this).data('timeout', window.setTimeout(updateDatasetList, 4000));
    });
}

window.jQuery(updateDatasetList);
