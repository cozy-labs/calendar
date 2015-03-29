time = require 'time'
fs = require 'fs'
moment = require 'moment'
multiparty = require 'multiparty'
ical = require 'cozy-ical'

Event = require '../models/event'

module.exports.export = (req, res) ->

    calendarId = req.params.calendarid

    calendar = new ical.VCalendar
        organization: 'Cozy'
        title: 'Cozy Calendar'
        name: calendarId
    Event.byCalendar calendarId, (err, events) ->
        if err
            res.send
                error: true
                msg: 'Server error occurred while retrieving data'
        else
            if events.length > 0
                calendar.add event.toIcal() for event in events

            res.header 'Content-Type': 'text/calendar'
            res.send calendar.toString()

module.exports.import = (req, res, next) ->

    form = new multiparty.Form()
    form.parse req, (err, fields, files) ->

        return next err if err

        cleanUp = ->
            for key, arrfile of files
                for file in arrfile
                    fs.unlink file.path, (err) ->
                        if err
                            console.log "failed to cleanup file", file.path, err

        unless file = files['file']?[0]
            res.send error: 'no file sent', 400
            return cleanUp()

        parser = new ical.ICalParser()
        parser.parseFile file.path, (err, result) ->
            if err
                console.log err
                console.log err.message
                res.send 500, error: 'error occured while saving file'
                cleanUp()
            else
                calendarName = result?.model?.name or 'my calendar'
                res.send 200,
                    events: Event.extractEvents result, calendarName
                    calendar:
                        name: calendarName
                cleanUp()
