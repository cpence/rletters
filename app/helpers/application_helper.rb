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
  def translate_markdown(key, options = {})
    # This method is private, but it's what maps the ".not_found" shortcut
    # style keys to their full equivalents
    key_trans = send(:scope_key_by_partial, key)
    I18n.translate_markdown(key_trans, options).html_safe
  end
  alias_method :t_md, :translate_markdown

  # Render a localized Markdown document
  #
  # This function renders a localized Markdown file located in the locales
  # tree.
  #
  # @api public
  # @param [String] file the document to be rendered
  # @return [SafeBuffer] the rendering result
  # @example Render config/locales/test/test.en.md
  #   <%= render_localized_markdown :test %>
  def render_localized_markdown(file)
    path = Rails.root.join('config', 'locales', file.to_s,
                           "#{file}.#{I18n.locale}.md")

    # Fall back to English if we have to
    unless File.exist?(path)
      if I18n.locale != :en
        path = Rails.root.join('config', 'locales', file.to_s,
                               "#{file}.en.md")
      end
    end

    # Give up if we can't find it
    unless File.exist?(path)
      fail I18n::MissingTranslationData.new(I18n.locale,
                                            "localized_markdown.#{file}",
                                            {})
    end

    render(file: path).html_safe
  end

  # Elements of the flash hash for which we have custom CSS classes
  FLASH_CLASSES = %w{ notice alert success }

  # Create Foundation markup for the flashes
  #
  # We're styling the background colors for several of the flashes ourselves,
  # so we want to generate that markup here.
  #
  # @api public
  # @return [String] the markup for displaying the flash
  # @example Display all the flashes
  #   <%= render_flash %>
  def render_flash
    ''.html_safe.tap do |content|
      flash.each do |key, value|
        c = "flash-#{key.to_s}" if FLASH_CLASSES.include?(key.to_s)
        c ||= 'flash-generic'

        content << content_tag(:div, html_escape(value), class: c)
      end
    end
  end

  # Render a partial from a job
  def render_job_partial(klass, view, args = {})
    path = klass.view_path(partial: view)

    if path
      locals = args[:locals] || {}
      locals[:klass] = klass

      render(args.merge(file: path, locals: locals)).html_safe
    else
      # This is a programmer error, so it should raise an exception
      fail(ActiveRecord::RecordNotFound,
           "Cannot find job view #{view} for class #{klass}")
    end
  end
end
