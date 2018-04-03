
// ---------------------------------------------------------------------------
// Bulk delete support for the administration controller

function checkBulkDeleteButton() {
  if (window.jQuery('.bulk-delete-checkbox:checked').length)
    window.jQuery('.bulk-delete-button').removeClass('disabled');
  else
    window.jQuery('.bulk-delete-button').addClass('disabled');
}

window.jQuery(document).on('change', '.bulk-delete-checkbox', function() {
  checkBulkDeleteButton();
});

function doBulkDelete() {
  var checked = window.jQuery('.bulk-delete-checkbox:checked');
  if (checked.length === 0) {
    alert('ERROR: Doing bulk delete on no elements?');
    return;
  }

  var ids = jQuery.map(checked, function(box, i) {
    return parseInt(window.jQuery(box).attr('value'), 10);
  });

  // Get the message and show a confirm box
  if (confirm(window.jQuery('.bulk-delete-button').data('message')) !== true) {
    return false;
  }

  // Post it away
  var form = window.jQuery('.bulk-delete-form');
  form.find('input[name=ids]').val(JSON.stringify(ids));
  form.submit();
}

window.jQuery(document).on('click', '.bulk-delete-button', function() {
  doBulkDelete();
  return false;
});

// ---------------------------------------------------------------------------
// Tree saving support for the administration controller

function getTreeAndSave() {
  // Get the serialized form of the whole tree
  var serialized = window.jQuery('.dd').nestable('serialize');

  // Post it away
  var form = window.jQuery('.tree-save-form');
  form.find('input[name=tree]').val(JSON.stringify(serialized));
  form.submit();
}

window.jQuery(document).on('click', '.tree-save-button', function() {
  getTreeAndSave(window.jQuery(this));
  return false;
});
