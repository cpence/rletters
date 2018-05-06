# frozen_string_literal: true

# Override the default 'field_with_errors' behavior in Rails to produce the
# kind of invalid markers we want in Bootstrap 4.
Rails.application.config.action_view.field_error_proc = Proc.new do |html_tag, instance|
  class_attr_index = html_tag.index 'class="'

  if class_attr_index
    html_tag.insert class_attr_index+7, 'is-invalid '
  else
    class_attr_index = html_tag.index "class='"
    if class_attr_index
      html_tag.insert class_attr_index+7, 'is-invalid '
    else
      html_tag.insert html_tag.index('>'), ' class="is-invalid"'
    end
  end
end
