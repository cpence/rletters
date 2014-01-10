# -*- encoding : utf-8 -*-

class Hash
  # Remove any nil items
  def compact
    delete_if { |k, v| v.nil? }
  end
end
