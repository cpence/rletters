# -*- encoding : utf-8 -*-

# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.wrappers :foundation, class: :input, hint_class: :field_with_hint,
                  error_class: :error do |b|
    b.use :html5
    b.use :placeholder

    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly

    b.use :label_input
    b.use :error, wrap_with: { tag: :small }
  end

  config.boolean_style = :nested
  config.button_class = 'button'
  config.error_notification_class = 'alert-box alert'
  config.form_class = :custom

  config.default_wrapper = :foundation
end
