
module RLetters
  module Visualization
    # Mix-ins to facilitate saving data out to PDF files
    module PDF
      extend ActiveSupport::Concern

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
      def pdf_with_header(header)
        info = {
          :Title        => header,
          :Author       => ENV['APP_NAME'],
          :Creator      => 'RLetters',
          :Producer     => 'Prawn',
          :CreationDate => Time.now
        }

        pdf = Prawn::Document.new(info: info,
                                  page_size: 'LETTER',
                                  page_layout: :landscape,
                                  margin: 72)

        pdf.text header, align: :center, size: 18, style: :bold
        pdf.move_down(20)

        yield(pdf)

        pdf.number_pages('<page>/<total>', at: [pdf.bounds.right - 150, -30],
                                           width: 150,
                                           align: :right)
        pdf.render
      end
    end
  end
end
