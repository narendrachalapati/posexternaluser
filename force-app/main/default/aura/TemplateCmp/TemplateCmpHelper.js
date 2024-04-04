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

    getAllSMSTemplates : function (component, event, helper) {
        
        
        if(component.get('v.recordId')) {
            var getAllSMSTemplates = component.get('c.getAllSMSTemplates');
            getAllSMSTemplates.setParams({
                "recordId" : component.get('v.recordId')
            });
            //getting the response from the apex class
            getAllSMSTemplates.setCallback(this, response => this.handleResponse(component, response));
            $A.enqueueAction(getAllSMSTemplates);
        } else if(component.get('v.sObjectApiName')) {
            console.log('sObjectApiName invoked');
            var getAllSMSTemplatesFromDeveloperName = component.get('c.getAllSMSTemplatesFromDeveloperName');
            getAllSMSTemplatesFromDeveloperName.setParams({
                "sObjectApiName" : component.get('v.sObjectApiName')
            });
            //getting the response from the apex class
            getAllSMSTemplatesFromDeveloperName.setCallback(this, response => this.handleResponse(component, response));
            $A.enqueueAction(getAllSMSTemplatesFromDeveloperName);
        }
            
    },

    handleResponse : function (component, response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            
            component.set('v.isLoading', false);
            component.set("v.smsTemplates", response.getReturnValue());
            

        } else {
            // Failure
            component.set('v.isLoading', false);
            this.logConsoleDebug('Error in Retriving Templates', 'log');
            var errors = response.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    this.displayMessage('Failure!', 'Failed to Retrive Templates : ' + errors[0].message, 'error', 'dismissible');
                }
            }
        }
    },

    getParsedBody : function (component, event, helper, templateBody) {
        var getParsedResponse = component.get('c.getParsedResponse');
        getParsedResponse.setParams({
            "recordId" : component.get('v.recordId') ? component.get('v.recordId') : '' ,
            "smsbody" : templateBody
        });
        //getting the response from the apex class
        getParsedResponse.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.set('v.isLoading', false);
                component.set("v.mergedText", response.getReturnValue());
                this.logConsoleDebug('apex response '+response.getReturnValue(), 'log');
                this.childComponentEvent(component, event, helper, response.getReturnValue()); 
                
            } else { 
                // Failure
                component.set('v.isLoading', false);
                this.logConsoleDebug('Error while parsing templates', 'log');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.displayMessage('Failure!', 'Failed to parse templates : ' + errors[0].message, 'error', 'dismissible');
                    }
                }
            }
        });
        if(component.get('v.recordId') || component.get('v.sObjectApiName'))
            $A.enqueueAction(getParsedResponse);
    },

    childComponentEvent : function(component, event,helper, message) { 
        // debugger;
        try {
            this.logConsoleDebug('Message to be fired- '+message, 'log');
            var cmpEvent = component.getEvent("selectTemplateEvent"); 
            cmpEvent.setParams({"selectedTemplateText" : message});  
            cmpEvent.fire(); 
            this.logConsoleDebug('Event fired '+message, 'log');
        }catch(e) {
            this.logConsoleDebug('Event fired '+e, 'log');
        }
        
    }

})