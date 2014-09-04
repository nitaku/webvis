KEY = 'client_id=9336f1a62ffecf2c8370&client_secret=fcb6b257fff5a09484b1aa76e59fb6eacf7e61ee'

request = require('request')
parse_link_header = require('parse-link-header')
MongoClient = require('mongodb').MongoClient
queue = require('queue-async')
_ = require('lodash')

console.log ''
console.log "### SYNCING LAB - #{new Date()}"
console.log ''

MongoClient.connect 'mongodb://127.0.0.1:27017/lab', (error, db) ->
    throw error if error
    
    users_q = queue(10)
    
    ['nitaku','kleem','fabiovalse','andreaderrico2','cartoda'].forEach (user) ->
        users_q.defer (users_q_callback) -> sync_user(db, user, users_q_callback)
        
    users_q.awaitAll (error, results) ->
        console.log 'All users done.'
        db.close()
        
# sync a user
sync_user = (db, user, users_q_callback) ->
    console.log "#{user}: Syncing all gists..."
    
    gists = []
    
    # recursive request to Gist APIs to fetch all of a user's gists
    recur_req = (url, callback) ->
        request {
            url: url+'?'+KEY,
            headers: {'User-Agent': 'WebVis Lab, via nodejs request library'}
          }, (error, response, body) ->
            throw error if error
            
            new_gists = JSON.parse(body)
            _.forEach new_gists, mongoify
            gists = gists.concat(new_gists)
            
            if response.headers.link? and parse_link_header(response.headers.link).next?
                recur_req parse_link_header(response.headers.link).next.url, callback
            else
                callback()
                
    recur_req "https://api.github.com/users/#{user}/gists", () ->
        gists_q = queue(20)
        
        gists.forEach (gist) ->
            # skip non-bl.ock gists
            if not gist.files['README\uff0emd']? or (not gist.files['thumbnail\uff0epng']? and not gist.files['thumbnail\uff0epng\uff0ebase64'])
                console.log "WARNING - #{user}: bl.ock-malformed gist #{gist.id} discarded"
                return
                
            gists_q.defer (gists_q_callback) -> sync_gist(db, user, gist, gists_q_callback)
            
        gists_q.awaitAll (error, results) ->
            throw error if error
            
            # delete old gists
            ids = _.map gists, (g) -> g.id
            
            console.log "#{user}: removing old gists"
            
            db.collection('gists').remove {'owner.login': user, id: {'$nin': ids}}, {w:1}, (error) ->
                throw error if error
                
                console.log "#{user}: all gists are now up to date"
                users_q_callback()
                
# sync a gist
sync_gist = (db, user, gist, gists_q_callback) ->
    db.collection('gists').findOne {id: gist.id}, (error, found_gist) ->
        if not found_gist?
            # fetch the actual gist content from the APIs
            request {
                url: "https://api.github.com/gists/#{gist.id}?#{KEY}",
                headers: {'User-Agent': 'WebVis Lab, via nodejs request library'}
              }, (error, response, body) ->
                throw error if error
                
                actual_gist = mongoify JSON.parse(body)
                
                # download truncated files
                # files_q = queue(5)
                
                _.forOwn actual_gist.files, (f, name) ->
                    if f.truncated
                        actual_gist.truncated = true
                        
                        # files_q.defer (files_q_callback) ->
                            # console.log "#{user}: downloading truncated file #{name.replace(/\uff0e/g,'.')}"
                            # request {
                                # url: "#{f.raw_url}?#{KEY}",
                                # headers: {'User-Agent': 'WebVis Lab, via nodejs request library'}
                              # }, (error, response, body) ->
                                # throw error if error
                                
                                # f.content = body
                                # console.log "#{user}: #{f.content.length} bytes downloaded"
                                # files_q_callback()
                
                # files_q.awaitAll (error, results) ->
                    # throw error if error
                
                db.collection('gists').save actual_gist, {w:1}, (error) ->
                    throw error if error
                    console.log "#{user}: new gist #{gist.id} saved"
                    gists_q_callback()
            return
        
        if new Date(gist.updated_at) > new Date(found_gist.updated_at)
            # fetch the actual gist content from the APIs
            request {
                url: "https://api.github.com/gists/#{gist.id}?#{KEY}",
                headers: {'User-Agent': 'WebVis Lab, via nodejs request library'}
              }, (error, response, body) ->
                throw error if error
                
                actual_gist = mongoify JSON.parse(body)
                actual_gist['_id'] = found_gist['_id']
                
                db.collection('gists').save actual_gist, {w:1}, (error) ->
                    throw error if error
                    console.log "#{user}: gist #{gist.id} updated"
                    gists_q_callback()
            return
        
        # gist is up to date: no action needed
        gists_q_callback()
        
# dots in file names are replaced to avoid problems with MongoDB
mongoify = (gist) ->
    fixed = {}
    for name, file of gist.files
        fixed[name.replace(/\./g,'\uff0e')] = file
        
    gist.files = fixed
    
    return gist
    