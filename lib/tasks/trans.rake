# -*- encoding : utf-8 -*-

if Rails.env.development?

  namespace :trans do
    require 'net/http'
  
    desc "Downloads translation files from the 99translations server."
    task :download do
      config = load_config
      abort("Unable to open config") unless config
    
      api_key = config['api_key']
      abort( "99translations.com requires configuration. Please configure 99translations in file #{config_file}") if api_key == 'YOUR_API_KEY'
    
      config.keys.each do |f|
        next if f == 'api_key'
        puts "Processing file #{f}"
        tr = config[f]['translations']
        tr.keys.each do |t|
          puts "... downloading #{t} to #{tr[t]}"
          download_file('99translations.com', "/download/#{api_key}/#{f}/#{t}", Rails.root.join(tr[t]))
        end
      end
    end   
  
    ##
    # Generic file download.
    ##
    def download_file(host, url, file)
      begin
        Net::HTTP.start(host) do |http|
          resp = http.get(url)
          case resp
          when Net::HTTPSuccess
          when Net::HTTPInternalServerError
            raise "Internal Server Error"
          else
            raise "Unknown error #{resp}: #{resp.inspect}"
          end
          File.open(file, "wb") do |f|
            f.write(resp.body)
          end
        end
      rescue => e
        puts "ERROR: download failed #{e}"
      end
    end
  
    def load_config
      file = config_file
      puts "Unable to read 99translations configuration file #{file}" and return unless File.file?(file)
      YAML.load_file(file)
    end
  
    def config_file
      Rails.root.join('config', 'trans.yml')
    end         
  end

end
