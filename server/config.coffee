americano = require 'americano'
path = require 'path'
fs = require 'fs'

root = path.join path.dirname(fs.realpathSync(__filename))
clientPath = path.join root, '..', 'client'
publicPath = path.join clientPath, 'public'
staticMiddleware = americano.static publicPath,
    maxAge: 86400000

module.exports =

    common:
        use: [
            staticMiddleware
            (req, res, next) ->
                req.url = req.url.replace '/public', ''
                staticMiddleware req, res, (err) ->
                    if req.url isnt req.originalUrl
                        req.url = '/public' + req.url
                    next err

            americano.bodyParser keepExtensions: true
            americano.errorHandler
                dumpExceptions: true
                showStack: true
        ]
        set:
            views: clientPath

    development: [
        americano.logger 'dev'
    ]

    production: [
        americano.logger 'short'
    ]

    plugins: [
        'americano-cozy-pouchdb'
    ]
