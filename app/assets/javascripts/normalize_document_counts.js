
function bindNormalizeDocumentCountsEvents() {
  $(document).on('change', 'select[name="job_params[normalize_doc_counts]"]',
    function(event, data) {
      $('#normalize_doc_counts_controls').toggle();
  });
}
