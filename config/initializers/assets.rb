
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile all and only the right things. This needs to be in an initializer,
# as we have to have it called *after* Rails has initialized its default list
# of precompiles, which we're overriding here. (The default Rails behavior will
# precompile anything called 'application.js', even in the Node.js modules,
# which is bad.)
# Rails.application.config.assets.precompile = [
#   'application.js',
#   'application.css',
#   %r(bootstrap-sass/assets/fonts/bootstrap/[\w-]+\.(?:eot|svg|ttf|woff2?)$)
# ]
