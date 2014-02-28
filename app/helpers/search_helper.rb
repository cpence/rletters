# -*- encoding : utf-8 -*-

# Markup generators for the search controller
module SearchHelper

  # Return a list of active filters for a Foundation sub-nav
  #
  # @api public
  # @param [RLetters::Solr::SearchResult] result the search result
  # @return [String] active filters in <dd><a> tags
  # @example Get all of the filter removal links
  #   active_filter_list(@result)
  #   # "<dd><a href='...'>Johnson</a></dd>..."
  def active_filter_list(result)
    # If we're entirely non-faceted, then bail
    if params[:fq].blank? && params[:categories].blank?
      return content_tag(:dd) do
        link_to I18n.t('search.index.no_filters'), '#'
      end
    end

    ret = ''.html_safe

    # Remove all
    ret << content_tag(:dd) do
      new_params = params.deep_dup
      new_params.delete(:categories)
      new_params.delete(:fq)

      link_to I18n.t('search.index.remove_all'), search_path(new_params)
    end

    # Categories
    if params[:categories]
      params[:categories].each do |id|
        c = Documents::Category.find(id)

        ret << content_tag(:dd, class: 'active') do
          new_params = params_for_category(c)
          link_to("#{Documents::Category.model_name.human}: #{c.name}",
                  search_path(new_params))
        end
      end
    end

    # Facets
    ret << result.facets.removal_links if result.facets
    ret
  end

  # Return a list of journal categories
  #
  # This function formats the tree of Documents::Category objects for
  # display in the faceting system.
  #
  # @api public
  # @return [String] journal categories, formatted for display
  # @example Display the journal categories
  #   <%= journal_category_list %>
  #   # "<ul><li>Category<ul>..."
  def journal_category_list
    return ''.html_safe if Documents::Category.all.size == 0

    content_tag(:li, content_tag(:strong, I18n.t('search.index.categories'))) +
      content_tag_for(:li, Documents::Category.roots) do |root|
        journal_category_list_for(root)
      end
  end

  # Get the short, formatted representation of a document
  #
  # This function returns the short bibliographic entry for a document that
  # will appear in the search results list.  The formatting here depends on
  # the current user's settings.  By default, we use a jQuery Mobile-formatted
  # partial with an H3 and some P's.  The user can set, however, to format the
  # bibliographic entries using their favorite CSL style.
  #
  # @api public
  # @param [Document] doc document for which bibliographic entry is desired
  # @return [String] bibliographic entry for document
  # @example Get the entry for a given document
  #   document_bibliography_entry(Document.new(authors: 'W. Johnson',
  #                                            year: '2000'))
  #   # "Johnson, W. 2000. ..."
  def document_bibliography_entry(doc)
    if user_signed_in? && current_user.csl_style
      if doc.fulltext_url
        cloud_icon = content_tag(:span, '',
                                 'data-tooltip' => true,
                                 title: t('search.document.cloud_tooltip'),
                                 class: 'icon fi-upload-cloud has-tip')
      else
        cloud_icon = ''
      end

      csl = RLetters::Documents::AsCSL.new(doc).entry(current_user.csl_style)
      return (csl + cloud_icon).html_safe
    end

    render partial: 'document', locals: { document: doc }
  end

  private

  # Recursively get the tree of journal categories
  #
  # @api private
  # @return [String] a list item for this category and its descendants
  def journal_category_list_for(category)
    ''.html_safe.tap do |content|
      content << category_link_for(category)

      unless category.leaf?
        content << content_tag(:ul) do
          content_tag_for(:li, category.children) do |c|
            journal_category_list_for(c)
          end
        end
      end
    end
  end

  # Return true if the category is currently enabled
  #
  # @api private
  def category_enabled(category)
    params[:categories] && params[:categories].include?(category.to_param)
  end

  # Get the params for enabling or disabling a category
  #
  # We want to enable or disable the category as well as all its descendants
  # with a single click, so do that here.
  #
  # @api private
  def params_for_category(category)
    params.deep_dup.tap do |ret|
      ret[:categories] ||= []

      if category_enabled(category)
        ret[:categories] -= category.self_and_ancestors.collect(&:to_param)
        ret[:categories] -= category.self_and_descendants.collect(&:to_param)
      else
        ret[:categories] += category.self_and_descendants.collect(&:to_param)
      end

      ret[:categories].uniq!
      ret.delete(:categories) if ret[:categories].empty?
    end
  end

  # Create a link to facet by a journal category
  #
  # @api private
  def category_link_for(category)
    new_params = params_for_category(category)

    if category_enabled(category)
      link_to(search_path(new_params)) do
        check_box_tag("category_#{category.to_param}", '1', true, disabled: true) +
          content_tag(:span, category.name)
      end
    else
      link_to(search_path(new_params)) do
        check_box_tag("category_#{category.to_param}", '1', false, disabled: true) +
          content_tag(:span, category.name)
      end
    end
  end
end
