//= require jquery
//= require jquery_ujs
//= require foundation

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

$(document).foundation();
