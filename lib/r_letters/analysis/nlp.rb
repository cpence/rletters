# -*- encoding : utf-8 -*-

module RLetters
  module Analysis
    # Code for communicating with our external Stanford NLP tool
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
    end
  end
end
