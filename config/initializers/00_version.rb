# frozen_string_literal: true

def get_revision
  revision_path = Rails.root.join('REVISION')
  if File.exist?(revision_path)
    return File.read(revision_path).strip
  elsif Rails.env.development?
    return `git rev-parse HEAD`.strip
  end

  return nil
end

Rails.application.config.version = get_revision
