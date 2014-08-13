#!/usr/bin/env coffee
americano = require('americano')

newApp = (root, callback) ->
    options =
        name: 'Calendar'
        root: root or __dirname

    americano.newApp options, callback

start = (options, callback) ->

    options ?= {}
    options.name = 'Calendar'
    options.port = options.port
    options.host = process.env.HOST or "0.0.0.0"
    options.root = options.root or __dirname

    americano.start options, (app, server) ->
        User = require './server/models/user'
        Realtimer = require 'cozy-realtime-adapter'
        realtime = Realtimer server: server, ['alarm.*', 'event.*']
        realtime.on 'user.*', -> User.updateTimezone()
        User.updateTimezone (err) ->
            callback err, app, server

if not module.parent
    port = process.env.PORT or 9113
    start null, port, (err) ->
        if err
            console.log "Initialization failed, not starting"
            console.log err.stack
            process.exit 1

module.exports.start = start

module.exports.newApp = newApp
