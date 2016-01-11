// ---------------------------------------------------------------------------
// Bulk delete support for the administration controller

function checkBulkDeleteButton() {
  if ($('.bulk-delete-checkbox:checked').length)
    $('.bulk-delete-button').removeClass('disabled');
  else
    $('.bulk-delete-button').addClass('disabled');
}

$('.bulk-delete-checkbox').on('change', function() {
  checkBulkDeleteButton();
});

function doBulkDelete() {
  var checked = $('.bulk-delete-checkbox:checked');
  if (checked.length === 0) {
    alert('ERROR: Doing bulk delete on no elements?');
    return;
  }

  var ids = jQuery.map(checked, function(box, i) {
    return parseInt($(box).attr('value'), 10);
  });

  // Get the message and show a confirm box
  if (confirm($('.bulk-delete-button').data('message')) !== true) {
    return false;
  }

  // Post it away
  var form = $('.bulk-delete-form');
  form.find('input[name=ids]').val(JSON.stringify(ids));
  form.submit();
}

$('.bulk-delete-button').on('click', function() {
  doBulkDelete();
  return false;
});

// ---------------------------------------------------------------------------
// Tree saving support for the administration controller

function getTreeAndSave() {
  // Get the serialized form of the whole tree
  var serialized = $('.dd').nestable('serialize');

  // Post it away
  var form = $('.tree-save-form');
  form.find('input[name=tree]').val(JSON.stringify(serialized));
  form.submit();
}

$('.tree-save-button').on('click', function() {
  getTreeAndSave($(this));
  return false;
});
