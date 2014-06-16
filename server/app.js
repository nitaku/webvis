(function() {
  var MongoClient, express, unmongoify, _;

  MongoClient = require('mongodb').MongoClient;

  express = require('express');

  _ = require('lodash');

  MongoClient.connect('mongodb://127.0.0.1:27017/lab', function(error, db) {
    var app, server;
    if (error) throw error;
    app = express();
    app.get('//api/gists', function(req, res) {
      var options;
      options = {
        fields: {
          id: 1,
          created_at: 1,
          updated_at: 1,
          description: 1,
          'files.thumbnail\uff0epng.raw_url': 1,
          'files.thumbnail\uff0epng\uff0ebase64': 1,
          owner: 1,
          truncated: 1
        },
        sort: [['created_at', -1]]
      };
      return db.collection('gists').find({}, options).toArray(function(error, gists) {
        if (error) throw error;
        _.forEach(gists, unmongoify);
        return res.json(gists);
      });
    });
    app.get('//api/gists/:id', function(req, res) {
      var options;
      options = {
        fields: {
          id: 1,
          created_at: 1,
          updated_at: 1,
          description: 1,
          'files.README\uff0emd': 1,
          'files.index\uff0ehtml': 1,
          owner: 1,
          truncated: 1
        },
        sort: [['created_at', -1]]
      };
      return db.collection('gists').findOne({
        id: req.params.id
      }, options, function(error, gist) {
        if (error) throw error;
        unmongoify(gist);
        return res.json(gist);
      });
    });
    app.get('/', function(req, res) {
      return res.send("<!DOCTYPE html>\n<html>\n    <head>\n        <meta charset=\"utf-8\">\n        \n        <link href=\"//netdna.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css\" rel=\"stylesheet\">\n        \n        <link rel=\"stylesheet\" href=\"home/lab.css\">\n        <link rel=\"stylesheet\" href=\"home/headers.css\">\n        <script src=\"home/lib/showdown.js\"></script>\n        <script src=\"http://d3js.org/d3.v3.min.js\"></script>\n    </head>\n    <body>\n        <script src=\"home/lab.js\"></script>\n    </body>\n</html>");
    });
    app.get('//:id', function(req, res) {
      return res.send("<!DOCTYPE html>\n<html>\n    <head>\n        <meta charset=\"utf-8\">\n        \n        <link href=\"//netdna.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css\" rel=\"stylesheet\">\n        \n        <link rel=\"stylesheet\" href=\"../home/gist.css\">\n        <script>\n            var this_gist_id = '" + req.params.id + "';\n        </script>\n        <script src=\"../home/lib/showdown.js\"></script>\n        <script src=\"http://d3js.org/d3.v3.min.js\"></script>\n    </head>\n    <body>\n        <script src=\"../home/gist.js\"></script>\n    </body>\n</html>");
    });
    app.get('//:id/:file', function(req, res) {
      return db.collection('gists').findOne({
        id: req.params.id
      }, {}, function(error, gist) {
        if (error) throw error;
        unmongoify(gist);
        res.setHeader('Content-Type', gist.files[req.params.file].type);
        return res.send(gist.files[req.params.file].content);
      });
    });
    return server = app.listen(3004, function() {
      return console.log('Listening on port %d', server.address().port);
    });
  });

  unmongoify = function(gist) {
    var file, fixed, name, _ref;
    fixed = {};
    _ref = gist.files;
    for (name in _ref) {
      file = _ref[name];
      fixed[name.replace(/\uff0e/g, '.')] = file;
    }
    gist.files = fixed;
    return gist;
  };

}).call(this);
