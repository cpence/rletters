
# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Also precompile the foundation_emails css. This is likely a bug; fixme.
Rails.application.config.assets.precompile += %w{foundation_emails.css}
