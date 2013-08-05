# -*- encoding : utf-8 -*-

# Ruby's internationalization module
module I18n

  extend(
    Module.new do

      # Patch the global Ruby internationalization module to support Markdown
      #
      # This method grabs a translation from the database and runs it through
      # Markdown before returning it.  Note that this method does *not* call
      # html_safe by default; if you need that you should call it yourself.
      #
      # @api public
      # @param [String] key the lookup key for the translation requested
      # @return [String] the requested translation, parsed as Markdown
      # @example Parse the translation for +error.not_found+ as Markdown
      #   <%= translate_markdown(:"error.not_found") %>
      def translate_markdown(key)
        Kramdown::Document.new(I18n.t(key)).to_html.html_safe
      end
      alias_method :t_md, :translate_markdown

    end)

end
