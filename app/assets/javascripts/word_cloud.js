
function updateWordCloudControls() {
  var word_cloud_checked = $('#job_params_word_cloud').prop('checked');
  // ngram_method is either 'single' or 'ngrams'
  var ngram_select = $('select#job_params_ngram_method');
  var ngrams_enabled = false;
  if (ngram_select.length !== 0 && ngram_select.val() == 'ngrams') {
    ngrams_enabled = true;
  }

  // First, show or hide the whole word cloud control box
  if (word_cloud_checked) {
    showAndEnable('#word_cloud_controls');
  } else {
    hideAndDisable('#word_cloud_controls');
  }

  // Then show or hide the special ngram word cloud controls
  if (ngrams_enabled && word_cloud_checked) {
    showAndEnable('#word_cloud_ngram_controls');
  } else {
    hideAndDisable('#word_cloud_ngram_controls');
  }
}

$(document).on('change', '#job_params_word_cloud',
  function(event, data) {
    updateWordCloudControls();
  });
