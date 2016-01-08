
# Base class from which all our models inherit
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # @return [Hash] Configuration for this model in the administration interface
  #
  #   The keys of this hash can currently include the following:
  #
  #   - :tree - if set, this is a `closure_tree` tree model, and gets a
  #     different collection display page
  #   - :no_create - if set, do not allow new instances of this model to be
  #     created
  #   - :no_delete - if set, do not allow instances of this model to be deleted
  #   - :no_edit - if set, do not allow instances of this model to be edited
  def self.admin_configuration
    {}
  end

  # @return [Hash] Attributes that may be edited in the administration
  #   interface
  #
  #   The keys of this hash should be attribute methods that can be called on
  #   the given model. The values are themselves hashes, which currently can
  #   include the following keys:
  #
  #   - :no_form - if set, do not display this attribute in the edit form
  #   - :no_display - if set, do not display this attribute in the summary
  #     table display
  #   - :form_options - if set, add these options to the SimpleForm control for
  #     the given attribute
  #   - :array - if set, this attribute is an array, and we will have special
  #     form support for it
  def self.admin_attributes
    {}
  end
end
