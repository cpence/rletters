BowerRails.configure do |bower_rails|
  bower_rails.root_path = Rails.root
  bower_rails.install_before_precompile = true
  bower_rails.resolve_before_precompile = true
end
