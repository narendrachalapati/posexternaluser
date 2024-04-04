({

    // doint: function (component,event,helper) {
    //     console.log('dointcalled');
    //     var utilityAPI = component.find("utilitybar");
    //     utilityAPI.getAllUtilityInfo().then(function(response) {
    //         var myUtilityInfo = response[1];
    //         utilityAPI.openUtility({
    //             utilityId: myUtilityInfo.id
    //         });
    //    })
    //     .catch(function(error) {
    //         console.log(error);
    //     });
    // },
    
handlePlivoSDKMessage: function (component, message,helper) {
       
           console.log('method called handleclick');
           var payload = message.getParams().payload;
          console.log('payload'+payload);
          // Converting JSON-encoded string to JS object
         var Plivoincomingobj = JSON.parse(payload);
         console.log('plivoincomingphone'+Plivoincomingobj.src);
          var plivoincomNum = Plivoincomingobj.src;
      if(plivoincomNum !== ''){
        var utilityAPI = component.find("utilitybar");
        utilityAPI.getAllUtilityInfo().then(function(response) {
            var myUtilityInfo = response[0];
            console.table(response);
            console.table(myUtilityInfo);
            utilityAPI.openUtility({
                utilityId: myUtilityInfo.id
            });
       })
       
        .catch(function(error) {
            console.log(error);
        });
           var newplivoincomNum = plivoincomNum.replace('+','')
           alert(newplivoincomNum);
           helper.ContactExissitingCheck(component,newplivoincomNum);
           console.log('helper1crossed');
         component.set('v.PlivoIncomingPhonenum', newplivoincomNum);
           console.log('messagefromAura'+component.get("v.PlivoIncomingPhonenum"));
                     console.log('crossedhelper');
           }
          
        
           
       },
   
       handleError: function (component, event, helper) {
           var error = event.getParams();
           console.log(error);
       },
      
       
       // Navigate to the record create page for the Aura PageRef example
       handleClick : function(component, event, helper) {
        var  sobjectrecid  = component.get('v.ContactByphnNumb.Id');
        console.log('sobjectrecid'+sobjectrecid);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": sobjectrecid,
          "slideDevName": "related"
        });
        navEvt.fire();
       },
      })