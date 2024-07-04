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
            var Projectrecords = response.getReturnValue();
            component.set('v.ProjectRecList',Projectrecords);
            component.set('v.ProjectRec',Projectrecords[0]);
            component.set('v.membername',Projectrecords[0].Employee__r.Name);
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
    //Creating the invoice for Employee
    createInvoiceRecord : function(component) {
        console.log('first promise called');
        return new Promise($A.getCallback(function(resolve, reject) {
        var Projectrec = component.get('v.ProjectRec');
        var Amountvar = component.get('v.Amount');
        console.log(Amountvar);

        var Invoicedatevar = component.get('v.Invoicedate');
        console.log(Invoicedatevar); 
        var Descriptionvar = component.get('v.Description');
        console.log(Descriptionvar); 
        if(Amountvar!=null && Amountvar!='' && Invoicedatevar!=null && Invoicedatevar!='' && Descriptionvar !=null && Descriptionvar!=''){
        var action = component.get('c.InvoiceCeration');
        const invoicewrap = {
            selectedProject:Projectrec,
            Description: component.get('v.Description'),
            Amount:  component.get('v.Amount'),
            AccountId: Projectrec.Account__c,
            ContactId: Projectrec.Vendor__c,
            invoiceDate: component.get('v.Invoicedate'),
            ProductId:Projectrec.Product__c,
            ProjectId:component.get('v.selectedProjectId'),
            Term:component.get('v.Selectedterm')
        };
   
        action.setParams({
            "invoicewrap" : invoicewrap,
			});
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log(' response.getReturnValue()');
               console.log(response.getReturnValue());
           if (state == "SUCCESS") {

            var invoiceRecord = response.getReturnValue();
            component.set('v.Invoice',invoiceRecord);
            resolve(invoiceRecord);  
           } else { // if any callback error, display error msg
               var errors = response.getError();
               reject("Failed to create invoice record.");
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
}));
    },
    //Doing callout For created invoice
    makeSynchronousCallout : function(component) {
        return new Promise($A.getCallback(function(resolve, reject) {
         var AccountId = component.get('v.AccountId');
         var Invoice = component.get('v.Invoice');
         var InvoiceId = Invoice.Id;
         var action = component.get('c.InvoiceSynchronouscallout');
        
         
         action.setParams({
             "AccountId" : AccountId,
             "invoiceId" : InvoiceId
         });
         action.setCallback(this, function (response) {
             var state = response.getState();
             console.log(' response.getReturnValue()');
                console.log(response.getReturnValue());
            if (state == "SUCCESS") {
             var sobjectrec = response.getReturnValue();
             resolve(sobjectrec);  
            } else { // if any callback error, display error msg
                var errors = response.getError();
               
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        reject("Failed to create invoice record.");
                       // component.displayMessage('Error', 'An error occurred during order Creation ' + errors[0].message, 'Error', 'dismissible');
                    }
                } else {
                  //  component.displayMessage('Error', 'An error occurred during order Creation : Unknown error', 'Error', 'dismissible');
                }
            }
             
         });
         $A.enqueueAction(action);
        }));
     },
      //Doing callout For  Email Send for created invoice
    makeSynchronousEmailCallout : function(component) {
        return new Promise($A.getCallback(function(resolve, reject) {
         var AccountId = component.get('v.AccountId');
         var Invoice = component.get('v.Invoice');
         var InvoiceId = Invoice.Id;
         var action = component.get('c.InvoiceEmailSynchronouscallout');
        
         
         action.setParams({
             "AccountId" : AccountId,
             "invoiceId" : InvoiceId
         });
         action.setCallback(this, function (response) {
             var state = response.getState();
             console.log(' response.getReturnValue()');
                console.log(response.getReturnValue());
            if (state == "SUCCESS") {
                this.finalizeTodo(component);
             var Sysobjectrec = response.getReturnValue();
             resolve(Sysobjectrec);  
            } else { // if any callback error, display error msg
                var errors = response.getError();
               
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        reject("Failed to create invoice record.");
                       // component.displayMessage('Error', 'An error occurred during order Creation ' + errors[0].message, 'Error', 'dismissible');
                    }
                } else {
                  //  component.displayMessage('Error', 'An error occurred during order Creation : Unknown error', 'Error', 'dismissible');
                }
            }
             
         });
         $A.enqueueAction(action);
        }));
     },
    //getting the selected project info For created invoice
    GettingselectedProject : function(component,selectedprojectId) {
        var action = component.get('c.SelectedProjectinfofetch');
        
         
         action.setParams({
             "selectedProjectId" : selectedprojectId,
           });
         action.setCallback(this, function (response) {
             var state = response.getState();
             console.log(' response.getReturnValue()');
                console.log(response.getReturnValue());
            if (state == "SUCCESS") {
             var Project = response.getReturnValue();
			 component.set('v.ProjectRec',Project);
            // resolve(sobjectrec);  
            } else { // if any callback error, display error msg
                var errors = response.getError();
               
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        reject("Failed to create invoice record.");
                       // component.displayMessage('Error', 'An error occurred during order Creation ' + errors[0].message, 'Error', 'dismissible');
                    }
                } else {
                  //  component.displayMessage('Error', 'An error occurred during order Creation : Unknown error', 'Error', 'dismissible');
                }
            }
             
         });
         $A.enqueueAction(action);
        
	},

    dueDatePreparation: function(invoicedate,termdays) {
        var  invoicedateTemp = new Date(invoicedate);
        invoicedateTemp.setDate(invoicedateTemp.getDate() + termdays);
       
            var day = invoicedateTemp.getDate().toString().padStart(2, '0');
            var month = (invoicedateTemp.getMonth() + 1).toString().padStart(2, '0'); // Months are zero-based
            var year = invoicedateTemp.getFullYear();
    
            var formattedDueDate = day + '-' + month + '-' + year;
			console.log('formattedDueDate NDR' + formattedDueDate);
            return formattedDueDate;
          
       },
       finalizeTodo: function(component) {
        var todoRecordId = component.get("v.todorecordid");
        if(todoRecordId && typeof finalizeTodo === 'function') {
            finalizeTodo(todoRecordId, true);
        }
    },
})