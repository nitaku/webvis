(function() {
  var body, converter, lab, main;

  converter = new Showdown.converter({
    extensions: ['webvis']
  });

  body = d3.select('body');

  lab = body.append('div').attr({
    id: 'lab'
  });

  main = body.append('div').attr({
    id: 'main'
  });

  lab.append('a').attr({
    href: 'lab'
  }).append('div').text('Lab').attr({
    id: 'lab_header'
  });

  d3.text('home/index.md', function(md) {
    return main.html(converter.makeHtml(md));
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
      return g.description;
    });
  });

}).call(this);
