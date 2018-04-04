
# Enable S3 if requested
if ENV['S3_ACCESS_KEY_ID'] && ENV['S3_SECRET_ACCESS_KEY'] &&
   ENV['S3_BUCKET']
  Paperclip::Attachment.deafult_options[:storage] = :s3
  Paperclip::Attachment.default_options[:s3_credentials] = {
    access_key_id: ENV['S3_ACCESS_KEY_ID'],
    secret_access_key: ENV['S3_SECRET_ACCESS_KEY']
  }
  Paperclip::Attachment.default_options[:s3_permissions] = 'private'
  Paperclip::Attachment.default_options[:bucket] = ENV['S3_BUCKET']
  Paperclip::Attachment.default_options[:s3_region] = ENV['S3_REGION']

  Paperclip::Attachment.default_options[:path] = ':class/:attachment/:id/:filename'
else
  Paperclip::Attachment.default_options[:storage] = :filesystem

  path = ENV['FILE_PATH'] || Rails.root.join('tmp', 'file_storage')
  path = File.join(path, ':class', ':attachment', ':id', ':filename')

  Paperclip::Attachment.default_options[:path] = path
end

# Don't do any processing to the files as we save them.
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
