
module RLetters
  module Analysis
    module Collocation
      # Analyze collocations using log likelihood as the significance measure
      class LogLikelihood < Base
        include Scoring::LogLikelihood
      end
    end
  end
end
