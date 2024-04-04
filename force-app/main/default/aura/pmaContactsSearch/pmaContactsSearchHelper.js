({
    getallopentabs : function(component) {
        var action = component.get('c.getOpenTabMembers');
        action.setCallback(this, function (response) {
            var state = response.getState();
           if (state == "SUCCESS") {
               var allopenTabs = response.getReturnValue();
                //For Aura attribute Iterate for UI
                component.set('v.openTabMembers',allopenTabs);
                console.log('***console.table for all open tabs****');
                console.table(allopenTabs);

                if (logApiResponses) { console.log('Init allopenTabs'); }
                if (logApiResponses) { console.table(allopenTabs); }
              
           } else { // if any callback error, display error msg
               var errors = response.getError();
               if (errors) {
                   if (errors[0] && errors[0].message) {
                       component.displayMessage('Error', 'An error occurred during Initialization of Open Tabs ' + errors[0].message, 'Error', 'dismissible');
                   }
               } else {
                   component.displayMessage('Error', 'An error occurred during Initialization of Open Tabs : Unknown error', 'Error', 'dismissible');
               }
           }
            
        });
        $A.enqueueAction(action);

    }
})