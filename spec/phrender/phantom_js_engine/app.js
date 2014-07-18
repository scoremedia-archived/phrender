(function() {
"use strict";

var head = document.getElementsByTagName('head')[0],
    title = document.createElement('title'),
    paragraph = document.createElement('p');

title.appendChild(document.createTextNode("Phrender The Prerenderer"));
head.appendChild(title);

paragraph.appendChild(document.createTextNode("Hello!"));
document.body.appendChild(paragraph);

setTimeout(function(){window.console.log('-- PHRENDER COMPLETE --');},1000);
})();
