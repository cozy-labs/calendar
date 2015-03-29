americano = require 'americano'
path = require 'path'
fs = require 'fs'

publicPath = path.join __dirname, "..", "client/public"
staticMiddleware = americano.static publicPath, maxAge: 86400000
publicStatic = (req, res, next) ->

    # Allows assets to be loaded from any route
    detectAssets = /\/(stylesheets|javascripts|images|fonts)+\/(.+)$/
    assetsMatched = detectAssets.exec req.url

    if assetsMatched?
        req.url = assetsMatched[0]

    staticMiddleware req, res, (err) -> next err

module.exports =

    common:
        use: [
            staticMiddleware
            publicStatic
            americano.bodyParser keepExtensions: true
        ]
        useAfter: [
            americano.errorHandler
                dumpExceptions: true
                showStack: true
        ]
        set:
             views: './client'
        engine:
            js: (path, locales, callback) ->
                callback null, require(path)(locales)

    development: [
        americano.logger 'dev'
    ]

    production: [
        americano.logger 'short'
    ]

    plugins: [
        'cozy-db-pouchdb'
    ]
