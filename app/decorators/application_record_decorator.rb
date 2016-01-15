
# A decorator that is generic enough to apply to every model in the app
#
# This is used to add markup generation for the administration panel, which
# needs to work on every model we have.
class ApplicationRecordDecorator < ApplicationDecorator
  # Get the value of an attribute of this model for the admin interface
  #
  # This function handles turning array-form attributes into unordered list
  # tags, as well as generating administration links for relations.
  #
  # @param [Symbol] attribute the attribute to fetch
  # @return [String] the attribute's value
  def admin_value_for(attribute)
    config = object.class.admin_attributes[attribute]
    value = send(attribute)

    return '<nil>' if value.nil?
    unless config&.has_key?(:array)
      return admin_display_value(attribute, value)
    end
    return '<empty>' if value.empty?

    h.content_tag(:ul) do
      h.content_tag_for(:li, value) do |element|
        admin_display_value(attribute, element)
      end
    end
  end

  private

  # Return the value of an attribute, possibly as a link if it's a model
  #
  # @param [Symbol] attribute the attribute to fetch
  # @param [Object] value the particular value object to display. This is
  #   passed in as a parameter to support returning links, for example, to
  #   all members of an array-type attribute.
  # @return [String] attribute value
  def admin_display_value(attribute, value)
    config = object.class.admin_attributes[attribute]
    return value.to_s unless config&.has_key?(:model)

    association = object.class.reflect_on_association(attribute)
    model_name = association.class_name.underscore

    h.link_to(value.to_s,
              h.admin_item_path(model: model_name, id: value.to_param))
  end
end
