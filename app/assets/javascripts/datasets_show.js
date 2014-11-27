// ---------------------------------------------------------------------------
// AJAX support for datasets#show

function updateDatasetTaskList() {
  var taskList = $('#dataset-task-list');
  if (taskList.length === 0)
    return;

  var ajax_url = taskList.attr('data-fetch-url');

  taskList.load(ajax_url,
    function() {
      $(this).data('timeout', window.setTimeout(updateDatasetTaskList, 4000));
    });
}

$(document).ready(updateDatasetTaskList);
