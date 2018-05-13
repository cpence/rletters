# frozen_string_literal: true

# Overwrite the secret key lines in .env to contain fresh secrets
namespace :rletters do
  namespace :secrets do
    desc 'Print environment variable values for secret keys'
    task :print do
      new_key_base = SecureRandom.hex(128)
      new_devise_key = SecureRandom.hex(128)
      env_file = Rails.root.join('.env')

      puts 'Set the following environment variables:'
      puts "SECRET_KEY_BASE=#{new_key_base}"
      puts "DEVISE_SECRET_KEY=#{new_devise_key}"
    end

    desc 'Overwrite secret key values in .env with new keys'
    task :env do
      new_key_base = SecureRandom.hex(128)
      new_devise_key = SecureRandom.hex(128)
      env_file = Rails.root.join('.env')

      # Open up the file and copy it to a temporary location
      Tempfile.open('.env', Rails.root) do |tempfile|
        File.open(env_file).each do |line|
          line = line.gsub(/^(# )?SECRET_KEY_BASE.*$/, "SECRET_KEY_BASE=#{new_key_base}")
          line = line.gsub(/^(# )?DEVISE_SECRET_KEY.*$/, "DEVISE_SECRET_KEY=#{new_devise_key}")
          tempfile.puts(line)
        end

        tempfile.fdatasync
        tempfile.close
        stat = File.stat(env_file)
        FileUtils.chown(stat.uid, stat.gid, tempfile.path)
        FileUtils.chmod(stat.mode, tempfile.path)
        FileUtils.mv(tempfile.path, env_file)
      end
    end
  end
end
