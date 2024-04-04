({
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

    displayMessage: function (title, message, type, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode": mode,
            "title": title,
            "type": type,
            "message": message
        });
        toastEvent.fire();
    },

    getAllFromPhoneNumbers : function (component, event, helper) {
        var getAllFromNumbers = component.get('c.getAllFromNumbers'); 
        getAllFromNumbers.setParams({
            "integrationSetting": 'Plivo',
            "objectSetting": 'PlivoSMS'
        });
        //getting the response from the apex class
        getAllFromNumbers.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.set('v.isLoading', false);
                component.set("v.availableFromNumber", response.getReturnValue());
                
                let selectedObj = response.getReturnValue().filter( i=> {
                    if(i.phoneNumber == component.get('v.selectedNumber')) {
                        return i;
                    }
                });

                console.log('selectedObj ', JSON.stringify(selectedObj), JSON.stringify(component.get('v.selectedNumber')) ); 
                if(selectedObj && selectedObj.length == 0) {
                    component.set('v.numberToBeUsed', (component.get('v.availableFromNumber') && component.get('v.availableFromNumber').length > 0) ? component.get('v.availableFromNumber')[0].phoneNumber : '');
                } else if(selectedObj && selectedObj.length > 0) {
                    component.set('v.numberToBeUsed', selectedObj[0].phoneNumber);
                }

                console.log(' numberToBeUsed', JSON.stringify(component.get('v.numberToBeUsed')));

            } else {
                // Failure
                component.set('v.isLoading', false);
                this.logConsoleDebug('Error in Retriving Phone Numbers', 'log');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.displayMessage('Failure!', 'Failed to Phone Numbers : ' + errors[0].message, 'error', 'dismissible');
                    }
                }
            }
        });
        $A.enqueueAction(getAllFromNumbers);
    },

    childComponentEvent : function(cmp, event,helper, selectedPhoneNumber) { 
        
        var cmpEvent = cmp.getEvent("fromNumberEvent"); 
        cmpEvent.setParams({"selectedFromNumber" : selectedPhoneNumber}); 

        cmpEvent.fire(); 

    },

    getDefaultPhoneNumber : function (component, event, helper) {
        var getDefaultPhoneNumber = component.get('c.getDefaultPhoneNumber');
        getDefaultPhoneNumber.setParams({
            "integrationSetting": 'Plivo'
        });
        //getting the response from the apex class
        getDefaultPhoneNumber.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.isLoading', false);
                var defaultFromNumber = response.getReturnValue();
                component.set('v.defaultNumber', defaultFromNumber); 
                this.childComponentEvent(component, event, helper, defaultFromNumber);

            } else {
                // Failure
                component.set('v.isLoading', false);
                this.logConsoleDebug('Error in getting default phoneneumber', 'log');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.displayMessage('Failure!', 'Failed to Retrive default phone number : ' + errors[0].message, 'error', 'dismissible');
                    }
                }
            }
        });
        $A.enqueueAction(getDefaultPhoneNumber);
    }

})