# frozen_string_literal: true

module RLetters
  module Visualization
    # Mix-ins to facilitate saving data out to PDF files
    module PDF
      extend ActiveSupport::Concern

      # A list of all the available fonts and their folder names
      FONTS = {
        'Arvo' => 'Arvo',
        'Exo 2' => 'Exo2',
        'Hack' => 'Hack',
        'Inconsolata' => 'InconsolataLGC',
        'Josefin Slab' => 'JosefinSlab',
        'Lato' => 'Lato',
        'Merriweather' => 'Merriweather',
        'Old Standard TT' => 'OldStandard',
        'Roboto' => 'Roboto',
        'Vollkorn' => 'Vollkorn'
      }.freeze

      # Write a PDF to a string, yielding a Prawn PDF document
      #
      # When the PDF document is yielded, the cursor is guaranteed to be at
      # the top left of the document, just below the written header. This
      # method will also number all generated pages of the PDF.
      #
      # @param [String] header The header to write
      # @return [String] The PDF file, as a string
      # @yield [pdf] Yields a Prawn PDF document, for building a PDF
      # @yieldparam [Prawn::Document] pdf The Prawn document object
      def pdf_with_header(header:)
        info = {
          'Title':        header,
          'Author':       ENV['APP_NAME'],
          'Creator':      'RLetters',
          'Producer':     'Prawn',
          'CreationDate': Time.now
        }

        pdf = Prawn::Document.new(info: info,
                                  page_size: 'LETTER',
                                  page_layout: :landscape,
                                  margin: 72)

        # Add all the known font families
        FONTS.each do |name, root|
          add_font_family(pdf: pdf, name: name, root: root)
        end

        # Draw the header
        pdf.font('Roboto') do
          pdf.text(header, align: :center, size: 18, style: :bold)
          pdf.move_down(20)
        end

        yield(pdf)

        # Number the pages
        pdf.fill_color('000000')
        pdf.font('Roboto') do
          pdf.number_pages('<page>/<total>', at: [pdf.bounds.right - 150, -30],
                                             width: 150,
                                             align: :right)
        end

        pdf.render
      end

      private

      # Add a font family to the PDF document
      #
      # All our fonts are stored in the same place, and all but one have all
      # of their styles available, so we can generalize this loading code.
      #
      # @param [Prawn::Document] pdf The document to add fonts to
      # @param [String] name The human-readable name of the family to add
      # @param [String] root The font family root to add
      # @return [void]
      def add_font_family(pdf:, name:, root:)
        # No Bold-Italic variant in OldStandard
        bold_italic_name = if root == 'OldStandard'
                             "#{root}-Bold.ttf"
                           else
                             "#{root}-BoldItalic.ttf"
                           end

        pdf.font_families.update(
          name => {
            normal: Rails.root.join('vendor', 'fonts', root,
                                    "#{root}-Regular.ttf").to_s,
            italic: Rails.root.join('vendor', 'fonts', root,
                                    "#{root}-Italic.ttf").to_s,
            bold: Rails.root.join('vendor', 'fonts', root,
                                  "#{root}-Bold.ttf").to_s,
            bold_italic: Rails.root.join('vendor', 'fonts', root,
                                         bold_italic_name).to_s
          }
        )
      end
    end
  end
end
