
namespace :setting do
  desc 'Set the value of a setting in the database'
  task :set, [:setting, :value] => :environment do |_, args|
    unless args[:setting] && args[:value]
      abort 'Must specify both setting and value to set in the database'
    end

    key = args[:setting].to_sym
    unless Admin::Setting.valid_keys.include? key
      abort "Key #{args[:setting]} is not a valid setting"
    end

    method = "#{args[:setting]}=".to_sym
    Admin::Setting.send(method, args[:value])
  end

  desc 'Get the value of a setting in the database'
  task :get, [:setting] => :environment do |_, args|
    abort 'Must specify setting to get' unless args[:setting]

    key = args[:setting].to_sym
    unless Admin::Setting.valid_keys.include? key
      abort "Key #{args[:setting]} is not a valid setting"
    end

    puts "Setting '#{key}': '#{Admin::Setting.send(key)}'"
  end
end
