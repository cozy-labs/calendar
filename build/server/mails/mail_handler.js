// Generated by CoffeeScript 1.7.1
var CozyAdapter, CozyInstance, Event, MailHandler, async, e, fs, jade, log, moment;

async = require('async');

jade = require('jade');

fs = require('fs');

moment = require('moment');

log = require('printit')({
  prefix: 'MailHandler',
  date: true
});

Event = require('../models/event');

CozyInstance = require('../models/cozy_instance');

try {
  CozyAdapter = require('americano-cozy-pouchdb/node_modules/jugglingdb-pouchdb-adapter');
} catch (_error) {
  e = _error;
  CozyAdapter = require('jugglingdb-cozy-adapter');
}

module.exports = MailHandler = (function() {
  function MailHandler() {
    var file;
    this.templates = {};
    file = __dirname + '/mail_invitation.jade';
    fs.readFile(file, 'utf8', (function(_this) {
      return function(err, jadeString) {
        if (err) {
          throw err;
        }
        return _this.templates.invitation = jade.compile(jadeString);
      };
    })(this));
    file = __dirname + '/mail_update.jade';
    fs.readFile(file, 'utf8', (function(_this) {
      return function(err, jadeString) {
        if (err) {
          throw err;
        }
        return _this.templates.update = jade.compile(jadeString);
      };
    })(this));
    file = __dirname + '/mail_delete.jade';
    fs.readFile(file, 'utf8', (function(_this) {
      return function(err, jadeString) {
        if (err) {
          throw err;
        }
        return _this.templates.deletion = jade.compile(jadeString);
      };
    })(this));
  }

  MailHandler.prototype.sendInvitations = function(event, dateChanged, callback) {
    var guests, needSaving;
    guests = event.toJSON().attendees;
    needSaving = false;
    return CozyInstance.getURL((function(_this) {
      return function(err, domain) {
        if (err) {
          log.error('Cannot get Cozy instance');
          console.log(err.stack);
          return callback();
        }
        return async.forEach(guests, function(guest, cb) {
          var date, dateFormat, ismail, mailOptions, subject, template, url;
          ismail = guest.status === 'INVITATION-NOT-SENT' || (guest.status === 'ACCEPTED' && dateChanged);
          if (guest.status === 'INVITATION-NOT-SENT' || (guest.status === 'ACCEPTED' && dateChanged)) {
            subject = "Invitation: " + event.description;
            if (dateChanged) {
              template = _this.templates.update;
            } else {
              template = _this.templates.invitation;
            }
          } else {
            return cb();
          }
          dateFormat = 'MMMM Do YYYY, h:mm a';
          date = moment(event.start).format(dateFormat);
          url = "https://" + domain + "/public/calendar/events/" + event.id;
          mailOptions = {
            to: guest.email,
            subject: subject,
            html: template({
              event: event.toJSON(),
              key: guest.key,
              date: date,
              url: url
            }),
            content: "Hello, I would like to invite you to the following event:\n\n" + event.description + " @ " + event.place + "\non " + date + "\nWould you be there?\n\nyes\n" + url + "?status=ACCEPTED&key=" + guest.key + "\n\nno\n" + url + "?status=DECLINED&key=" + guest.key
          };
          return CozyAdapter.sendMailFromUser(mailOptions, function(err) {
            if (!err) {
              needSaving = true;
              guest.status = 'NEEDS-ACTION';
            } else {
              log.error("An error occured while sending invitation");
              console.log(err.stack);
            }
            return cb(err);
          });
        }, function(err) {
          if (err) {
            return callback(err);
          } else if (!needSaving) {
            return callback();
          } else {
            return event.updateAttributes({
              attendees: guests
            }, callback);
          }
        });
      };
    })(this));
  };

  MailHandler.prototype.sendDeleteNotification = function(event, callback) {
    return async.forEach(event.toJSON().attendees, (function(_this) {
      return function(guest, cb) {
        var date, dateFormat, mailOptions;
        if (guest.status !== 'ACCEPTED') {
          return cb(null);
        }
        dateFormat = 'MMMM Do YYYY, h:mm a';
        date = moment(event.start).format(dateFormat);
        mailOptions = {
          to: guest.email,
          subject: "This event has been canceled: " + event.description,
          content: "This event has been canceled:\n" + event.description + " @ " + event.location + "\non " + date,
          html: _this.templates.deletion({
            event: event.toJSON(),
            key: guest.key,
            date: date
          })
        };
        return CozyAdapter.sendMailFromUser(mailOptions, function(err) {
          var needSaving;
          if (!err) {
            needSaving = true;
            guest.status = 'NEEDS-ACTION';
          } else {
            log.error("An error occured while sending invitation");
            console.log(err.stack);
          }
          return cb(err);
        });
      };
    })(this), callback);
  };

  return MailHandler;

})();
