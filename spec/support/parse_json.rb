# -*- encoding : utf-8 -*-

# This is a nice idea to DRY-up JSON API specs, thanks to
# http://matthewlehner.net/rails-api-testing-guidelines/
module ParseJson
  def json
    @json ||= JSON.parse(response.body)
  end
end
