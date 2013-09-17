
function bindWordFrequencyEvents() {
  $(document).on('change', 'input[name=block_method_switch]',
    function(event, data) {
      $('#count_controls').toggle();
      $('#blocks_controls').toggle();
  });
}
