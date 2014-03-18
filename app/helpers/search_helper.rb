# -*- encoding : utf-8 -*-

# Markup generators for the search controller
module SearchHelper
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
end
