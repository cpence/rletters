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
