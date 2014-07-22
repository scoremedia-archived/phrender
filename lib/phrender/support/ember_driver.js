window.__PHRENDER = true;
window.__firstRender = true;
window.__afterRender = function() {
    console.log('-- PHRENDER COMPLETE --');
};
Ember.Route = Ember.Route.extend({
    render: function(){
        if (window.__firstRender) {
            window.__firstRender = false;
        } else {
            Ember.run.scheduleOnce('afterRender', null, window.__afterRender);
        }
        this._super.apply(this, arguments);
    }
});

