var system = require('system'),
    fs = require('fs'),
    webpage = require('webpage');

// streams
var stdout = system.stdout,
    stdin = system.stdin;

// global opts
var options = JSON.parse(system.args[1]),
    pageOptions = JSON.parse(system.args[2]),
    globals = {
        "page": null,
        "timer": null,
        "expired": false,
        "rendered": false,
        "html": fs.read(options.index_file)
    };

printJson = function(messageType, message) {
    payload = {};
    payload[messageType] = message;
    stdout.writeLine(JSON.stringify(payload));
    stdout.flush();
}

logMessage = function(message) {
    printJson('console', message);
}

logTrace = function(trace) {
    if (trace && trace.length) {
        var traceStack = [];
        trace.forEach(function(t) {
            traceStack.push(' -> ' + t.file + ': ' + t.line + (t.function ? ' (in function "' + t.function + '")' : ''));
        });

        printJson('trace', traceStack.join('\n'));
    }
}

logError = function(message, trace) {
    printJson('error', message);

    logTrace(trace);
}

printPage = function(url) {
    globals.page = webpage.create();

    globals.page.setContent(globals.html, url);

    // Log javascript console messages
    globals.page.onConsoleMessage = function(msg) {
        if (msg.trim() == "-- PHRENDER COMPLETE --"){
            globals.rendered = true;
        } else {
            logMessage(msg);
        }
    }

    // capture errors
    globals.page.onError = logError;

    globals.page.injectJs(options.script);

    // Catch something
    globals.timer = setTimeout(writeHtml, options.timeout);

    // Wait for the flag to switch
    waitForRender();
};

waitForRender = function() {
    if (!globals.expired) {
        if (!globals.rendered) {
            setTimeout(waitForRender, 100);
        } else {
            clearTimeout(globals.timer);
            writeHtml();
        }
    }
};

writeHtml = function() {
    globals.expired = true;
    var html = globals.page.evaluate(function() {
        return document.documentElement.outerHTML;
    });
    printJson("page", html);
    phantom.exit();
};

run = function() {
    printPage(pageOptions.url);
};

run();
