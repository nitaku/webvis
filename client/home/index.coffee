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
    enter_entries = main.selectAll('.entry')
        .data(entries)
      .enter().append('div')
        .attr
            class: 'entry'
        
    header = enter_entries.append('div')
        .attr
            class: 'header'
    
    header.append('h2')
        .text (entry) -> entry.title
        
    header.append('h3')
        .text (entry) -> entry.date
        
    enter_entries.append('div')
        .style('background-image', (entry) -> "url(#{entry.cover})")
        .attr
            class: 'cover'
            
    enter_entries.append('div')
        .html((entry) -> converter.makeHtml(entry.caption))
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
            
    enter_thumbnails.append('img')
        .attr
            class: 'avatar'
            src: (g) -> g.owner.avatar_url
            
    enter_gists.append('div')
        .attr
            class: 'description'
        .text((g) -> (if g.truncated then 'BROKEN - ' else '') + g.description)
        