
$('div[data-role=page]').live('pageshow', function (event, data) {
    $('#blocks_controls').toggle();
    $("input[name='block_method_switch']").change(function() {
        $('#count_controls').toggle();
        $('#blocks_controls').toggle();
        });
    });
