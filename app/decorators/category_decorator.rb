# -*- encoding : utf-8 -*-

class CategoryDecorator < Draper::Decorator
  decorates Documents::Category
  delegate_all

  # Return a +<dd>+ tag for removing this category
  #
  # @api public
  # @return [String] a definition tag for removing this category
  def removal_link
    h.content_tag(:dd, class: 'active') do
      new_params = toggle_params
      h.link_to("#{Documents::Category.model_name.human}: #{name}",
              h.search_path(new_params))
    end
  end


  # Recursively return the tree links for this category
  #
  # @api public
  # @return [String] a list item for this category and its descendants
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

  # @api public
  # @return [Boolean] true if the category is currently enabled
  def enabled
    h.params[:categories] && h.params[:categories].include?(to_param)
  end

  # Create a link to facet by a journal category
  #
  # @api private
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
  # with a single click, so do that here.
  #
  # @api private
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
