converter = new Showdown.converter({extensions: ['webvis']})

body = d3.select('body')

lab = body.append('div')
    .attr
        id: 'lab'
        
main = body.append('div')
    .attr
        id: 'main'
        
lab.append('a')
    .attr
        href: 'lab'
  .append('div')
    .html('<img src="home/icons/lab_icon.svg"/>Lab <i class="fa fa-angle-double-right fa-2x"></i>')
    .attr
        id: 'lab_header'
        
d3.text 'home/index.md', (md) ->
    main.html converter.makeHtml(md)
    
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
            
    enter_gists.append('div')
        .attr
            class: 'description'
        .text((g) -> (if g.truncated then 'BROKEN - ' else '') + g.description)
        