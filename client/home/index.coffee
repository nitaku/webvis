converter = new Showdown.converter()

body = d3.select('body')

# intro = body.append('div')
    # .attr
        # id: 'intro'
        
main = body.append('div')
    .attr
        id: 'main'
        
lab = body.append('div')
    .attr
        id: 'lab'
        
lab.append('a')
    .attr
        href: 'lab'
  .append('div')
    .html('<img src="home/icons/lab_icon.svg"/>Lab <i class="fa fa-angle-double-right fa-2x"></i>')
    .attr
        id: 'lab_header'
        
# d3.text 'home/intro.md', (md) ->
    # intro.html converter.makeHtml(md)
    
d3.json 'home/entries.json', (entries) ->
    entries.forEach (entry) ->
        entry_r = main.append('div')
            .attr
                class: 'entry'
                
        if entry.href?
            container = entry_r.append('a')
                .attr
                    href: entry.href
        else
            container = entry_r
            
        header = container.append('div')
            .attr
                class: 'header'
            
        header.append('h2')
            .text(entry.title)
            
        header.append('h3')
            .text entry.date
            
        container.append('div')
            .style('background-image', "url(#{entry.cover})")
            .attr
                class: 'cover'
                
        entry_r.append('div')
            .html(converter.makeHtml(entry.caption))
            .attr
                class: 'caption'
    
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
        