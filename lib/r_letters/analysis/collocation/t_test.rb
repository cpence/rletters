# -*- encoding : utf-8 -*-

module RLetters
  module Analysis
    module Collocation
      # Analyze collocations using T tests as the significance measure
      class TTest < Base
        include Scoring::TTest
      end
    end
  end
end
