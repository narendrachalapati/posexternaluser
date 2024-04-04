({
    sendToJSApp: function (component, event, helper) {
        var message = {
            name: "General",
            value: component.get("v.messageToJSApp")
        };
        component.find("WebcallingApp").message(message);
    },

    handleMessage: function (component, event, helper) {
        var message = event.getParams();
        component.set('v.messageFromJSApp', message.payload);
    },

    handleError: function (component, event, helper) {
        var error = event.getParams();
        console.log(error);
    }
})