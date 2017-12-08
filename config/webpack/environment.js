const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

// Load the ProvidePlugin to get jQuery and Bootstrap working
environment.plugins.set(
  'Provide',
  new webpack.ProvidePlugin({
    $: "jquery",
    jQuery: "jquery",
    "window.jQuery": "jquery",

    Tether: "tether",
    "window.Tether": "tether",

    d3: "d3",

    Alert: "exports-loader?Alert!bootstrap/js/dist/alert",
    Button: "exports-loader?Button!bootstrap/js/dist/button",
    Carousel: "exports-loader?Carousel!bootstrap/js/dist/carousel",
    Collapse: "exports-loader?Collapse!bootstrap/js/dist/collapse",
    Dropdown: "exports-loader?Dropdown!bootstrap/js/dist/dropdown",
    Modal: "exports-loader?Modal!bootstrap/js/dist/modal",
    Popover: "exports-loader?Popover!bootstrap/js/dist/popover",
    Scrollspy: "exports-loader?Scrollspy!bootstrap/js/dist/scrollspy",
    Tab: "exports-loader?Tab!bootstrap/js/dist/tab",
    Tooltip: "exports-loader?Tooltip!bootstrap/js/dist/tooltip",
    Util: "exports-loader?Util!bootstrap/js/dist/util",
  })
)

// Tell the CSS loader where to find Bootstrap
environment.loaders.get('style').use.push(
  {
    loader: 'sass-resources-loader',
    options: {
      resources: ['./node_modules/bootstrap-sass/assets/stylesheets/bootstrap/_variables.scss',
                  './app/javascript/bootstrap_variables.scss']
    }
  }
)

module.exports = environment
