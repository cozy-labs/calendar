// Generated by CoffeeScript 1.9.0
var Contact, cozydb;

cozydb = require('cozy-db-pouchdb');

module.exports = Contact = cozydb.getModel('Contact', {
  fn: String,
  n: String,
  datapoints: [Object]
});

Contact.prototype.asNameAndEmails = function() {
  var emails, name, simple, _ref, _ref1;
  name = this.fn || ((_ref = this.n) != null ? _ref.split(';').slice(0, 2).join(' ') : void 0);
  emails = (_ref1 = this.datapoints) != null ? _ref1.filter(function(dp) {
    return dp.name === 'email';
  }) : void 0;
  return simple = {
    id: this.id,
    name: name || '?',
    emails: emails || []
  };
};
