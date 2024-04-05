({
    GuestuserCheck: function (component) {
        var action = component.get('c.Guestusercheck');
        var isGuestUser = component.get('v.IsGuestUser');
        action.setCallback(this, function (response) {
           var state = response.getState();
           console.log('Is guestuser check' + state);
           if (state == 'SUCCESS') {
              var Guestusercheck = response.getReturnValue();
              component.set('v.IsGuestUser', Guestusercheck);
              console.log('GuestusercheckNDR'+ component.get('v.IsGuestUser'));
               } else {
              console.log('Failed to Fetch Transaction ');
              var errors = response.getError();
            console.log(errors);
                 
           }
        });
        $A.enqueueAction(action);
  
     }
})