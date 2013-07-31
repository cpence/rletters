# -*- encoding : utf-8 -*-
#
# Rake Task for replacing the secret-token in config/initializers/secret_token.rb
#
namespace :secret do
  desc 'Replace the secure secret key in your secret_token.rb'
  task :replace do
    pattern_token  = /(\.secret_token *= *')\w+(')/
    secret_token   = SecureRandom.hex(64)
    pattern_base   = /(\.secret_key_base *= *')\w+(')/
    secret_base    = SecureRandom.hex(64)
    
    filepath = "#{Rails.root}/config/initializers/secret_token.rb"
    content  = File.read(filepath)
    
    unless pattern_token && pattern_base
      STDERR.puts "secret tokens not found in #{filepath}"
      exit 1
    end
    
    # replace the secret token
    content.gsub!(pattern_token, "\\1#{secret_token}\\2")
    content.gsub!(pattern_base, "\\1#{secret_base}\\2")
    
    # write the new configuration
    File.open(filepath, 'w') {|f| f.write(content) }
    
    puts "Secret token successfully replaced"
  end
end
