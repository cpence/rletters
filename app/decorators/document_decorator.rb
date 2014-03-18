# -*- encoding : utf-8 -*-

class DocumentDecorator < Draper::Decorator
  delegate_all

  # Get the short, formatted representation of a document
  #
  # This function returns the short bibliographic entry for a document that
  # will appear in the search results list.  The formatting here depends on
  # the current user's settings.  By default, we use a partial that does some
  # nice standard formatting.  The user can set, however, to format the
  # bibliographic entries using their favorite CSL style.
  #
  # @api public
  # @param [Document] doc document for which bibliographic entry is desired
  # @return [String] bibliographic entry for document
  # @example Get the entry for a given document
  #   decorated_document.citation
  #   # =>  "Johnson, W. 2000. ..."
  def citation
    if h.user_signed_in? && h.current_user.csl_style
      if fulltext_url
        cloud_icon = h.content_tag(:span, '',
                                   data: { tooltip: true },
                                   title: I18n.t('search.document.cloud_tooltip'),
                                   class: 'icon fi-upload-cloud has-tip')
      else
        cloud_icon = ''
      end

      csl = RLetters::Documents::AsCSL.new(object).entry(h.current_user.csl_style)
      return (csl + cloud_icon).html_safe
    end

    h.render partial: 'document', locals: { document: self }
  end
end
