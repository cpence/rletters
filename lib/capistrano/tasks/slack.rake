require 'net/http'
require 'uri'
require 'json'

namespace :deploy do

  desc 'Notify Slack about a new release'
  task :notify_slack do
    hook_url = fetch(:slack_hook)
    version = fetch(:current_revision) || '(unknown)'

    message = {
      'text': 'A new version of RLetters has just been deployed.',
      'blocks': [
        {
          'type': 'section',
          'text': {
            'type': 'mrkdwn',
            'text': "A new version of RLetters has just been deployed.\n\n*Release:* #{version}"
          }
        }
      ]
    }

    uri = URI.parse(hook_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.path,
                                  'Content-type': 'application/json')
    request.body = message.to_json
    http.request(request)
  end

end
