
module AdminControllerHelper
  # Get the value of an attribute of this model for the admin interface
  #
  # This function handles turning array-form attributes into unordered list
  # tags, as well as generating administration links for relations.
  #
  # @param [Object] object the object to act on
  # @param [Symbol] attribute the attribute to fetch
  # @return [String] the attribute's value
  def admin_value_for(object, attribute)
    config = object.class.admin_attributes[attribute]
    value = object.send(attribute)

    return '<nil>' if value.nil?
    unless config&.has_key?(:array)
      return admin_display_value(object, attribute, value)
    end
    return '<empty>' if value.empty?

    content_tag(:ul) do
      content_tag_for(:li, value) do |element|
        admin_display_value(object, attribute, element)
      end
    end
  end

  # Render a Nestable list for a `closure_tree` collection
  #
  # @param [Array<Object>] roots items to be rendered at root of the tree
  # @return [String] HTML markup for the Nestable list
  def as_nestable_list(roots, &block)
    content_tag(:div, class: 'dd') do
      nestable_list_recursive(roots, block)
    end
  end

  private

  # Return the value of an attribute, possibly as a link if it's a model
  #
  # @param [Object] object the object to act on
  # @param [Symbol] attribute the attribute to fetch
  # @param [Object] value the particular value object to display. This is
  #   passed in as a parameter to support returning links, for example, to
  #   all members of an array-type attribute.
  # @return [String] attribute value
  def admin_display_value(object, attribute, value)
    config = object.class.admin_attributes[attribute]
    return value.to_s unless config&.has_key?(:model)

    association = object.class.reflect_on_association(attribute)
    model_name = association.class_name.underscore

    link_to(value.to_s,
            admin_item_path(model: model_name, id: value.to_param))
  end

  # Recurse through a collection to produce a multi-level list
  #
  # @param [Array<Object>] items items to be rendered at this level of the tree
  # @return [String] the `ol` tag for this root
  def nestable_list_recursive(items, block)
    content_tag(:ol, class: 'dd-list') do
      tags = items.map do |item|
        content_tag(:li, class: 'dd-item', data: { id: item.to_param }) do
          content = capture_with_haml { block.call(item) }
          recurse = if item.children.empty?
                      ''.html_safe
                    else
                      nestable_list_recursive(item.children, block)
                    end

          content.html_safe + recurse
        end
      end

      tags.join.html_safe
    end
  end
end
