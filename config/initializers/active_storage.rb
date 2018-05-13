# frozen_string_literal: true

Rails.application.config.active_storage.service =
  if Rails.env.test?
    :test
  elsif ENV['S3_ACCESS_KEY_ID'] && ENV['S3_SECRET_ACCESS_KEY'] &&
        ENV['S3_BUCKET']
    :amazon
  else
    :local
  end

# Send all ActiveStorage jobs to the maintenance queue
Rails.application.config.active_storage.queue = :maintenance

Rails.application.config.after_initialize do
  # Defeat the ActiveStorage MIME type detection. It fails miserably in almost
  # all of our cases.
  # https://github.com/rails/rails/blob/master/activestorage/app/models/active_storage/blob.rb
  ActiveStorage::Blob.class_eval do
    def extract_content_type(io)
      return content_type if content_type
      Marcel::MimeType.for io, name: filename.to_s, declared_type: content_type
    end
  end
end
