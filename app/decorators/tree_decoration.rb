
# Code for decorating any collections representable as trees
module TreeDecoration
  # Render a Nestable list for a `closure_tree` collection
  #
  # @return [String] HTML markup for the Nestable list
  def as_nestable_list(&block)
    h.content_tag(:div, class: 'dd') do
      nestable_list_recursive(self, block)
    end
  end

  private

  # Recurse through a collection to produce a multi-level list
  #
  # @return [String] the `ol` tag for this root
  def nestable_list_recursive(items, block)
    h.content_tag(:ol, class: 'dd-list') do
      tags = items.map do |item|
        h.content_tag(:li, class: 'dd-item', data: { id: item.to_param }) do
          content = h.capture_haml { block.call(item) }
          recurse = if item.children.empty?
                      ''.html_safe
                    else
                      nestable_list_recursive(item.children, block)
                    end

          content + recurse
        end
      end

      tags.join.html_safe
    end
  end
end
