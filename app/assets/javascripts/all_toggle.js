
$(document).on('change', 'input[name="job_params[all]"]',
  function(event, data) {
    checked = $(this).is(':checked');

    checkbox = $(this).parent().parent().parent();
    number = $(checkbox).prev();

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
