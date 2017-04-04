// ---------------------------------------------------------------------------
// AJAX support for workflow#fetch

function updateWorkflowTaskList() {
  var datasetList = window.jQuery('#workflow-task-list');
  if (datasetList.length === 0)
    return;

  var ajax_url = datasetList.attr('data-fetch-url');

  datasetList.load(ajax_url,
    function() {
      window.jQuery(this).data('timeout', window.setTimeout(updateWorkflowTaskList, 4000));
    });
}

window.jQuery(updateWorkflowTaskList);
