({
    onInit: function (component, event, helper) {
var action = component.get('c.gettingdetailsbyrecordid');
        var patientid = component.get("v.recordId");
        console.log('patientid'+patientid);
        action.setParams({
            "paentid": patientid
           
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var googlefile = response.getReturnValue();
                
                 component.set('v.imageURL',googlefile.Preview_Link__c); 
                 component.set('v.Brand', googlefile.BrandName__c); 
                console.log('previewlink'+component.get('v.imageURL'));
                console.log('Brand'+component.get('v.Brand'));
                 component.set('v.previewlink',googlefile.Preview_Link__c);
                 component.set('v.Downloadlink',googlefile.DownloadLink__c); 
                // helper.imagepreview(component,googlefile.ContentType__c);
                 console.log('b64stringNDR' + googlefile);
                 console.table(googlefile);
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
    
})