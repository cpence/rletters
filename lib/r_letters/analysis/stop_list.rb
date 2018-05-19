# frozen_string_literal: true

module RLetters
  module Analysis
    # Code for parsing and loading lists of stop words
    class StopList
      # Return list of available stop lists
      #
      # @return [Hash<Symbol, Array<String>>] all present stop lists
      def self.available
        file_list = Rails.root.join('lib', 'r_letters', 'analysis',
                                    'stop_list', 'stopwords_*.txt')

        [].tap do |ret|
          Dir[file_list].each do |filename|
            # Extract the language
            base = File.basename(filename)
            m = /stopwords_(..)\.txt/.match(base)
            ret << m[1].to_sym
          end
        end
      end

      # Return the stop list for the requested language
      #
      # @param [Symbol] lang language to request
      # @return [Array<String>] stop words for this language
      def self.for(lang)
        filename = Rails.root.join('lib', 'r_letters', 'analysis',
                                   'stop_list', "stopwords_#{lang}.txt")
        return nil unless File.exist?(filename)

        [].tap do |ret|
          File.open(filename).each_line do |line|
            next if line == ''

            # Both hashes and pipes are used as comments in these files
            keep = line.split('|')[0]
            next if keep == ''

            keep = keep.split('#')[0]
            next if keep == ''

            # There might be more than one word per line, so take care of that
            words = keep.strip.split(' ')
            next if words.empty?

            ret.append(*words)
          end
        end
      end
    end
  end
end
