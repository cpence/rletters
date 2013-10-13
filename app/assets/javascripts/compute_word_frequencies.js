
$(document).on('change', 'input[name=block_method_switch]',
  function(event, data) {
    $('.count_controls').toggle();
    $('.blocks_controls').toggle();
  });

$(document).on('change', 'input[name=word_method_switch]',
  function(event, data) {
    $('.num_words_controls').toggle();
    $('.inclusion_list_controls').toggle();
  });

$(document).on('change', 'input[name=exclude_method_switch]',
  function(event, data) {
    if ($('input[name=exclude_method_switch][value=common]').prop('checked')) {
      $('.exclude_common_controls').show();
      $('.exclude_list_controls').hide();
    } else if ($('input[name=exclude_method_switch][value=list]').prop('checked')) {
      $('.exclude_common_controls').hide();
      $('.exclude_list_controls').show();
    } else {
      $('.exclude_common_controls').hide();
      $('.exclude_list_controls').hide();
    }
  });
