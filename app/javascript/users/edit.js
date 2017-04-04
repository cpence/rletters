// ---------------------------------------------------------------------------
// AJAX list of library links from the libraries controller

function checkLibraryList() {
  var libraryList = window.jQuery('div#library-list');

  // If there's a library list at all, we want to refresh its contents (e.g.,
  // after the user closes the "add new library" dialog box)
  if (libraryList.length === 0)
    return;

  var ajax_url = libraryList.attr('data-fetch-url');

  window.jQuery.ajax({
    url: ajax_url,
    type: 'get',
    dataType: 'html',
    cache: false,
    success: function(data) {
      var libraryList = window.jQuery('div#library-list');
      libraryList.html(data);
    }
  });
}

window.jQuery(checkLibraryList);
