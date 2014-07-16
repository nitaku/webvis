body = d3.select('body')

lab = body.append('div')
    .attr
        id: 'lab'
        
lab.append('div')
    .html('<img src="home/icons/lab_icon.svg"/>Lab')
    .attr
        id: 'lab_header'
        
d3.json '/webvis/lab/api/gists', (gists) ->
    enter_gists = lab.selectAll('.gist')
        .data(gists)
      .enter().append('a')
        .attr
            href: (g) -> "lab/#{g.id}"
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
    
    enter_thumbnails.append('img')
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
        