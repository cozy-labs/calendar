time = require 'time'
fs = require 'fs'
moment = require 'moment'
multiparty = require 'multiparty'
ical = require 'cozy-ical'
Event = require '../models/event'
Alarm = require '../models/alarm'
User = require  '../models/user'

module.exports.export = (req, res) ->
    calendar = Alarm.getICalCalendar()
    Alarm.all (err, alarms) =>
        if err
            res.send error: true, msg: 'Server error occurred while retrieving data'
        else
            Event.all (err, events) =>
                if err then res.send
                        error: true
                        msg: 'Server error occurred while retrieving data'
                else
                    if alarms.length > 0
                        for alarm in alarms
                            calendar.add alarm.timezoneToIcal()
                            calendar.add alarm.toIcal()
                    if events.length > 0
                        calendar.add event.toIcal() for event in events

                    res.header 'Content-Type': 'text/calendar'
                    res.send calendar.toString()


module.exports.import = (req, res) ->
    form = new multiparty.Form()

    form.parse req, (err, fields, files) ->
        console.log fields
        console.log files
        if files.file.length > 0
            file = files.file[0]
            console.log file
            parser = new ical.ICalParser()
            parser.parseFile file.path, (err, result) ->
                if err
                    console.log err
                    console.log err.message
                    res.send error: 'error occured while saving file', 500
                else
                    fs.unlink file.path, ->
                        res.send
                            events: Event.extractEvents result
                            alarms: Alarm.extractAlarms result, User.timezone
        else
            res.send error: 'no file sent', 500
