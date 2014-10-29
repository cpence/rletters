//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap-sprockets
//= require i18n/translations

$(function() {
  // Setup drop down menu
  $('.dropdown-toggle').dropdown();

  // Fix input element click problem
  $('.dropdown input, .dropdown label').click(function(e) {
    e.stopPropagation();
  });

  // Load via jQuery any modal dialog boxes that are suitably marked up
  $(document).on('click', '.ajax-modal', function(e) {
    e.preventDefault();

    var modal = $('#ajax-modal');
    var url = $(this).attr('href');

    if (url.indexOf('#') == 0) {
      $(url).modal('show');
    } else {
      $.get(url, function(data) {
        modal.html(data);
        modal.modal();
      });
    }
  });
});

function hideAndDisable(selector) {
  $(selector).hide();
  $(selector + ' input').prop('disabled', true);
  $(selector + ' select').prop('disabled', true);
  $(selector + ' textarea').prop('disabled', true);
}

function showAndEnable(selector) {
  $(selector).show();
  $(selector + ' input').prop('disabled', false);
  $(selector + ' select').prop('disabled', false);
  $(selector + ' textarea').prop('disabled', false);
}

function toggleVisAndDisabled(selector) {
  $(selector).toggle();

  var visible = $(selector).is(':visible');
  $(selector + ' input').prop('disabled', !visible);
  $(selector + ' select').prop('disabled', !visible);
  $(selector + ' textarea').prop('disabled', !visible);
}
