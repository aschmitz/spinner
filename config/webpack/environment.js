const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

// Add an ProvidePlugin
environment.plugins.prepend('Provide',  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    jquery: 'jquery',
//    ActionCable: 'actioncable',
  })
)

const config = environment.toWebpackConfig()

config.resolve.alias = {
  jquery: "jquery/src/jquery",
}

module.exports = environment
