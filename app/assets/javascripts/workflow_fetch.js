// ---------------------------------------------------------------------------
// AJAX support for workflow#fetch

function updateTaskList() {
  var datasetList = $('#task-list');
  if (datasetList.length === 0)
    return;

  var ajax_url = datasetList.attr('data-fetch-url');

  datasetList.load(ajax_url,
    function() {
      $(this).data('timeout', window.setTimeout(updateTaskList, 4000));
    });
}

$(updateTaskList);
