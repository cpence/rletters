# -*- encoding : utf-8 -*-

module RLetters
  module Analysis
    # Code for communicating with our external Stanford NLP tool
    #
    # @note No test coverage here, as this is a file full of functions that we
    # will stub out in testing.
    #
    # :nocov:
    class NLP
      # Return an array of lemmatized words
      #
      # @api public
      # @param [Array<String>, String] the word or words to lemmatize
      # @return [Array<String>] the words after lemmatization
      # @example Lemmatize some words
      #   RLetters::Analysis::NLP.lemmatize_words('went')
      #   # => ['go']
      def self.lemmatize_words(words)
        if words.is_a?(String)
          words = [words]
        end

        # No lemmatization if we don't have the nlp_tool
        if Admin::Setting.nlp_tool_path.blank?
          return words
        end

        # Call the external tool
        yml = Cheetah.run(Admin::Setting.nlp_tool_path, '-l',
                          stdin: words.join(' '), stdout: :capture)
        YAML.load(yml)
      end

      # Returns an array of words with parts-of-speech tags
      #
      # @api public
      # @param [String] text the text to obtain POS tags for
      # @return [Array<String>] an array of tagged words
      # @example Get parts of speech tags for a sentence
      #   RLetters::Analysis::NLP.parts_of_speech('It was the best of times.')
      #   # => ['It_PRP', 'was_VBD', 'the_DT', 'best_JJS', 'of_IN',
      #         'times_NNS', '._.']
      def self.parts_of_speech(text)
        # No tagging if we don't have the nlp_tool (FIXME: this should
        # probably be an exception, as this is going to return data that
        # the caller can't actually use)
        if Admin::Setting.nlp_tool_path.blank?
          return text.split
        end

        # Call the external tool
        yml = Cheetah.run(Admin::Setting.nlp_tool_path, '-p',
                          stdin: text, stdout: :capture)
        YAML.load(yml)
      end

      # Returns an array of named entity references
      #
      # @api public
      # @param [String] text the text to obtain named entities for
      # @return [Hash] a hash of named entities, grouped by type
      # @example Get parts of speech tags for a sentence
      #   RLetters::Analysis::NLP.parts_of_speech('Saint Petersburg was '
      #     'founded by Tsar Peter the Great on May 27 1703.')
      #   # => { 'PERSON' => ['Petersburg', 'Tsar Peter'] }
      def self.named_entities(text)
        # Return no references if the nlp_tool isn't available
        if Admin::Setting.nlp_tool_path.blank?
          return []
        end

        # Call the external tool
        yml = Cheetah.run(Admin::Setting.nlp_tool_path, '-n',
                          stdin: text, stdout: :capture)
        YAML.load(yml)
      end
    end
  end
end
