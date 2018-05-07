# frozen_string_literal: true

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
      # @param [Array<String>] words the word or words to lemmatize
      # @return [Array<String>] the words after lemmatization
      def self.lemmatize_words(words)
        words = [words] if words.is_a?(String)

        # No lemmatization if we don't have the nlp_tool
        return words if ENV['NLP_TOOL_PATH'].blank?

        # Call the external tool
        yml = Cheetah.run(ENV['NLP_TOOL_PATH'], '-l',
                          stdin: words.join(' '), stdout: :capture)
        YAML.safe_load(yml)
      end

      # Returns an array of words with parts-of-speech tags
      #
      # @param [String] text the text to obtain POS tags for
      # @return [Array<String>] an array of tagged words
      def self.parts_of_speech(text)
        # No tagging if we don't have the nlp_tool (FIXME: this should
        # probably be an exception, as this is going to return data that
        # the caller can't actually use)
        return text.split if ENV['NLP_TOOL_PATH'].blank?

        # Call the external tool
        yml = Cheetah.run(ENV['NLP_TOOL_PATH'], '-p',
                          stdin: text, stdout: :capture)
        YAML.safe_load(yml)
      end

      # Returns an array of named entity references
      #
      # @param [String] text the text to obtain named entities for
      # @return [Hash] a hash of named entities, grouped by type
      def self.named_entities(text)
        # Return no references if the nlp_tool isn't available
        return [] if ENV['NLP_TOOL_PATH'].blank?

        # Call the external tool
        yml = Cheetah.run(ENV['NLP_TOOL_PATH'], '-n',
                          stdin: text, stdout: :capture)
        YAML.safe_load(yml)
      end
    end
    # :nocov:
  end
end
