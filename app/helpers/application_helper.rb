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
  #   <%= t_md(:"error.not_found") %>
  def t_md(key)
    key_trans = key

    # This was borrowed from ActionView::Helpers::TranslationHelper#scope_key_by_partial
    if key.to_s.first == "."
      if @virtual_path
        key_trans = @virtual_path.gsub(/[\/_?]/, ".") + key.to_s
      else
        raise "Cannot use t(#{key.inspect}) shortcut because path is not available"
      end
    end
    
    Kramdown::Document.new(I18n.t(key_trans)).to_html.html_safe
  end
end
