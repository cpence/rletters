# -*- encoding : utf-8 -*-

module RLetters
  module Analysis
    module Collocation
      # Analyze collocations using mutual information as the significance
      # measure
      class MutualInformation < Base
        include Scoring::MutualInformation
      end
    end
  end
end
