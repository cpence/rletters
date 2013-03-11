# -*- encoding : utf-8 -*-

# Set a few Haml options, once it's loaded
ActiveSupport.on_load(:action_vew) do
  Haml::Template.options[:format] = :html5
  Haml::Template.options[:encoding] = Encoding::UTF_8
  Haml::Template.options[:ugly] = true
end
