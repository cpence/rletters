// ---------------------------------------------------------------------------
// Custom form validation support for the dataset construction form
function checkCategoryForm() {
  $(document).on('change', '#category-checkboxes input', function() {
    var checked = $('#category-checkboxes input:checked');
    if (checked.length === 0) {
      $('#category-checkboxes input').each(function(idx, elt) {
        elt.setCustomValidity('Must check at least one journal for category');
      });
    } else {
      $('#category-checkboxes input').each(function(idx, elt) {
        elt.setCustomValidity('');
      });
    }
  });
}

$(checkCategoryForm);
