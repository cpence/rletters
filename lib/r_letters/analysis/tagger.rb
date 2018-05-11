# frozen_string_literal: true

module RLetters
  module Analysis
    # A PoS tagger object
    #
    # This object is expensive to construct, as it loads a variety of word
    # dictionary files from disk. Only create one, and save it at module level
    # to a constant, so that we can use it like a module rather than a class
    # object.
    Tagger = EngTagger.new
  end
end
