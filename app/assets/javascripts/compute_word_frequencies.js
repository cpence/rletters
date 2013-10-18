
$(document).on('change', 'select#job_params_block_method',
  function(event, data) {
    $('#count_controls').toggle();
    $('#blocks_controls').toggle();
  });

$(document).on('change', 'select#job_params_word_method',
  function(event, data) {
    $('#num_words_controls').toggle();
    $('#inclusion_list_controls').toggle();
  });

$(document).on('change', 'select#job_params_exclude_method',
  function(event, data) {
    var option = this.options[this.selectedIndex].value;

    if (option == 'common') {
      $('#exclude_common_controls').show();
      $('#exclude_list_controls').hide();
    } else if (option == 'list') {
      $('#exclude_common_controls').hide();
      $('#exclude_list_controls').show();
    } else {
      $('#exclude_common_controls').hide();
      $('#exclude_list_controls').hide();
    }
  });
