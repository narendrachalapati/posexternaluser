({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);
    },

    stripeCardLoaded: function(component, event, helper) {
        var calendarIframe = document.getElementById('calendarIframe');
        calendarIframe.style.height = '100vh';
        component.set('v.isLoading', false);
    },
})