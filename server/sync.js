(function() {
  var KEY, MongoClient, mongoify, parse_link_header, queue, request, sync_gist, sync_user, _;

  KEY = 'client_id=9336f1a62ffecf2c8370&client_secret=fcb6b257fff5a09484b1aa76e59fb6eacf7e61ee';

  request = require('request');

  parse_link_header = require('parse-link-header');

  MongoClient = require('mongodb').MongoClient;

  queue = require('queue-async');

  _ = require('lodash');

  console.log('');

  console.log("### SYNCING LAB - " + (new Date()));

  console.log('');

  MongoClient.connect('mongodb://127.0.0.1:27017/lab', function(error, db) {
    var users_q;
    if (error) throw error;
    users_q = queue(10);
    ['nitaku', 'kleem', 'fabiovalse', 'andreaderrico2', 'cartoda', 'mtesconi'].forEach(function(user) {
      return users_q.defer(function(users_q_callback) {
        return sync_user(db, user, users_q_callback);
      });
    });
    return users_q.awaitAll(function(error, results) {
      console.log('All users done.');
      return db.close();
    });
  });

  sync_user = function(db, user, users_q_callback) {
    var gists, recur_req;
    console.log("" + user + ": Syncing all gists...");
    gists = [];
    recur_req = function(url, callback) {
      return request({
        url: url + '?' + KEY,
        headers: {
          'User-Agent': 'WebVis Lab, via nodejs request library'
        }
      }, function(error, response, body) {
        var new_gists;
        if (error) throw error;
        new_gists = JSON.parse(body);
        _.forEach(new_gists, mongoify);
        gists = gists.concat(new_gists);
        if ((response.headers.link != null) && (parse_link_header(response.headers.link).next != null)) {
          return recur_req(parse_link_header(response.headers.link).next.url, callback);
        } else {
          return callback();
        }
      });
    };
    return recur_req("https://api.github.com/users/" + user + "/gists", function() {
      var gists_q;
      gists_q = queue(20);
      gists.forEach(function(gist) {
        if (!(gist.files['README\uff0emd'] != null) || (!(gist.files['thumbnail\uff0epng'] != null) && !gist.files['thumbnail\uff0epng\uff0ebase64'])) {
          console.log("WARNING - " + user + ": bl.ock-malformed gist " + gist.id + " discarded");
          return;
        }
        return gists_q.defer(function(gists_q_callback) {
          return sync_gist(db, user, gist, gists_q_callback);
        });
      });
      return gists_q.awaitAll(function(error, results) {
        var ids;
        if (error) throw error;
        ids = _.map(gists, function(g) {
          return g.id;
        });
        console.log("" + user + ": removing old gists");
        return db.collection('gists').remove({
          'owner.login': user,
          id: {
            '$nin': ids
          }
        }, {
          w: 1
        }, function(error) {
          if (error) throw error;
          console.log("" + user + ": all gists are now up to date");
          return users_q_callback();
        });
      });
    });
  };

  sync_gist = function(db, user, gist, gists_q_callback) {
    return db.collection('gists').findOne({
      id: gist.id
    }, function(error, found_gist) {
      if (!(found_gist != null)) {
        request({
          url: "https://api.github.com/gists/" + gist.id + "?" + KEY,
          headers: {
            'User-Agent': 'WebVis Lab, via nodejs request library'
          }
        }, function(error, response, body) {
          var actual_gist;
          if (error) throw error;
          actual_gist = mongoify(JSON.parse(body));
          _.forOwn(actual_gist.files, function(f, name) {
            if (f.truncated) return actual_gist.truncated = true;
          });
          return db.collection('gists').save(actual_gist, {
            w: 1
          }, function(error) {
            if (error) throw error;
            console.log("" + user + ": new gist " + gist.id + " saved");
            return gists_q_callback();
          });
        });
        return;
      }
      if (new Date(gist.updated_at) > new Date(found_gist.updated_at)) {
        request({
          url: "https://api.github.com/gists/" + gist.id + "?" + KEY,
          headers: {
            'User-Agent': 'WebVis Lab, via nodejs request library'
          }
        }, function(error, response, body) {
          var actual_gist;
          if (error) throw error;
          actual_gist = mongoify(JSON.parse(body));
          actual_gist['_id'] = found_gist['_id'];
          return db.collection('gists').save(actual_gist, {
            w: 1
          }, function(error) {
            if (error) throw error;
            console.log("" + user + ": gist " + gist.id + " updated");
            return gists_q_callback();
          });
        });
        return;
      }
      return gists_q_callback();
    });
  };

  mongoify = function(gist) {
    var file, fixed, name, _ref;
    fixed = {};
    _ref = gist.files;
    for (name in _ref) {
      file = _ref[name];
      fixed[name.replace(/\./g, '\uff0e')] = file;
    }
    gist.files = fixed;
    return gist;
  };

}).call(this);
