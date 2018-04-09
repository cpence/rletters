
// Enable BS4's client-side form validation for all forms within root
function checkBootstrapValidation(root) {
  // Fetch all the forms we want to apply custom Bootstrap validation styles to
  var forms = root.find('.needs-validation');

  // Loop over them and prevent submission
  window.jQuery.each(forms, function(index, form) {
    window.jQuery(form).on('submit', function(event) {
      if (form.checkValidity() === false) {
        event.preventDefault();
        event.stopPropagation();
      }
    });
  });

  forms.addClass('was-validated');
}

// Load via jQuery any modal dialog boxes that are suitably marked up
window.jQuery(document).on('click', '.ajax-modal', function(e) {
  e.preventDefault();

  var context = window.jQuery(this);
  var id = context.attr('id');
  var url = context.attr('href');
  var modal = window.jQuery('#modal-container #ajax-' + id + '-modal');

  if (modal.length === 0) {
    var container = window.jQuery('#modal-container');
    // FIXME: should add the 'fade' class after 'modal' here, but it's causing
    // strange bugs in system tests.
    container.append(
      "<div id='ajax-" + id +
      "-modal' class='modal' tabindex='-1' role='dialog'></div>");

    modal = window.jQuery('#modal-container #ajax-' + id + '-modal');
  }

  window.jQuery.get(url, function(data) {
    modal.html(data);
    checkBootstrapValidation(modal);
    modal.modal('show');
  })
});

window.jQuery(function() {
  // Load tooltips wherever they may be found (we use these extensively)
  window.jQuery('[data-toggle="tooltip"]').tooltip()

  // Set up Bootstrap validation for any forms currently shown
  checkBootstrapValidation(window.jQuery(document));

  // Submit the sign-in form that's on all pages on enter
  window.jQuery('.dropdown-sign-in-form input').keydown(function(e) {
    if (e.keyCode == 13 || e.keyCode == 10) {
      this.form.submit();
      return false;
    }
  });
});

window.hideAndDisable = function(selector) {
  window.jQuery(selector).hide().addClass('disabled');
  window.jQuery(selector + ' div').addClass('disabled');
  window.jQuery(selector + ' label').addClass('disabled');
  window.jQuery(selector + ' input').prop('disabled', true).addClass('disabled');
  window.jQuery(selector + ' select').prop('disabled', true).addClass('disabled');
  window.jQuery(selector + ' textarea').prop('disabled', true).addClass('disabled');
}

window.showAndEnable = function(selector) {
  window.jQuery(selector).show().removeClass('disabled');
  window.jQuery(selector + ' div').removeClass('disabled');
  window.jQuery(selector + ' label').removeClass('disabled');
  window.jQuery(selector + ' input').prop('disabled', false).removeClass('disabled');
  window.jQuery(selector + ' select').prop('disabled', false).removeClass('disabled');
  window.jQuery(selector + ' textarea').prop('disabled', false).removeClass('disabled') ;
}

window.toggleVisAndDisabled = function(selector) {
  window.jQuery(selector).toggle();

  var visible = window.jQuery(selector).is(':visible');
  window.jQuery(selector + ' div').toggleClass('disabled', !visible);
  window.jQuery(selector + ' label').toggleClass('disabled', !visible);
  window.jQuery(selector + ' input').prop('disabled', !visible).toggleClass('disabled', !visible);
  window.jQuery(selector + ' select').prop('disabled', !visible).toggleClass('disabled', !visible);
  window.jQuery(selector + ' textarea').prop('disabled', !visible).toggleClass('disabled', !visible);
}
