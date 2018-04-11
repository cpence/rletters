
# Base class from which all our models inherit
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
