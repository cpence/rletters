
module Admin
  # Customizable bits of content
  #
  # In a few places on an RLetters site, there are various snippets of
  # information that should be customized by each site's administrator. This
  # model represents that information in the database. The list of possible
  # snippets is generated in advance, at installation time (via database
  # seeding; see the `db/seeds` directory), and these snippets may then be
  # edited in the administration panel. Content is stored in the Markdown
  # format for easy editing, and will also be passed through ERB before
  # Markdown, so any variables accessible at the time of the call will be
  # available (such as environment variables).
  #
  # @!attribute name
  #   @raise [RecordInvalid] if the name is missing (`validates :presence`)
  #   @return [String] Name of this snippet (an internal ID)
  # @!attribute language
  #   @raise [RecordInvalid] if the language is missing (`validates :presence`)
  #   @return [String] Language of this snippet (in Rails locale code form)
  # @!attribute content
  #   @return [String] Markdown content for this snippet
  class Snippet < ApplicationRecord
    self.table_name = 'admin_snippets'
    validates :name, presence: true
    validates :language, presence: true

    # @return [String] Friendly name of this snippet (looked up in locale)
    def friendly_name
      ret = I18n.t("snippets.#{name}", default: '')
      return name if ret.blank?
      ret
    end

    # Render the snippet for a particular name.  This will return an empty
    # string if an invalid name is passed.
    #
    # @param [String] name The internal ID of the snippet to render (*not* the
    #   friendly name)
    # @param [Symbol] language The language of the snippet to render (defaults
    #   to current locale)
    # @return [String] HTML output of rendering this snippet to Markdown
    def self.render(name, language = nil)
      language = I18n.locale unless language

      snippet = find_by(name: name, language: language)
      return '' unless snippet

      snippet.render
    end

    # Render this snippet.
    #
    # @return [String] HTML output of rendering this snippet to Markdown
    def render
      erb_page = ERB.new(content).result(binding)
      Kramdown::Document.new(erb_page).to_html.html_safe
    end
  end
end
