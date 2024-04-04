({
    ContactExissitingCheck: function (component, newplivoincomNum) {
       console.log('ContactExissitingCheck called');
       console.log('ContactExissitingCheck called'+newplivoincomNum);
   
        var Contactfetchaction = component.get('c.GettingContactByFormattedPhone');
        Contactfetchaction.setParams({
            FormattedPhone: newplivoincomNum
           
        });
        Contactfetchaction.setCallback(this, function (response) {
            var state = response.getState();
            console.log('ContactExissitingCheck state'+state);
            if (state == "SUCCESS") {
                var ContacttoNavegate = response.getReturnValue();
                var contactId = ContacttoNavegate.Id;
                
                component.set('v.ContactByphnNumb', ContacttoNavegate);
               console.log('contact'+component.get('v.ContactByphnNumb'));
               console.table(component.get('v.ContactByphnNumb'));
               console.log('ReDirectionURL');
        var contactId = component.get('v.ContactByphnNumb.Id');
        console.log('plivoincomingId'+contactId);
        var navService = component.find("navService");
        console.log('messagefromAuradoin'+component.get("v.PlivoIncomingPhonenum"));
      

            } else { // if any callback error, display error msg
                console.log('Error in Calling API');
                var errors = response.getError();
                console.log('errors' + errors[0].message);
                console.table(errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.displayMessage('Failure!', 'Failed to Call API : ' + errors[0].message, 'error', 'dismissible');
                    }
                }
            }
        });
        $A.enqueueAction(Contactfetchaction);
    }
})