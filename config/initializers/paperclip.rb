
# Store all the Paperclip attachments in the database
Paperclip::Attachment.default_options[:storage] = :database
Paperclip::Attachment.default_options[:processors] = []

# Disable the spoof-detection code. The spoof detection code picks up the
# wrong MIME type for about half of my CSV files, which causes maddening
# and unreproducible validation errors. There *should* be a way for end users
# to disable this without a monkey-patch, but there isn't.
module Paperclip
  class MediaTypeSpoofDetector
    def spoofed?
      false
    end
  end
end
