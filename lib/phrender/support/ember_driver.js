window.__PHRENDER = true;
window.__afterRender = function() {
    console.log('-- PHRENDER COMPLETE --');
};
Ember.Route = Ember.Route.extend({
    render: function(){
        Ember.run.scheduleOnce('afterRender', null, window.__afterRender);
        this._super.apply(this, arguments);
    }
});
