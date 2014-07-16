(function() {
  var body, lab;

  body = d3.select('body');

  lab = body.append('div').attr({
    id: 'lab'
  });

  lab.append('div').html('<img src="home/icons/lab_icon.svg"/>Lab').attr({
    id: 'lab_header'
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
    enter_thumbnails.filter(function(gist) {
      return gist.comments > 0;
    }).append('div').attr({
      "class": 'comments'
    }).html(function(gist) {
      return "<span class='fa-stack fa-lg'><i class='fa fa-comment fa-flip-horizontal fa-stack-1x' style='color: white;'></i><i class='fa fa-comment-o fa-flip-horizontal fa-stack-1x' style='font-weight: bold;color: #393d48;'></i></span><span class='count'>" + gist.comments + "</span>";
    });
    return enter_gists.append('div').attr({
      "class": 'description'
    }).text(function(g) {
      return (g.truncated ? 'BROKEN - ' : '') + g.description;
    });
  });

}).call(this);
