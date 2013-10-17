// ---------------------------------------------------------------------------
// AJAX support for datasets##show

function updateTaskList() {
  var taskList = $('div#dataset-task-list');
  if (taskList.length === 0)
    return;

  var ajax_url = taskList.attr('data-fetch-url');

  taskList.load(ajax_url,
    function() {
      window.setTimeout(updateTaskList, 4000);
    });
}

$(updateTaskList);
