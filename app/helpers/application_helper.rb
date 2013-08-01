# -*- encoding : utf-8 -*-

# Markup generators common to all of RLetters
module ApplicationHelper

  # Fetch a translation and run it through a Markdown parser
  #
  # Some translations are stored in the translation database as Markdown
  # markup.  This helper fetches them and then runs them through Kramdown.
  #
  # @api public
  # @param [String] key the lookup key for the translation requested
  # @return [String] the requested translation, parsed as Markdown
  # @example Parse the translation for +error.not_found+ as Markdown
  #   <%= translate_markdown(:"error.not_found") %>
  def translate_markdown(key)
    # This method is private, but it's what maps the ".not_found" shortcut
    # style keys to their full equivalents
    key_trans = self.send(:scope_key_by_partial, key)
    I18n.translate_markdown(key_trans).html_safe
  end
  alias :t_md :translate_markdown
end
