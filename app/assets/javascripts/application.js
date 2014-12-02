//= require jquery
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

  if (modal.length === 0) {
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

$(document).ready(function() {
  // Load tooltips for cloud references
  $('.cloud-tooltip').tooltip();
});

function hideAndDisable(selector) {
  $(selector).hide().addClass('disabled');
  $(selector + ' div').addClass('disabled');
  $(selector + ' input').prop('disabled', true).addClass('disabled');
  $(selector + ' select').prop('disabled', true).addClass('disabled');
  $(selector + ' textarea').prop('disabled', true).addClass('disabled');
}

function showAndEnable(selector) {
  $(selector).show().removeClass('disabled');
  $(selector + ' div').removeClass('disabled');
  $(selector + ' input').prop('disabled', false).removeClass('disabled');
  $(selector + ' select').prop('disabled', false).removeClass('disabled');
  $(selector + ' textarea').prop('disabled', false).removeClass('disabled') ;
}

function toggleVisAndDisabled(selector) {
  $(selector).toggle();

  var visible = $(selector).is(':visible');
  $(selector + ' div').toggleClass('disabled', !visible);
  $(selector + ' input').prop('disabled', !visible).toggleClass('disabled', !visible);
  $(selector + ' select').prop('disabled', !visible).toggleClass('disabled', !visible);
  $(selector + ' textarea').prop('disabled', !visible).toggleClass('disabled', !visible);
}
