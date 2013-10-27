# -*- encoding : utf-8 -*-

# Template handler for Markdown-based templates
#
# This handler supports compiled ERB within Markdown templates, as well.
module MarkdownHandler
  # @api private
  # @return [Module] the ERB template handler
  def self.erb
    @erb ||= ActionView::Template.registered_template_handler(:erb)
  end

  # Render a Markdown template
  #
  # @api private
  # @return [String] the HTML source
  def self.call(template)
    compiled_source = erb.call(template)
    "Kramdown::Document.new(begin;#{compiled_source};end, auto_ids: false).to_html"
  end
end

ActionView::Template.register_template_handler :md, MarkdownHandler
ActionView::Template.register_template_handler :markdown, MarkdownHandler
