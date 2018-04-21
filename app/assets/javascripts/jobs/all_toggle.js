
window.jQuery(document).on('change', 'input[name="job_params[all]"]',
  function(event, data) {
    checked = window.jQuery(this).is(':checked');

    checkbox = window.jQuery(this).parents('.form-group').first();
    number = window.jQuery(checkbox).prev();

    if (checked)
    {
      number.addClass('disabled');
      number.find('div').addClass('disabled');
      number.find('input').prop('disabled', true).addClass('disabled');
    }
    else
    {
      number.removeClass('disabled');
      number.find('div').removeClass('disabled');
      number.find('input').prop('disabled', false).removeClass('disabled');
    }
  });
