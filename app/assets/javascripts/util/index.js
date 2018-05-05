
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
      window.jQuery(form).addClass('was-validated');

      // Remove all server-side validation, as the user has now changed the
      // form
      window.jQuery(form).find('.is-invalid').removeClass('is-invalid');
      window.jQuery(form).find('.server-errors').hide();

      // Show the client-side error messages, which will be displayed if the
      // client-side validation failed
      window.jQuery(form).find('.client-errors').show();
    });
  });
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

// Return a list of all form elements that can take a 'disabled' class, within
// the current selector.
function formElementsFor(selector) {
  var elements = [
    selector,
    selector + ' div',
    selector + ' label',
    selector + ' input',
    selector + ' select',
    selector + ' textarea'
  ];

  return $(elements.join(','));
}

function setVisibleAndDisabled(selector, state) {
  $(selector).toggle(state);
  formElementsFor(selector)
    .toggleClass('disabled', !state)
    .prop('disabled', !state);
}

window.hideAndDisable = function(selector) {
  setVisibleAndDisabled(selector, false);
}

window.showAndEnable = function(selector) {
  setVisibleAndDisabled(selector, true);
}

window.toggleVisAndDisabled = function(selector) {
  var visible = $(selector).is(':visible');
  setVisibleAndDisabled(selector, !visible);
}
