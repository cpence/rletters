# -*- encoding : utf-8 -*-

# A CSL style users may select for citation formatting
#
# CSL styles are stored as a single table of styles in the database, which
# cannot be added to or edited by users.  Administrators can add new styles in
# the administration interface.
#
# @!attribute name
#   @return [String] Name of this CSL style
# @!attribute style
#   @return [String] XML source for this CSL style
class CslStyle < ActiveRecord::Base
  attr_accessible :name, :style
end
