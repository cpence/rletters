// ---------------------------------------------------------------------------
// Array support for SimpleForm

function removeArrayRow(link)
{
  var input_group = link.parent().parent();
  input_group.remove();
}

function addArrayRow(link)
{
  var input_group = link.parent().parent();

  // Build the copy
  var copy = input_group.clone();
  var copy_input = copy.find('input');

  // Change the copy's ID
  var id_bits = copy_input.attr('id').split('_');
  var number = parseInt(id_bits[2]) + 1;
  copy_input.attr('id', id_bits[0] + '_' + id_bits[1] + '_' + number);

  // Append it to the form group
  input_group.parent().append(copy);

  // Re-activate its click handler
  copy.find('a.simple-form-add').on('click', function() {
    addArrayRow(window.jQuery(this));
    return false;
  });

  // Un-disable the current input
  input = input_group.find('input');
  input.prop('disabled', false);

  // Swap out its add link for a remove link (FIXME: localize?)
  link.attr('class', 'simple-form-remove').attr('aria-label', 'Remove');
  link.find('span').attr('class', 'glyphicon glyphicon-minus');
  link.off('click').on('click', function() {
    removeArrayRow(window.jQuery(this));
    return false;
  });
}

window.jQuery(document).on('click', '.simple-form-remove', function() {
  removeArrayRow(window.jQuery(this));
  return false;
});
window.jQuery(document).on('click', '.simple-form-add', function() {
  addArrayRow(window.jQuery(this));
  return false;
});
