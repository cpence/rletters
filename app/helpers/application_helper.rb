# -*- encoding : utf-8 -*-

# Markup generators common to all of RLetters
module ApplicationHelper
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
