(function(){
    var webvis = function(converter) {
        return [
            // Entries
            // |[Title|date|cover.png|caption]| -> <div class='entry'><h2>Title</h2><h3>date</h3><div class="cover" style="background-image: url(cover.png)"></div><div class='caption'>caption</div></div>
            { 
                type: 'lang',
                filter: function(text) {
                    return text.replace(/\|\[(.*)\|(.*)\|(.*)\|(.*)\]\|/g, '<div class="entry"><h2>$1</h2><h3>$2</h3><div class="cover" style="background-image: url($3)"></div><div class="caption">$4</div></div>');
                }
            }
        ];
    };
    
    // Client-side export
    if (typeof window !== 'undefined' && window.Showdown && window.Showdown.extensions) { window.Showdown.extensions.webvis = webvis; }
    // Server-side export
    if (typeof module !== 'undefined') module.exports = webvis;
}());