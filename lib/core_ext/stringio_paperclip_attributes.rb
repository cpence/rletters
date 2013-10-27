# -*- encoding : utf-8 -*-

# Ruby's default StringIO class
#
# We monkey-patch two methods on this class, which allows us to pass a StringIO
# instead of a File object into Paperclip as an attachment object.  This lets
# us build downloads in memory instead of in temporary files on the disk.
class StringIO
  # Mimic the original_filename attribute of an uploaded file
  #
  # @api private
  # @return [String] the original filename of the attachment
  attr_accessor :original_filename

  # Mimic the content_type attribute of an uploaded file
  #
  # @api private
  # @return [String] the content type of the attachment
  attr_accessor :content_type
end
