#!/usr/bin/env coffee
americano = require 'americano'
fs = require 'fs'
path = require 'path'


start = (options, callback) ->

    options ?= {}
    options.name = 'Calendar'
    options.port = options.port
    options.host = process.env.HOST or "0.0.0.0"
    options.root = options.root or __dirname

    options.dbName = process.env.POUCHDB_NAME or 'db'
    configPath = path.join process.cwd(), 'config.json'
    unless fs.existsSync configPath
        config = apps: {}
        fs.writeFileSync configPath, JSON.stringify config

    americano.start options, (err, app, server) ->
        callback err, app, server


if not module.parent
    port = process.env.PORT or 9113
    start port: port, (err) ->
        if err
            console.log "Initialization failed, not starting"
            console.log err.stack
            process.exit 1

module.exports.start = start
