#!/usr/bin/env coffee
americano = require('americano')

start = (root, port, callback) ->
    americano.start
            name: 'Calendar'
            port: port
            host: process.env.HOST or "0.0.0.0"
            root: root or __dirname
    , (app, server) ->
        User = require './server/models/user'
        Realtimer = require 'cozy-realtime-adapter'
        realtime = Realtimer server : server, ['alarm.*', 'event.*']
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
