// ---------------------------------------------------------------------------
// Row building support for search#advanced

function setButtonVisibility(row, add, remove)
{
  row.find('a.add-button').css('visibility', (add ? 'visible' : 'hidden'));
  row.find('a.remove-button').css('visibility', (remove ? 'visible' : 'hidden'));
}

function updateAdvancedRows()
{
  var rowContainer = $('#advanced-rows');
  if (rowContainer.length === 0)
    return;

  rows = rowContainer.find('.advanced-row');
  if (rows.length === 0)
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
  $('.bool-group select').css('visibility', 'visible');
  $('.bool-group select').last().css('visibility', 'hidden');

  // If there's only one row, it gets a plus button and no minus button
  if (rows.length == 1)
  {
    setButtonVisibility(rows.first(), true, false);
    return;
  }

  var i, row;

  // Hide the plus button on all but the last row
  row = rows.first();
  for (i = 0 ; i < rows.length - 1 ; i++)
  {
    setButtonVisibility(row, false, true);
    row = row.next();
  }

  row = rows.last();
  setButtonVisibility(row, true, true);
}

function addRow(button)
{
  container = $('#advanced-rows');
  if (container.length === 0)
  {
    alert("ERROR: Could not find row container from add row button");
    return;
  }

  rows = container.find('.advanced-row');
  if (rows.length === 0)
  {
    alert("ERROR: Could not find rows from add row button");
    return;
  }

  first_row = rows.first();
  new_row = first_row.clone();
  new_row.appendTo(container);

  updateAdvancedRows();
}

function removeRow(button)
{
  row = button.parent().parent().parent();
  row.remove();

  updateAdvancedRows();
}

$(document).ready(updateAdvancedRows);
