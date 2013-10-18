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
    key_trans = send(:scope_key_by_partial, key)
    I18n.translate_markdown(key_trans).html_safe
  end
  alias_method :t_md, :translate_markdown

  # Elements of the flash hash for which we have custom CSS classes
  FLASH_CLASSES = %w{ notice alert success }

  # Create Foundation markup for a flash
  #
  # We're styling the background colors for several of the flashes ourselves,
  # so we want to generate that markup here.
  #
  # @api public
  # @param [Symbol] key the flash key
  # @param [Symbol] value the flash contents
  # @return [String] the markup for displaying the flash
  # @example Display an alert flash
  #   <%= render_flash(:alert, 'Oh no!')
  def render_flash(key, value)
    c = "flash-#{key.to_s}" if FLASH_CLASSES.include?(key.to_s)
    c ||= "flash-generic"

    content_tag(:div, class: c) { h(value) }
  end

  # Render a partial from a job
  def render_job_partial(klass, view, args = {})
    path = klass.view_path(partial: view)

    if path
      render(args.merge(file: path)).html_safe
    else
      "<p><strong>ERROR: Cannot find job view #{view} for class #{klass}".html_safe
    end
  end

end
