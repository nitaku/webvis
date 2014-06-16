# FIXME this should be read from a central database
USERS = ['nitaku','kleem','fabiovalse','andreaderrico2']

converter = new Showdown.converter()

time_format = d3.time.format('%B %d, %Y')

body = d3.select('body')

d3.json "api/gists/#{this_gist_id}", (gist) ->
    body.append('h2')
        .html "<img class='avatar' src='#{gist.owner.avatar_url}'/>" + time_format(new Date(gist.created_at)) + '<br/>by ' + gist.owner.login
    
    body.append('h1')
        .text(gist.description)
        
    container = body.append('section')
    
    container.append('nav')
        .html "Open in <a href='http://bl.ocks.org/#{gist.id}'>bl.ocks.org</a> - <a href='http://gist.github.com/#{gist.id}'>Gist</a> - <a href='#{gist.id}/index.html'>full page</a>"
    
    if gist.files['index.html']?
        container.append('iframe')
            .attr
                src: "#{gist.id}/index.html"
                marginwidth: 0
                marginheight: 0
                scrolling: 'no'
                
    # convert bl.ocks.org links to webvis
    readme_markdown = gist.files['README.md'].content
    for user in USERS
        readme_markdown = readme_markdown.replace(new RegExp("http:\/\/bl\.ocks\.org\/"+user+"/([a-f0-9]+)", 'g'), '$1')
        
    container.append('article')
        .html converter.makeHtml(readme_markdown)
        
    # comments
    comments_box = container.append('aside')
        .attr
            class: 'comments_box'
    
    a = comments_box.append('a')
        .attr
            href: "https://gist.github.com/#{gist.id}#footer"
    
    a.append('div')
        .attr
            class: 'add_link'
        .html '<i class="fa fa-comments-o fa-2x"></i> Leave a comment'
        
    d3.json "https://api.github.com/gists/#{gist.id}/comments", (data) ->
        comments_box.selectAll('.comment')
            .data(data.filter((c) -> c.user.login isnt 'nnwakelam'), (c) -> c.id) # workaround for spam comments
          .enter().insert('div', '.comment:first-child')
            .attr('class', 'comment')
            .html((c) -> "<img src='#{c.user.avatar_url}'/>#{c.body}")
            