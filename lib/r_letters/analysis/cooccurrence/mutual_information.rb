
module RLetters
  module Analysis
    module Cooccurrence
      # Analyze coocurrences using mutual information as the significance
      # measure
      class MutualInformation < Base
        include Scoring::MutualInformation
      end
    end
  end
end
