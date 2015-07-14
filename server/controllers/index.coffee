async = require 'async'
path = require 'path'
fs = require 'fs'
Tag = require '../models/tag'
Event = require '../models/event'
Contact = require '../models/contact'
User  = require '../models/user'
cozydb = require 'cozy-db-pouchdb'
WebDavAccount = require '../models/webdavaccount'


# Tell if the compiled version of jade templates can be used or not.
getTemplateExtension = ->
    # If run from build/, templates are compiled to JS
    # otherwise, they are in jade
    filePath = path.resolve __dirname, '../../client/index.js'
    runFromBuild = fs.existsSync filePath
    extension = if runFromBuild then 'js' else 'jade'
    return extension


module.exports.index = (req, res) ->
    async.parallel [
        (done) -> Contact.all (err, contacts) ->
            return done err if err
            for contact, index in contacts
                contacts[index] = contact.asNameAndEmails()
            done null, contacts

        (cb) -> Tag.all cb
        (cb) -> Event.all cb
        (cb) -> cozydb.api.getCozyInstance cb
        (cb) -> WebDavAccount.first cb

    ], (err, results) ->

        if err then res.send
            error: 'Server error occurred while retrieving data'
            stack : err.stack
        else

            [contacts, tags, events, instance, webDavAccount] = results

            locale = instance?.locale or 'en'
            if webDavAccount?
                webDavAccount.domain = instance?.domain or ''

            extension = getTemplateExtension()
            res.render "index.#{extension}", imports: """
                window.locale = "#{locale}";
                window.inittags = #{JSON.stringify tags};
                window.initevents = #{JSON.stringify events};
                window.initcontacts = #{JSON.stringify contacts};
                window.webDavAccount = #{JSON.stringify webDavAccount};
            """

module.exports.userTimezone = (req, res) ->

    if req.query.keys isnt "timezone"
        res.send 403, "keys not exposed"
    else
        res.send User.timezone
