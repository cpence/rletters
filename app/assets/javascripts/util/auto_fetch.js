// ---------------------------------------------------------------------------
// General support for automatically refreshing AJAX frames

function doAutoFetch(element) {
  $(element).load($(element).data('fetch-url'), function() {
    $(this).data('timeout', window.setTimeout(doAutoFetch, 4000, element));
  });
}

function setupAutoFetch() {
  $.each($('[data-fetch=auto]'), function(idx, elt) { doAutoFetch(elt); });
}

window.jQuery(setupAutoFetch);
