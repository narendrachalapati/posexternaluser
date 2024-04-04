({
    doint : function(component, event, helper) {
       
        component.apiCall = function (controllerMethodName, params, success, failure) {
			component.set('v.isLoading', true);
			console.log('loading true', controllerMethodName);
            
            var action = component.get('c.' + controllerMethodName);
            if(params)
                action.setParams(params);
            console.log('params ', params);
            action.setCallback(this, function (data) {
                var errors = data.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    if (failure) {
                        failure(errors[0].message);
                    } else {
                        alert('Failed to perform action!');
                    }
                } else {
                    if (success) {
						success(data.getReturnValue());
					}
                }
            });
            $A.enqueueAction(action);
        };

        component.displayMessage = function (title, message, type) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "mode": 'pester',
                "title": title,
                "type": type,
                "message": message
            });
            toastEvent.fire();
        };

    },

    ontemplateBodyChange : function(component, event) {
        
        var selectedRecord = component.get('v.selectedRecord');
        var templateBody = component.get('v.templateBody');
        // if (selectedRecord) {
        //     component.apiCall('fetchPreview',
        //     {
        //         recordId : selectedRecord,
        //         templateBody : templateBody
        //     },
        //     (returnVal) => {
        //         if (returnVal) {
        //             component.set('v.parsedBody', returnVal);
        //         }
        //         component.set('v.isLoading', false);
        //     },
        //     (error) => {
        //         component.displayMessage('Error', error, 'Error');
        //         component.set('v.isLoading', false);
        //     })
        // }
    },

    handleComponentEvent : function(component, event) {
        console.log('received', event.getParam("recordId"));
        var selectedRecord = event.getParam("recordId");
        component.set('v.selectedRecord', selectedRecord);
        var templateBody = component.get('v.templateBody');
        component.apiCall('fetchPreview',
        {
            recordId : selectedRecord,
            templateBody : templateBody
        },
        (returnVal) => {
            if (returnVal) {
                component.set('v.parsedBody', returnVal);
            }
            component.set('v.isLoading', false);
        },
        (error) => {
            component.displayMessage('Error', error, 'Error');
            component.set('v.isLoading', false);
        })

    },

    handleTogglePreview : function(component, event) {
        if (component.get("v.expand") === true) {
            component.set("v.expand", false);
        }
        else {
            component.set("v.expand", true);
        }
    }


})