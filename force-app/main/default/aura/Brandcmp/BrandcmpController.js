({
    doInit: function(component, event, helper) {
        var action = component.get('c.gettingdetailsbyrecordid');
        var patientid = component.get("v.memberId");
        console.log('patientid'+patientid);
        action.setParams({
            "paentid": patientid
           
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var googlefile = response.getReturnValue(); 
                console.log('googlefile '+ googlefile);
                console.table(googlefile);

                  component.set('v.googlefilerecid',googlefile.Id);
                  console.log('googlefile.Id' + googlefile.Id);
                  var googlefileid = googlefile.Id;
                  if(googlefileid != 'undefined' && googlefileid != null){
                 component.set('v.base64',googlefile.ThumbnailLink__c);  
                 component.set('v.previewlink',googlefile.Preview_Link__c);
                 component.set('v.Downloadlink',googlefile.DownloadLink__c); 
   
                 helper.imagepreview(component,googlefile.ContentType__c);
                 console.log('b64stringNDR23' + googlefile);
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
            var fileName = 'No File Selected..';
            if (event.getSource().get("v.files").length > 0) {
                fileName = event.getSource().get("v.files")[0]['name'];
            }
            component.set("v.fileName", fileName);
            if (component.find("fuploader").get("v.files").length > 0) {
                helper.uploadHelper(component, event);
            } else {
                alert('Please Select a Valid File');
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