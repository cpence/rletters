# -*- encoding : utf-8 -*-

# A customizable, static information page
#
# A handful of pages in RLetters are filled with customizable, but static
# information that should be customized by each site's administrator.  This
# model represents those pages in the database.  The list of pages is generated
# in advance, at installation time (via seeding, see the +db/fixtures+
# directory), and these pages may then be edited in the administration panel.
# Pages are stored in the Markdown format for easy editing, and will also be
# passed through ERB before Markdown, so any Rails variables accessible at the
# time of the call will be available (such as the +Settings+ hash).
#
# @!attribute name
#   @return [String] Name of this page (an internal ID)
# @!attribute content
#   @return [String] Markdown content for this page
class MarkdownPage < ActiveRecord::Base
  attr_accessible :name, :content
  
  # @return [String] Friendly name of this page (looked up in locale)
  def friendly_name
    I18n.t("markdown_pages.#{name}")
  end
  
  # Render the Markdown page for a particular name.  This will do nothing if
  # an invalid name is passed.
  #
  # @api public
  # @param [String] name The internal ID of the page to render (*not* the friendly name)
  # @return [String] HTML output of rendering this page to Markdown
  # @example Render the 'faq' page
  #   <%= MarkdownPage.render('faq') %>
  def self.render(name)
    page = MarkdownPage.find_by_name(name) rescue nil
    return unless page
    
    Kramdown::Document.new(ERB.new(page.content).result(binding)).to_html.html_safe
  end
end
