
$(document).on('change', 'input[name="job_params[normalize_doc_counts]"]',
  function(event, data) {
    toggleVisAndDisabled('#normalize_doc_counts_controls');
  });
