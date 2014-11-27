// ---------------------------------------------------------------------------
// AJAX support for workflow#fetch

function updateWorkflowTaskList() {
  var datasetList = $('#workflow-task-list');
  if (datasetList.length === 0)
    return;

  var ajax_url = datasetList.attr('data-fetch-url');

  datasetList.load(ajax_url,
    function() {
      $(this).data('timeout', window.setTimeout(updateWorkflowTaskList, 4000));
    });
}

$(document).ready(updateWorkflowTaskList);
