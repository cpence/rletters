
function bindWordFrequencyEvents() {
  $('body').on('pageshow', 'div[data-role=page]',
    function (event, data) {
      $('#blocks_controls').toggle();
  });

  $('body').on('change', 'input[name=block_method_switch]',
    function(event, data) {
      $('#count_controls').toggle();
      $('#blocks_controls').toggle();
  });
}
