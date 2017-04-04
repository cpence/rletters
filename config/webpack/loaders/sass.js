const ExtractTextPlugin = require('extract-text-webpack-plugin')

module.exports = {
  test: /\.(scss|sass|css)$/i,
  use: ExtractTextPlugin.extract({
    fallback: 'style-loader',
    use: [
      'css-loader?importLoaders=3',
      'postcss-loader',
      'sass-loader',
      {
        loader: 'sass-resources-loader',
        options: {
          resources: ['./node_modules/bootstrap-sass/assets/stylesheets/bootstrap/_variables.scss',
                      './app/javascript/bootstrap_variables.scss']
        }
      }
    ]
  }),
}
