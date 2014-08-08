americano = require 'americano-cozy-pouchdb'
path = require 'path'
log = require('printit')
    prefix: 'Calendar'

module.exports = User = americano.getModel 'User',
    email    : type : String
    timezone : type : String, default: "Europe/Paris"


User.all = (callback) ->
    User.request "all", callback

User.destroyAll = (callback) ->
    User.requestDestroy "all", callback

User.getTimezone = (callback) ->
    configPath = path.join process.cwd(), 'config'

    try
        user = require configPath
    catch err
        console.log err
        log.error 'No config file found at ' + configPath
        user = {}

    user.timezone ?= "Europe/Paris"
    callback null, user.timezone

User.updateTimezone = (callback) ->
    User.getTimezone (err, timezone) ->
        User.timezone = timezone
        callback?()
