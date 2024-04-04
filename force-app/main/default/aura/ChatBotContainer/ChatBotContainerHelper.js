({ 
    //Print Console log or Table
    logConsoleDebug: function (debugString, type) {
        // component.logConsoleDebug(s, 'log');
        var enableConsoleDebug = true;
        if (enableConsoleDebug) {
            if (type == 'table') {
                console.table(debugString);
            } else {
                console.log(debugString);
            }
        }
    },
    
    notifyUser : function(component) {
        if (!("Notification" in window)) {
            alert("This browser does not support desktop notification");
        } else if (Notification.permission === "granted") {
            console.log('notification sp ', JSON.stringify(component.get('v.browserNotification'), null, 2));
            component.get('v.browserNotification').forEach( i=>{
                var data = []
                data['title'] = i.name;
                data['body'] = "You have a new SMS";
                var notification = new Notification(data['title'], 
                {
                    'body': i.message,
                    'icon': 'https://adisols--pma.sandbox.my.salesforce-sites.com/resource/1677834187000/sms_icon',
                    'tag' : i.tagId
                });
                notification.onclick = function(event) {
                    window.open('https://modernhealthcare-dev-ed.develop.lightning.force.com/'+i.contactId, '_blank');
                } 
                let notifiedMap = component.get('v.notifiedActivity');
                notifiedMap[i.tagId] = true;
                component.set('v.notifiedActivity', notifiedMap);
            });

            // var data = []
            // data['title'] = "SMS Notification";
            // data['body'] = "You have a new SMS";
            // var notification = new Notification(data['title'], 
            // {
            //     'body': data['body'],
            //     'icon': 'https://adisols--pma.sandbox.my.salesforce-sites.com/resource/1677834187000/sms_icon',
            // });
            /* 
            notification.onclick = function(event) {
            window.open('https://www.example.com/', '_blank');
            } */
        } else if (Notification.permission !== "denied") {
        Notification.requestPermission().then(function (permission) {
            if (permission === "granted") {
                var data = []
                data['title'] = "SMS Notification";
                data['body'] = "You have a new SMS";
                var notification = new Notification(data['title'], 
                {
                    'body': data['body'],
                    'icon': 'https://adisols--pma.sandbox.my.salesforce-sites.com/resource/1677834187000/sms_icon',
                });
            }
        });
        }
    },

    beep : function(component) {
        this.logConsoleDebug('static res :' + component.get('v.alert'), 'log');
        var beepsound = new Audio(component.get('v.alert'));
        beepsound.play();
    },

    fireApplicationEventCallWithParams: function (eventControllerName, params) {
        try {
            var appEvent = $A.get('e.c:' + eventControllerName);
            appEvent.setParams(params);
            this.logConsoleDebug('*** ' + 'Sending messagedata' + ' *** ' + params, 'log');
            this.logConsoleDebug('*** ' + 'Sending application event' + ' *** ' + eventControllerName, 'log');
            appEvent.fire();
            this.logConsoleDebug('*** ' + 'Sent application event successfully' + ' *** ' + eventControllerName, 'log');
        } catch (e) {
            this.logConsoleDebug('Excepetion Got ' + e, 'log');
        }
    },

    //Generate UUID
    uuid4: function () {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            var r = Math.random() * 16 | 0,
                v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    },

    //Check Undefined and return Blanks or null
    getBlankorNullForInvalidData: function (valueToCheck , returnBlank) {
        var cleanedValue = valueToCheck;
        if ( (valueToCheck == "undefined") || (valueToCheck == null) ){
            if(returnBlank){
                cleanedValue = '';
            }else{
                cleanedValue = null;
            }
        }        
        return cleanedValue;
    },
})