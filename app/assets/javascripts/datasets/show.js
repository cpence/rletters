// ---------------------------------------------------------------------------
// AJAX support for datasets#show

function updateDatasetTaskList() {
  var taskList = window.jQuery('#dataset-task-list');
  if (taskList.length === 0)
    return;

  var ajax_url = taskList.attr('data-fetch-url');

  taskList.load(ajax_url,
    function() {
      window.jQuery(this).data('timeout', window.setTimeout(updateDatasetTaskList, 4000));
    });
}

window.jQuery(updateDatasetTaskList);
