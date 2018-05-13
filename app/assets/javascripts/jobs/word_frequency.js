// ---------------------------------------------------------------------------
// Support for the dependencies between the form controls on the params page

window.jQuery(document).on('change', 'select#job_params_ngram_method',
  function(event, data) {
    toggleVisAndDisabled('#single-controls');
    toggleVisAndDisabled('#ngram-controls');

    // If we've shown the single controls, then reset the sub-control
    // visibility, otherwise hide the sub-controls
    if (window.jQuery('#single-controls').is(':visible')) {
      window.jQuery('#job_params_word_method').change();
      window.jQuery('#job_params_exclude_method').change();
    } else {
      hideAndDisable('#num-words-controls');
      hideAndDisable('#inclusion-list-controls');
      window.jQuery('#job_params_exclude_method').change();
    }
  });

window.jQuery(document).on('change', 'select#job_params_block_method',
  function(event, data) {
    toggleVisAndDisabled('#count-controls');
    toggleVisAndDisabled('#blocks-controls');
  });

window.jQuery(document).on('change', 'select#job_params_word_method',
  function(event, data) {
    var option = this.options[this.selectedIndex].value;

    if (option == 'count') {
      showAndEnable('#num-words-controls');
      hideAndDisable('#inclusion-list-controls');
      showAndEnable('#exclusion-controls');
    } else if (option == 'list') {
      hideAndDisable('#num-words-controls');
      showAndEnable('#inclusion-list-controls');
      hideAndDisable('#exclusion-controls');
    } else {
      hideAndDisable('#num-words-controls');
      hideAndDisable('#inclusion-list-controls');
      showAndEnable('#exclusion-controls');
    }
  });

window.jQuery(document).on('change', 'select#job_params_exclude_method',
  function(event, data) {
    var option = this.options[this.selectedIndex].value;

    if (option == 'common') {
      showAndEnable('#exclude-common-controls');
      hideAndDisable('#exclude-list-controls');
      hideAndDisable('#exclude-list-ngram-controls');
    } else if (option == 'list') {
      hideAndDisable('#exclude-common-controls');
      if (window.jQuery('#single-controls').is(':visible')) {
        showAndEnable('#exclude-list-controls');
        hideAndDisable('#exclude-list-ngram-controls');
      } else {
        showAndEnable('#exclude-list-ngram-controls');
        hideAndDisable('#exclude-list-controls');
      }
    } else {
      hideAndDisable('#exclude-common-controls');
      hideAndDisable('#exclude-list-controls');
      hideAndDisable('#exclude-list-ngram-controls');
    }
  });
