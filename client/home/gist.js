(function() {
  var USERS, body, converter, time_format;

  USERS = ['nitaku', 'kleem', 'fabiovalse', 'andreaderrico2'];

  converter = new Showdown.converter();

  time_format = d3.time.format('%B %d, %Y');

  body = d3.select('body');

  d3.json("api/gists/" + this_gist_id, function(gist) {
    var container, readme_markdown, user, _i, _len;
    body.append('h2').html(("<img class='avatar' src='" + gist.owner.avatar_url + "'/>") + time_format(new Date(gist.created_at)) + '<br/>by ' + gist.owner.login);
    body.append('h1').text(gist.description);
    container = body.append('section');
    if (gist.files['index.html'] != null) {
      container.append('iframe').attr({
        src: "" + gist.id + "/index.html",
        marginwidth: 0,
        marginheight: 0,
        scrolling: 'no'
      });
    }
    container.append('nav').html("Open in <a href='http://bl.ocks.org/" + gist.id + "'>bl.ocks.org</a> - <a href='http://gist.github.com/" + gist.id + "'>Gist</a> - <a href='" + gist.id + "/index.html'>full page</a>");
    readme_markdown = gist.files['README.md'].content;
    for (_i = 0, _len = USERS.length; _i < _len; _i++) {
      user = USERS[_i];
      readme_markdown = readme_markdown.replace(new RegExp("http:\/\/bl\.ocks\.org\/" + user + "/([a-f0-9]+)", 'g'), '$1');
    }
    console.log(readme_markdown);
    return container.append('article').html(converter.makeHtml(readme_markdown));
  });

}).call(this);
