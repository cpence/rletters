//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs

//= require bootstrap-sprockets
//= require i18n/translations

//= require_self

//= require article_dates
//= require compute_word_frequencies
//= require craig_zeta
//= require datasets_index
//= require datasets_show
//= require named_entities
//= require network
//= require normalize_document_counts
//= require term_dates
//= require users_edit
//= require workflow_fetch

//= require turbolinks
//= require turbolinks_settings

// Fix input element click problem
$(document).on('click', '.dropdown input, .dropdown label', function(e) {
  e.stopPropagation();
});

// Load via jQuery any modal dialog boxes that are suitably marked up
$(document).on('click', '.ajax-modal', function(e) {
  e.preventDefault();

  var id = $(this).attr('id');
  var url = $(this).attr('href');
  var modal = $('#ajax-' + id + '-modal');

  if (modal.length == 0) {
    var container = $('#modal-container');
    container.append(
      "<div id='ajax-" + id +
      "-modal' class='modal fade' tabindex='-1' role='dialog' aria-hidden='true'></div>");

    modal = $('#ajax-' + id + '-modal');
  }

  $.get(url, function(data) {
    modal.html(data);
    modal.modal('show');
  });
});

$(function() {
  // Load tooltips for cloud references
  $('.cloud-tooltip').tooltip();
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
