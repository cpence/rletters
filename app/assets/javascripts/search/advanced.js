// ---------------------------------------------------------------------------
// Row building support for search#advanced

function updateAdvancedRows()
{
  var rowContainer = $('#advanced-rows');
  if (rowContainer.length === 0)
    return;

  // Reset all of the IDs on these rows
  $('.advanced-row .field-group label').attr('for', function(arr) {
    return 'field_' + arr;
  });

  $('.advanced-row .field-group select').attr('id', function(arr) {
    return 'field_' + arr;
  }).attr('name', function (arr) {
    return 'field_' + arr;
  });

  $('.advanced-row .value-group label').attr('for', function(arr) {
    return 'value_' + arr;
  });

  $('.advanced-row .value-group input').attr('id', function(arr) {
    return 'value_' + arr;
  }).attr('name', function(arr) {
    return 'value_' + arr;
  });

  // Show the boolean toggles on every row but the last one
  showAndEnable('.advanced-row:not(:last-of-type) .bool-group select');
  hideAndDisable('.advanced-row:last-of-type .bool-group select');

  // Show all the minus buttons
  $('.advanced-remove-button').css('visibility', 'visible');

  // Hide all but the last plus button
  $('.advanced-add-button').css('visibility', 'hidden');
  $('.advanced-add-button').last().css('visibility', 'visible');

  // If there's only one row, nothing gets minus buttons
  if ($('.advanced-row').length == 1)
    $('.advanced-remove-button').css('visibility', 'hidden');
}

function addSearchAdvancedRow(button)
{
  container = $('#advanced-rows');
  if (container.length === 0)
  {
    alert("ERROR: Could not find row container from add row button");
    return;
  }

  new_row = $(window.rlRowMarkup);
  new_row.appendTo(container);

  updateAdvancedRows();
}

function removeSearchAdvancedRow(button)
{
  row = button.parents('.advanced-row').first();
  label_row = row.prev();
  label_row.remove();
  row.remove();

  updateAdvancedRows();
}

function setAdvancedButtons() {
  $(document).on('click', '.advanced-add-button', function() {
    addSearchAdvancedRow($(this));
    return false;
  });
  $(document).on('click', '.advanced-remove-button', function() {
    removeSearchAdvancedRow($(this));
    return false;
  });
}

function fieldDropdownChange(event)
{
  var field = $(this);
  var option = $(this).find('option:selected');
  var row = field.parents('.advanced-row').first();

  // See if the row has a typeahead attached or not
  if (row.data('typeahead-active') === undefined)
    row.data('typeahead-active', false);
  var active = row.data('typeahead-active');

  // See if we need one or not
  var val = option.attr('value');
  var need_active = (val == 'authors' || val == 'journal_exact');

  // If we don't have one and don't need it, we're done
  if (!active && !need_active)
    return;

  var input = row.find('.value-group input');

  // If it's active, destroy it regardless
  if (active)
  {
    // Destroy the typeahead
    input.typeahead('destroy');
    row.data('typeahead-active', false);
  }

  // Create one if we need to
  if (!need_active)
    return;

  var bloodhound, name;

  if (val == 'authors')
  {
    name = 'authors';
    bloodhound = window.rlBloodhoundAuthors;
  }
  else
  {
    name = 'journals';
    bloodhound = window.rlBloodhoundJournals;
  }

  input.typeahead({ highlight: true },
  {
    name: name,
    displayKey: 'val',
    source: bloodhound.ttAdapter()
  });
  row.data('typeahead-active', true);
}

function createAutocompleteSystem()
{
  container = $('#advanced-rows');
  if (container.length === 0)
    return;

  // Create a pair of datasets for typeahead
  window.rlBloodhoundAuthors = new Bloodhound({
    name: 'authors',
    remote: {
      url: '/lists/authors?q=%QUERY',
      wildcard: '%QUERY'
    },
    datumTokenizer: function(d) {
      Bloodhound.tokenizers.nonword(d.val);
    },
    queryTokenizer: Bloodhound.tokenizers.nonword
  });
  window.rlBloodhoundJournals = new Bloodhound({
    name: 'journals',
    remote: {
      url: '/lists/journals?q=%QUERY',
      wildcard: '%QUERY'
    },
    datumTokenizer: function(d) {
      Bloodhound.tokenizers.whitespace(d.val);
    },
    queryTokenizer: Bloodhound.tokenizers.whitespace
  });

  window.rlBloodhoundAuthors.initialize();
  window.rlBloodhoundJournals.initialize();

  // Hook the change events to create and destroy typeaheads
  $(document).on('change', '.advanced-row .field-group select',
                 fieldDropdownChange);
}

$(updateAdvancedRows);
$(createAutocompleteSystem);
$(setAdvancedButtons);
