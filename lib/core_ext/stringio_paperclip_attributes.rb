# -*- encoding : utf-8 -*-

class StringIO
  # Mimic the original_filename attribute of an uploaded file
  attr_accessor :original_filename

  # Mimic the content_type attribute of an uploaded file
  attr_accessor :content_type
end
