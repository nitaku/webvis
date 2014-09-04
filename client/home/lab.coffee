body = d3.select('body')

lab = body.append('div')
    .attr
        id: 'lab'
        
lab.append('a').attr('href','/webvis/lab').append('div')
    .html('<div class="logo"></div>Lab')
    .attr
        id: 'lab_header'
        
d3.json ('/webvis/lab/api/gists' + if user_filter? then "/users/#{user_filter}" else ''), (gists) ->
    
    if user_filter?
        gist = gists[0]
        lab.append('div')
            .attr
                class: 'user_filter'
            .html "<img class='big_avatar' src='#{gist.owner.avatar_url}'/> <a href='/webvis/lab/users/#{gist.owner.login}'>#{gist.owner.login}</a>"
        
    enter_gists = lab.selectAll('.gist')
        .data(gists)
      .enter().append('a')
        .attr
            href: (g) -> "/webvis/lab/#{g.id}"
      .append('div')
        .attr
            class: 'gist'
        .style('opacity', (g) -> if g.truncated then 0.1 else undefined) # blur truncated gists
            
    enter_thumbnails = enter_gists.append('div')
        .attr
            class: 'thumbnail'
        
        .style 'background-image', (g) ->
            if g.files['thumbnail.png']?
                return "url(#{g.files['thumbnail.png'].raw_url})"
            else if g.files['thumbnail.png.base64']?
                return "url(data:image/png;base64,#{g.files['thumbnail.png.base64'].content})"
    
    enter_thumbnails.append('a').attr('href', (g) -> "/webvis/lab/users/#{g.owner.login}").append('img')
        .attr
            class: 'avatar'
            src: (g) -> g.owner.avatar_url
            
    enter_thumbnails.filter((gist) -> gist.comments > 0)
      .append('div')
        .attr
            class: 'comments'
        .html((gist) -> "<span class='fa-stack fa-lg'><i class='fa fa-comment fa-flip-horizontal fa-stack-1x' style='color: white;'></i><i class='fa fa-comment-o fa-flip-horizontal fa-stack-1x' style='font-weight: bold;color: #393d48;'></i></span><span class='count'>#{gist.comments}</span>")
        
    enter_gists.append('div')
        .attr
            class: 'description'
        .text((g) -> (if g.truncated then 'BROKEN - ' else '') + g.description)
        