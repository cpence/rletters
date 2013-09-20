# -*- encoding : utf-8 -*-

# A list of common words to exclude from analysis
#
# We often need to remove commonly occurring words from bodies of text for
# analysis purposes.  To make that process easy, we seed lists of those words
# into the database.
#
# @!attribute lanuage
#   @return [String] Language for this stop list
# @!attribute list
#   @return [String] Space-separated list of common words to exclude
class StopList < ActiveRecord::Base
end
