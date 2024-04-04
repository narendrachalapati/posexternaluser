({
    doint : function(component, event, helper) {
        /**LOADING VALUES */
        var recordId = component.get('v.recordId') ? component.get('v.recordId') : '';
        if (recordId) {
            var action = component.get('c.fetchTemplate');
            var params = {
                recordId : recordId
            }
            action.setParams(params);
            action.setCallback(this, function (data) {
                var errors = data.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    component.displayMessage('Error', error, 'Error');
                    component.set('v.isLoading', false);
                } else {
                    var returnVal = data.getReturnValue();
                    if(returnVal) {
                        component.set('v.templateName', returnVal.Name);
                        component.set('v.isAvailable', returnVal.IsActive__c);
                        component.set('v.templateBody', returnVal.Template__c);
                    }
                }
            });
            $A.enqueueAction(action);
            
        }
        

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
    handleCoptToClipboard : function(component, event, helper) {
        try {
                // Create an hidden input
                var hiddenInput = component.find("merge-field");
                
                // select the content
                hiddenInput.select();
                // Execute the copy command
                hiddenInput.execCommand("copy");
            
          } catch (err) {
            console.error('Failed to copy: ', err);
            console.trace(err);
          }
        alert("Copied to clipboard: " + item);
    },

    handleTemplateNameChange : function(component, event, helper) {

    },
    handleIsAvailable : function(component, event, helper) {

    },
    handleTemplateBodyChange : function(component, event, helper) {
        var newTextValue = event.getSource().get("v.value");
        console.log('templateBody ', newTextValue);
        component.set("v.templateBody", newTextValue);
    },
    
    handleLookupEvent : function(component, event, helper) {
        console.log('event called');
        console.log(JSON.stringify(event.getParam('selectedRecord'), null, 2));
        let selectedRecord = event.getParam('selectedRecord');
        if (selectedRecord) {
            let apiname = selectedRecord.apiname;
            let objectApiName = selectedRecord.ObjectApiName;
            let mergefield = '{!' + objectApiName + '.' + apiname + '}';
            component.set("v.mergeField", mergefield);
        } else {
            component.set("v.mergeField", '');
        }
    },
    handleReset : function(component, event, helper) {
        component.set('v.templateName', '');
        component.set('v.isAvailable', false);
        component.set('v.templateBody', '');
    },
    handleSave : function(component, event, helper) {
        var recordId = component.get('v.recordId') ? component.get('v.recordId') : '';
        var templateName = component.get('v.templateName') ? component.get('v.templateName') : '';
        var isAvailable = component.get('v.isAvailable') ? component.get('v.isAvailable') : '';
        var templateBody = component.get('v.templateBody') ? component.get('v.templateBody') : '';
        component.apiCall('upsertTemplate',
        {
            recordId : recordId,
            templateName : templateName,
            templateBody : templateBody,
            isAvailable : isAvailable
        },
        (returnVal) => {
            if(recordId) {
                component.displayMessage('Success', 'Successfully updated.', 'Success');
            } else {
                component.displayMessage('Success', 'Successfully created.', 'Success');
            }
            component.set('v.isLoading', false);
        },
        (error) => {
            component.displayMessage('Error', error, 'Error');
            component.set('v.isLoading', false);
        })
    }
})