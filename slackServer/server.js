var slackbot = require('node-slackbot');
var fs = require('fs');
var https = require('https');

var token = '';

var bot = new slackbot(token);

var url = 'https://slack.com/api/users.info?token=' + token + '&user=';

var users = {};

function getUsername(id, fn) {
  if ( users.hasOwnProperty(id) ) {
    fn(users[id]);
    return;
  }
  https.get(url + id, function(res) {
    var body = '';
    res.on('data', function(chunk) {
      body += chunk;
    });
    res.on('end', function() {
      var slackResponse = JSON.parse(body)
      fn(slackResponse.user.name);
    });
  }).on('error', function(e) {
    console.log("Got error: ", e);
  });
}

var slackLoaded = false;

bot.use(function(message, cb) {
  if ( message.hasOwnProperty('text') ) {
    if (!slackLoaded) {
      slackLoaded = true;
      return;
    }
    var date = new Date();
    var timestamp = date.getHours() + ':' + date.getMinutes();
    getUsername(message.user, function(name) {
      var entry = name + ' (' + timestamp + ') => ' + message.text;
      console.log(entry);
      fs.appendFile(__dirname + '/message.log', entry + '\n', function (err) {
      });
    });
  }
  cb();
});

bot.connect();
