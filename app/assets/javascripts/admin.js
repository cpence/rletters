// ---------------------------------------------------------------------------
// Tree saving support for the administration controller

function getTreeAndSave() {
  // Find the form
  var form = $('.tree-save-form')

  // Get the serialized form of the whole tree
  var serialized = $('.dd').nestable('serialize');

  // Stick it into the input
  form.find('input[name=tree]').val(JSON.stringify(serialized));

  // Post it away
  form.submit();
}

$('.tree-save-button').on('click', function() {
  getTreeAndSave($(this));
  return false;
});
