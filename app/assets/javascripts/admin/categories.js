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

// ---------------------------------------------------------------------------
// Activate Nestable2 on our category index page
function onNestableChange() {
  // Get the URL that we're supposed to POST to from the element
  var post_url = $('#category-dd').data('target');

  // Get the Rails XHR token out of the meta tag
  var token = $('meta[name="csrf-token"]').attr('content');

  // Send it using raw JS
  var xhr = new XMLHttpRequest();
  xhr.open("POST", post_url, true);
  xhr.setRequestHeader('Content-Type', 'application/json');
  xhr.setRequestHeader('X-CSRF-Token', token);
  xhr.send(JSON.stringify({
    order: $('#category-dd').nestable('serialize')
  }));
}

function nestableCategoryList() {
  $('#category-dd').nestable({
    callback: onNestableChange
  })
}

$(nestableCategoryList);
