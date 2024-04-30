({
	GettingProjectinfohelper : function(component) {
       // var button = document.getElementById('invoiceButton');
        // Then, disable the button
       // button.disabled = true;
		var AccountId = component.get('v.AccountId');
		var ContactId = component.get('v.memberId');
        var action = component.get('c.Projectinfofetch');
        action.setParams({
            "AccountId" : AccountId,
			"ContactId" : ContactId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log(' response.getReturnValue()');
               console.log(response.getReturnValue());
           if (state == "SUCCESS") {
            var Projectrecord = response.getReturnValue();
            component.set('v.ProjectRec',Projectrecord);
                 
           } else { // if any callback error, display error msg
               var errors = response.getError();
              
               if (errors) {
                   if (errors[0] && errors[0].message) {
                      // component.displayMessage('Error', 'An error occurred during order Creation ' + errors[0].message, 'Error', 'dismissible');
                   }
               } else {
                 //  component.displayMessage('Error', 'An error occurred during order Creation : Unknown error', 'Error', 'dismissible');
               }
           }
            
        });
        $A.enqueueAction(action);
       
    },
    CreatingInvoiceRecordHelper : function(component) {
        var Projectrec = component.get('v.ProjectRec');
        var Amount = component.get('v.Amount');
        console.log(Amount);

        var Invoicedate = component.get('v.Invoicedate');
        console.log(Invoicedate); 
        var Description = component.get('v.Description');
        console.log(Description); 
        if(Amount!=null && Amount!='' && Invoicedate!=null && Invoicedate!='' && Description !=null && Description!=''){
        var action = component.get('c.InvoiceCeration');
        action.setParams({
            "Description" : Description,
			"Amount" : Amount,
            "AccountId" : Projectrec.Account__c,
            "ContactId" : Projectrec.Employee__c,
            "invoiceDate" : Invoicedate,
            
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log(' response.getReturnValue()');
               console.log(response.getReturnValue());
           if (state == "SUCCESS") {
            var invoiceRecord = response.getReturnValue();
            component.set('v.Invoice',invoiceRecord);
                 
           } else { // if any callback error, display error msg
               var errors = response.getError();
              
               if (errors) {
                   if (errors[0] && errors[0].message) {
                      // component.displayMessage('Error', 'An error occurred during order Creation ' + errors[0].message, 'Error', 'dismissible');
                   }
               } else {
                 //  component.displayMessage('Error', 'An error occurred during order Creation : Unknown error', 'Error', 'dismissible');
               }
           }
            
        });
        $A.enqueueAction(action);
        component.set('v.Navigateto', true);
    }else{
         alert ("Please fill required fileds");  
    }
    }
})