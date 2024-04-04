({
    onInit: function (component, event, helper) {
   
     

       // component.set("v.shape", 'square');  
       // component.find("select").set("v.value", "square");
       /* component.myGreeting = function(component, event, helper) {
            var selecteditem = document.querySelector(".cardfind")
            if(selecteditem){
              selecteditem.classList.remove("card-container");  
            }
            
        },
        window.setTimeout(
            $A.getCallback(function () {
               component.myGreeting();
            }), 5000
        );   */ 
        
        component.displayMessage = function (title, message, type) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "mode": 'dismissible',
                "title": title,
                "type": type,
                "message": message
            });
            toastEvent.fire();
        };

        var recordId = component.get("v.recordId");
        var action = component.get("c.getSysTrackRecordPictureURL");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                    var imageURL = a.getReturnValue();
                    console.log('imageURL ' + imageURL);
                    if(imageURL !== 'noimage'){
                        // Success
                        component.set("v.imageURL", imageURL);    
                        // $A.get('e.force:refreshView').fire();
                    }else{
                        var generateshortcodeaction = component.get("c.getShortendImageName");
                       //component.set('v.searchText',event.target.value);
                    generateshortcodeaction.setParams({
                         nameToShortend:component.get('v.FullName'),
        });
        generateshortcodeaction.setCallback(this, function (response) {
            var stateofshortcode = response.getState();
            if (stateofshortcode === "SUCCESS") {
                var Shortcode = response.getReturnValue();
                 component.set('v.Shortcode',Shortcode);
               
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
                        //helper.generateshortcode(component,event);
                        console.log('helper crossed');
                    }
            }
            else{
                // Failure
                console.log('Error in Retriving imageURL');
            }
        });
        $A.enqueueAction(action);
          
    },
    changeImageStyle: function (component, evt, helper) {
        var cstyle = component.find('select').get('v.value'); 
        console.log(cstyle); 
        component.set("v.shape", cstyle);  
    },
    changeImageWidth: function (component, evt, helper) {
        var imgWidth = component.find('imageWidth').get('v.value');
        console.log('imgWidth'+imgWidth);   
        component.set("v.imgWidth", imgWidth);  
    },
    changeImageHeight: function (component, evt, helper) {
        var imgHeight = component.find('imageHeight').get('v.value');  
        console.log('imgHeight'+imgHeight);   
        component.set("v.imgHeight", imgHeight);  
    },
  testbutton: function (component, event, helper) {
 
        let selectedsection = document.querySelector(".card-container");
        console.log('selectedsection'+selectedsection);
            setTimeout(() => {
       selectedsection.classList.remove("card-container");
       selectedsection.querySelectorAll(".card-container")
       .forEach((selectedsection) => selectedsection.classList.remove("card-container"));
}, 3000); 
    }
})