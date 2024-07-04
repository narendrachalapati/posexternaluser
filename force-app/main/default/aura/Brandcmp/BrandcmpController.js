({
    doInit: function(component, event, helper) {
        //helper.finalizeTodo(component, event);
        var accountId = component.get("v.accountId");
        var action = component.get('c.fetchFileRecordDetailsByWhattId');
        console.log('accountId ' + accountId);
        action.setParams({
            "recordId": accountId
            
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var googleFileRecord = response.getReturnValue();
                if( (googleFileRecord) && !(!googleFileRecord.Id) ){
                    var googleFileRecordId = googleFileRecord.Id;
                    component.set('v.googlefilerecid', googleFileRecordId);
                	console.log('googlefile.Id' + googleFileRecordId);
                    component.set('v.base64',googleFileRecord.ThumbnailLink__c);  
                    component.set('v.previewlink',googleFileRecord.Preview_Link__c);
                    component.set('v.Downloadlink',googleFileRecord.DownloadLink__c); 
                    
                    helper.imagepreview(component, googleFileRecord.ContentType__c);
                }
            } else { // if any callback error, display error msg
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        // component.displayMessage('Error', 'An error occurred during Searching ' + errors[0].message, 'Error','dismissible');
                    }
                } else {
                    // component.displayMessage('Error', 'An error occurred during Searching : Unknown error', 'Error','dismissible');
                }
                
            }
        });
        $A.enqueueAction(action);  
    },
    handleSave: function(component, event, helper) {
        if (component.find("fuploader").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
        } else {
            alert('Please Select a Valid File');
        }
    },
    
    handleFilesChange: function(component, event, helper) {
        component.set('v.isloading', 'true');
        var fileName = 'No File Selected..';
        console.log(event.getSource());
        console.table(event.getSource());
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
        if (component.find("fuploader").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
            
            
        } else {
            alert('Please Select a Valid File');
            component.set('v.isloading', 'false');
        }
    },
    handleFileEdit: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
        if (component.find("fEdit").get("v.files").length > 0) {
            helper.EditHelper(component, event);
        } else {
            alert('Please Select a Valid File');
        }
    },
    
    handleCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    
})