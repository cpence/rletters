// ---------------------------------------------------------------------------
// AJAX support for datasets##show

function updateTaskList() {
  var taskList = $('div.dataset_task_list');
  if (taskList.length === 0)
    return;

  var ajax_url = taskList.attr('data-fetch-url');

  taskList.load(ajax_url,
    function() {
      window.setTimeout(updateTaskList, 4000);
      $(this).find('ul').listview().trigger('updatelayout');
    });
}

$(document).on('ready', function() { updateTaskList(); });
