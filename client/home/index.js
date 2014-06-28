(function() {
  var body, converter, lab, main;

  converter = new Showdown.converter();

  body = d3.select('body');

  main = body.append('div').attr({
    id: 'main'
  });

  lab = body.append('div').attr({
    id: 'lab'
  });

  lab.append('a').attr({
    href: 'lab'
  }).append('div').html('<img src="home/icons/lab_icon.svg"/>Lab <i class="fa fa-angle-double-right fa-2x"></i>').attr({
    id: 'lab_header'
  });

  d3.json('home/entries.json', function(entries) {
    var enter_entries, header;
    enter_entries = main.selectAll('.entry').data(entries).enter().append('div').attr({
      "class": 'entry'
    });
    header = enter_entries.append('div').attr({
      "class": 'header'
    });
    header.append('h2').text(function(entry) {
      return entry.title;
    });
    header.append('h3').text(function(entry) {
      return entry.date;
    });
    enter_entries.append('div').style('background-image', function(entry) {
      return "url(" + entry.cover + ")";
    }).attr({
      "class": 'cover'
    });
    return enter_entries.append('div').html(function(entry) {
      return converter.makeHtml(entry.caption);
    }).attr({
      "class": 'caption'
    });
  });

  d3.json('/webvis/lab/api/gists', function(gists) {
    var enter_gists, enter_thumbnails;
    enter_gists = lab.selectAll('.gist').data(gists).enter().append('a').attr({
      href: function(g) {
        return "lab/" + g.id;
      }
    }).append('div').attr({
      "class": 'gist'
    }).style('opacity', function(g) {
      if (g.truncated) {
        return 0.1;
      } else {
        return;
      }
    });
    enter_thumbnails = enter_gists.append('div').attr({
      "class": 'thumbnail'
    }).style('background-image', function(g) {
      if (g.files['thumbnail.png'] != null) {
        return "url(" + g.files['thumbnail.png'].raw_url + ")";
      } else if (g.files['thumbnail.png.base64'] != null) {
        return "url(data:image/png;base64," + g.files['thumbnail.png.base64'].content + ")";
      }
    });
    enter_thumbnails.append('img').attr({
      "class": 'avatar',
      src: function(g) {
        return g.owner.avatar_url;
      }
    });
    return enter_gists.append('div').attr({
      "class": 'description'
    }).text(function(g) {
      return (g.truncated ? 'BROKEN - ' : '') + g.description;
    });
  });

}).call(this);
