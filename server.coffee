#!/usr/bin/env coffee
americano = require('americano')

newApp = (root, port, host, callback) ->
    options =
        name: 'Calendar'
        port: port
        host: host or "0.0.0.0"
        root: root or __dirname

    americano.newApp options, callback

start = (root, port, callback) ->
    User = require './server/models/user'
    Realtimer = require 'cozy-realtime-adapter'

    options =
        name: 'Calendar'
        port: port
        host: process.env.HOST or "0.0.0.0"
        root: root or __dirname

    americano.start options, (app, server) ->
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
