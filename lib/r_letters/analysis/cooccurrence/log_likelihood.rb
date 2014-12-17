# -*- encoding : utf-8 -*-

module RLetters
  module Analysis
    module Cooccurrence
      # Analyze cooccurrences using log likelihood as the significance measure
      class LogLikelihood < Base
        include Scoring::LogLikelihood
      end
    end
  end
end
