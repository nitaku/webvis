# MongoDB setup
# use lab
# db.gists.ensureIndex({created_at: 1})
# db.gists.ensureIndex({id: 1})

MongoClient = require('mongodb').MongoClient
express = require('express')
_ = require('lodash')

MongoClient.connect 'mongodb://127.0.0.1:27017/lab', (error, db) ->
    throw error if error
    
    app = express()
    
    app.get '//api/gists', (req, res) -> 
        options = {
            fields: {
                id: 1,
                created_at: 1,
                updated_at: 1,
                description: 1,
                'files.thumbnail\uff0epng.raw_url': 1,
                'files.thumbnail\uff0epng\uff0ebase64': 1,
                owner: 1,
                truncated: 1,
                comments: 1
            },
            sort: [['created_at',-1]]
        }
        db.collection('gists').find({}, options).toArray (error, gists) ->
            throw error if error
            
            _.forEach gists, unmongoify
            
            res.json gists
            
    app.get '//api/gists/users/:user', (req, res) -> 
        options = {
            fields: {
                id: 1,
                created_at: 1,
                updated_at: 1,
                description: 1,
                'files.thumbnail\uff0epng.raw_url': 1,
                'files.thumbnail\uff0epng\uff0ebase64': 1,
                owner: 1,
                truncated: 1,
                comments: 1
            },
            sort: [['created_at',-1]]
        }
        db.collection('gists').find({'owner.login': req.params.user}, options).toArray (error, gists) ->
            throw error if error
            
            _.forEach gists, unmongoify
            
            res.json gists
            
    app.get '//api/gists/:id', (req, res) ->
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
            sort: [['created_at',-1]]
        }
        db.collection('gists').findOne {id: req.params.id}, options, (error, gist) ->
            throw error if error
            
            unmongoify gist
            
            res.json gist
            
    app.get '/', (req, res) ->
        res.send """
            <!DOCTYPE html>
            <html>
                <head>
                    <meta charset="utf-8">
                    <title>Lab - WAFI WebVis</title>
                    
                    <link href="//netdna.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
                    
                    <link rel="stylesheet" href="home/lab.css">
                    <link rel="stylesheet" href="home/headers.css">
                    <script src="home/lib/showdown.js"></script>
                    <script src="http://d3js.org/d3.v3.min.js"></script>
                </head>
                <body>
                    <script src="home/lab.js"></script>
                </body>
            </html>
        """
        
    app.get '//users/:user', (req, res) ->
        res.send """
            <!DOCTYPE html>
            <html>
                <head>
                    <meta charset="utf-8">
                    <title>#{req.params.user}@Lab - WAFI WebVis</title>
                    
                    <link href="//netdna.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
                    
                    <link rel="stylesheet" href="../../home/lab.css">
                    <link rel="stylesheet" href="../../home/headers.css">
                    <script src="../../home/lib/showdown.js"></script>
                    <script src="http://d3js.org/d3.v3.min.js"></script>
                    <script>
                        var user_filter = '#{req.params.user}';
                    </script>
                </head>
                <body>
                    <script src="../../home/lab.js"></script>
                </body>
            </html>
        """
        
    app.get '//:id', (req, res) ->
        db.collection('gists').findOne {id: req.params.id}, {description: 1}, (error, gist) ->
            throw error if error
            
            unmongoify gist
            
            res.send """
                <!DOCTYPE html>
                <html>
                    <head>
                        <meta charset="utf-8">
                        <title>#{gist.description} - Lab - WAFI WebVis</title>
                        
                        <link href="//netdna.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
                        
                        <link rel="stylesheet" href="../home/gist.css">
                        <script>
                            var this_gist_id = '#{req.params.id}';
                        </script>
                        <script src="../home/lib/showdown.js"></script>
                        <script src="http://d3js.org/d3.v3.min.js"></script>
                    </head>
                    <body>
                        <script src="../home/gist.js"></script>
                    </body>
                </html>
            """
        
    app.get '//:id/:file', (req, res) ->
        db.collection('gists').findOne {id: req.params.id}, {}, (error, gist) ->
            throw error if error
            
            unmongoify gist
            
            res.setHeader('Content-Type', gist.files[req.params.file].type)
            res.send gist.files[req.params.file].content
            
    server = app.listen 3004, () ->
        console.log('Listening on port %d', server.address().port)
        
# dots in file names are replaced back to their original value
unmongoify = (gist) ->
    fixed = {}
    for name, file of gist.files
        fixed[name.replace(/\uff0e/g,'.')] = file
        
    gist.files = fixed
    
    return gist
    