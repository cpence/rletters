# -*- encoding : utf-8 -*-

# Decorate a category object
#
# This class adds methods to display links related to adding and removing
# a category from search results.
class CategoryDecorator < ApplicationDecorator
  decorates Documents::Category
  delegate_all

  # Return a `<dd>` tag for removing this category
  #
  # @api public
  # @return [String] a definition tag for removing this category
  # @example Display a link to remove the given category
  #   %dl
  #     = f.removal_link
  #     -# ...
  def removal_link
    new_params = toggle_params
    h.link_to(h.search_path(new_params), class: 'btn navbar-btn btn-primary') do
      h.html_escape("#{Documents::Category.model_name.human}: #{name}") +
        close_icon
    end
  end


  # Recursively return the tree links for this category
  #
  # @api public
  # @return [String] a list item for this category and its descendants
  # @example Display this category and its descendants
  #   %ul
  #     %li= c.link_tree
  def link_tree
    ''.html_safe.tap do |content|
      content << toggle_link

      unless leaf?
        content << h.content_tag(:ul) do
          h.content_tag_for(:li, children) do |c|
            CategoryDecorator.decorate(c).link_tree
          end
        end
      end
    end
  end

  # Returns true if this category is currently enabled
  #
  # This is determined solely from the current value of params.
  #
  # @api public
  # @return [Boolean] true if the category is currently enabled
  # @example Find an enabled category
  #   Documents::Category.all.detect { |c| c.enabled }
  def enabled
    h.params[:categories] && h.params[:categories].include?(to_param)
  end

  # Create a link to enable or disable this journal category
  #
  # This method returns the correct link to toggle the state of this category,
  # either to enable or disable it.
  #
  # @api public
  # @return [String] a link to enable/disable this category
  # @example Show a toggle link for this category
  #   %ul
  #     %li= cat.toggle_link
  def toggle_link
    new_params = toggle_params

    if enabled
      h.link_to(h.search_path(new_params)) do
        h.check_box_tag("category_#{to_param}", '1', true, disabled: true) +
          h.content_tag(:span, name)
      end
    else
      h.link_to(h.search_path(new_params)) do
        h.check_box_tag("category_#{to_param}", '1', false, disabled: true) +
          h.content_tag(:span, name)
      end
    end
  end

  private

  # Get the params for enabling or disabling a category
  #
  # We want to enable or disable the category as well as all its descendants
  # with a single click, so this will toggle all of them.
  #
  # @api private
  # @return [Hash] the parameters suitable for toggling this category
  def toggle_params
    h.params.deep_dup.tap do |ret|
      ret[:categories] ||= []

      if enabled
        ret[:categories] -= self_and_ancestors.collect(&:to_param)
        ret[:categories] -= self_and_descendants.collect(&:to_param)
      else
        ret[:categories] += self_and_descendants.collect(&:to_param)
      end

      ret[:categories].uniq!
      ret.delete(:categories) if ret[:categories].empty?
    end
  end
end
