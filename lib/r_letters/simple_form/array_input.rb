
module RLetters
  # All custom input modules for SimpleForm
  module SimpleForm
    # An input class that permits an array of values
    #
    # Initially inspired by the guide here, thanks to:
    # http://railsguides.net/simple-form-array-text-input/
    class ArrayInput < ::SimpleForm::Inputs::StringInput
      # @return [String] the input HTMl code
      def input(wrapper_options = nil)
        input_html_options[:type] ||= :string if html5?
        count = object.public_send(attribute_name).size

        object.public_send(attribute_name).each_with_index.map do |array_el, i|
          array_name = "#{object_name}[#{attribute_name}][]"
          array_id = "#{object_name}_#{attribute_name}_#{i}"

          opts = input_html_options.merge(value: array_el, name: array_name,
                                          id: array_id)
          opts = merge_wrapper_options(opts, wrapper_options)

          template.content_tag(:div, class: 'input-group') do
            @builder.text_field(attribute_name, opts) + remove_button(array_id)
          end
        end.join.html_safe +
          add_button("#{object_name}_#{attribute_name}_#{count}",
                     "#{object_name}[#{attribute_name}][]")
      end

      private

      def add_button(id, name)
        template.content_tag(:div, class: 'input-group') do
          template.tag(:input, type: 'text', class: 'form-control',
                               name: name, id: id, disabled: true) +
          template.content_tag(:div, class: 'input-group-addon') do
            template.content_tag(:a,
                                 class: 'simple-form-add', href: '#',
                                 'aria-label': I18n.t('simple_form.add')) do
              template.tag(:span, class: 'glyphicon glyphicon-plus',
                                  'aria-hidden': 'true')
            end
          end
        end
      end

      def remove_button(id)
        template.content_tag(:div, class: 'input-group-addon') do
          template.content_tag(:a,
                               class: 'simple-form-remove', href: '#',
                               'aria-label': I18n.t('simple_form.remove')) do
            template.tag(:span, class: 'glyphicon glyphicon-minus',
                                'aria-hidden': 'true')
          end
        end
      end
    end
  end
end
