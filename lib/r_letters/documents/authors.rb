
module RLetters
  module Documents
    # The authors of a document
    #
    # This class patches some methods into +Array+ for creating the array of
    # authors from a list and converting it back into its original
    # comma-separated format.
    class Authors < Array
      # Create the array from a comma-separated list
      #
      # @param [String] names the names of the authors, comma-separated
      # @return [Authors] a list of authors for this document
      def self.from_list(names)
        names ||= ''

        array = names.strip.split(',').map do |a|
          RLetters::Documents::Author.new(a.strip)
        end

        Authors.new(array)
      end

      # @return [String] the list of authors as originally passed in to
      #   the constructor
      def to_s
        map(&:full).join(', ')
      end
    end
  end
end
