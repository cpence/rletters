
$('div[data-role=page]').live('pageshow', function (event, data) {
    $('#blocks_controls').toggle();
});

$('input[name=block_method_switch]').live('change', function(event, data) {
    $('#count_controls').toggle();
    $('#blocks_controls').toggle();
});
