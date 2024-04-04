({
    
    generateshortcode: function (component, event) {
        var generateshortcodeaction = component.get('c.getShortendImageName');
        component.set('v.searchText',event.target.value);
        generateshortcodeaction.setParams({
            nameToShortend:component.get('v.FullName'),
        });
        generateshortcodeaction.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var Shortcode = response.getReturnValue();
                 component.set('v.Shortcode',Shortcode);
                 console.table(Shortcode);
                 console.log(Shortcode);
                // get section Div element using aura:id
              } else { // if any callback error, display error msg
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.displayMessage('Error', 'An error occurred during Searching ' + errors[0].message, 'Error','dismissible');
                    }
                } else {
                    component.displayMessage('Error', 'An error occurred during Searching : Unknown error', 'Error','dismissible');
                }
             
            }
        });
        $A.enqueueAction(generateshortcodeaction);
    },   
     
})