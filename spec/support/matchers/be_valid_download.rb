# -*- encoding : utf-8 -*-
RSpec::Matchers.define :be_valid_download do |mime|
  match do |actual|
    actual.success? == true && actual.content_type == mime && actual.body.length != 0
  end

  failure_message do |actual|
    "expected that response would be a non-zero-length download of mime type #{expected}"
  end

  failure_message_when_negated do |actual|
    "expected that response would not be a non-zero-length download of mime type #{expected}"
  end

  description do
    "be a non-zero-length download of mime type #{expected}"
  end
end
