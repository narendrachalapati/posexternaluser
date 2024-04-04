({
    doInit: function (component, event, helper) {
        component.displayMessage = function (title, message, type, mode) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "mode": mode,
                "title": title,
                "type": type,
                "message": message
            });
            toastEvent.fire();
        };

    // to fetch URL Parameter 
        // helper.getDefaultPhoneNumber(component, event, helper);
        component.set("v.isLoading", true);
        var pageRef = component.get("v.pageReference");
        var paramvalue = pageRef && pageRef.state && pageRef.state.c__sObjectApiName ? pageRef.state.c__sObjectApiName : '';
        console.log('state ',JSON.stringify(pageRef, null, 2));
        component.set("v.sObjectApiName", 'Contact');
        console.log('#sObjectApiName '+paramvalue);
        if(!component.get('v.sObjectApiName')) {
            component.displayMessage('URL parameter missing', 'Mass-message page is missing URL parameter. Please contact Admin!', 'error', 'error');
        } else {
            var action = component.get('c.getListviewFilters');
            action.setParams({
                "sObjectApiName" : component.get('v.sObjectApiName')
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log('listviewstate' + state);
                if (state == "SUCCESS") {
                    var listviewresponce = response.getReturnValue();
                    component.set('v.listviewobjt', listviewresponce);
        
                    console.table(component.get('v.listviewobjt'));
        
                    component.set("v.isLoading", false);
        
                } else { // if any callback error, display error msg
                    console.log('Error in Calling API');

                    component.set("v.isLoading", false);
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
            $A.enqueueAction(action);
        }

    //-------------------------

        component.set('v.selectedlistviewId', []);
        
    },

    openingmessagebox: function (component, event, helper) {
        component.set("v.isLoading", true);
        component.set("v.mycolumns", [

            {label: 'Contact Name', fieldName: 'Name', type: 'text'},
            {label: 'Contact Phone', fieldName: 'Phone_Number__c', type: 'Phone'},
            {label: 'Contact Email', fieldName: 'Email', type: 'Email'}
        ]);
        console.log('testingoptions');
        var ctarget = event.currentTarget;
        var selectedlisstview = ctarget.dataset.listviewid;
        component.set('v.selectedlistviewId', selectedlisstview);
        console.log('test' + selectedlisstview);
        
        var action = component.get('c.gettinglistviewfilteredRecords');
        action.setParams({
            filterId: selectedlisstview,
            objectName: component.get('v.sObjectApiName')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('listviewstate' + state);
            if (state == "SUCCESS") {
                var listofselectedrecords = response.getReturnValue();
                component.set('v.selectedlistofrecords', listofselectedrecords);
                console.log(component.get('v.selectedlistofrecords'));
                console.table(component.get('v.selectedlistofrecords'));
                component.set("v.isLoading", false);

            } else { // if any callback error, display error msg
                console.log('Error in Calling API');
                var errors = response.getError();
                console.log('errors' + errors[0].message);
                console.table(errors);
                component.set("v.isLoading", false);
            if (errors) {
                if (errors[0] && errors[0].message) {
                    component.displayMessage('NotAllowed to send', 'This List view is not a sendable list view', 'info', 'dismissible');
                }
            }
            }
        });
        $A.enqueueAction(action);
  },
  //this hook is called when sending the message by clicking the send button
//   Sendingmessages: function (component, event, helper) {
//     console.log('methhod called');
//     var tempsobject = component.get('v.selectedlistofrecords');
//     var message = component.get('v.currentMessage');
//     console.log('sobject'+tempsobject);
//     console.table(tempsobject);
//     var sobjectIdList = [];
//     var ActivityidList =[];
    
//    for (var i = 0; i < tempsobject.length; i++) {
//     console.log('forloopin');
//         var tempsobjectId = tempsobject[i].Id;
//         console.log('tempsobjectId'+tempsobjectId);
//         sobjectIdList.push(tempsobjectId);
//         //Do something
//     }
//     console.table(sobjectIdList);
//    var action = component.get('c.createActivity');
//       action.setParams({
//     messagebody: message,
//     messageSubject:'Outbound SMS Bulk send',
//     recordIdList:sobjectIdList,
//     });
//     action.setCallback(this, function (response) {
//         var state = response.getState();
//         console.log('listviewstate' + state);
//         if (state == "SUCCESS") {
//            var Listofactivities = response.getReturnValue();
//           component.set('v.Activitylist', Listofactivities);
//            console.log(component.get('v.Activitylist'));
//           console.table(component.get('v.Activitylist'));
//           for (var i = 0; i < Listofactivities.length; i++) {
//             console.log('forloopin');
//                 var tempActivityId = Listofactivities[i].Id;
//                 console.log('tempsobjectId'+tempActivityId);
//                 ActivityidList.push(tempActivityId);
//                 //Do something
//             }
           
//          // if( (ActivityidList != undefined) && (ActivityidList != null) ){
//             component.set('v.isLoading',true);
//             let SMSCalloutaction = component.get("c.calloutSynchronousOutbound");
//             SMSCalloutaction.setParams({
//                 "recIdList": ActivityidList,
//                 "objSetting": 'PlivoSMS',
//                 "apexHandler": 'Plivo_Outbound_SYS_ApplicationService',
//                 "direction": 'OUT',
//                 "accountMergeField" : 'Account__c'
//             });

//             SMSCalloutaction.setCallback(this, function (response) {
//                 let state = response.getState();
//                 console.log('SMS Callback ' + state);
//                 component.displayMessage('Failure!', 'Failed to Send SMS. Status: ' + state, 'error', 'dismissible');
                     
//                 if (state === 'SUCCESS') {
//                     var sysLogStatus = response.getReturnValue();
//                     console.log('Apex response:', sysLogStatus);
//                     if (sysLogStatus.toUpperCase() == 'DONE') {
//                         console.log('SMS Successfully Sent ');
//                         //component.displayMessage('Success!', 'SMS Successfully Sent ', 'success', 'dismissible');
//                    component.set('v.isLoading',false);
//                     } else {
//                         component.displayMessage('Failure!', 'Failed to Send SMS. Status: ' + sysLogStatus, 'error', 'dismissible');
                       
//                         component.set('v.isLoading',false);

//                     }

//                 } else if (state === "ERROR") {
//                   var errors = response.getError();
//                    component.set('v.isLoading',false);
//                     if (errors) {
//                         if (errors[0] && errors[0].message) {
//                             component.displayMessage('Failure!', 'Failed to Send SMS. Status: ' + errors[0].message, 'error', 'dismissible');
//                         }
//                     } else {
//                         component.displayMessage('Failure!', 'Failed to Send SMS. Status: Unknown error', 'error', 'dismissible');
//                     }

//                 }
//             });

//             $A.enqueueAction(SMSCalloutaction);
//        // }

//         } else { // if any callback error, display error msg
//            console.log('Error in Calling API');
//            var errors = response.getError();
//            console.log('errors' + errors[0].message);
//            console.table(errors);
//            if (errors) {
//               if (errors[0] && errors[0].message) {
//                  component.displayMessage('Failure!', 'Failed to Call API : ' + errors[0].message, 'error', 'dismissible');
//               }
//            }
//         }
//      });
//      $A.enqueueAction(action);

//   },
//   

    onFocusSendMessageHandler: function (component, event, helper) {
        helper.onFocusSendMessage(component);
    },

    onFocusOutSendMessageHandler: function (component, event, helper) {
        helper.onFocusOutSendMessage(component);
    },
    
  //hook is called when we typing the message in text box on keyup event
    
    updateActivityMesssage: function (component, event, helper) {
        var currentMessage = event.target.value;
        component.set('v.currentMessage', currentMessage);    

        var messageFieldMaxLength = component.get('v.messageFieldMaxLength');		
        var messageinputElement, messageCounterElement;
        messageinputElement = document.querySelector(".message-input");
        messageCounterElement = document.querySelector(".message-counter");
        if (messageinputElement) {
            let scHeight = event.target.offsetHeight;
            if (scHeight < 150) {
                messageinputElement.style.height = '145px';
            }

            // Call the helper function to calculate the character count, SMS count, and Max character Length
            var result = helper.countCharactersAndSMS(currentMessage);
            messageFieldMaxLength = result.maxCharacters;
            var messageCharacterCount = result.characters;
            var smsCount = result.sms;

            component.set('v.messageFieldMaxLength', messageFieldMaxLength);  
            component.set('v.messageCharacterCount', messageCharacterCount);  
            component.set('v.smsCount', smsCount);  

            //Here we set styles to change the counter along the way, in two breakpoints, 90 and 100 percent of the maxlength
            var ninetyPercent = messageFieldMaxLength * 0.9;
            
            if ( messageCharacterCount >= ninetyPercent && messageCharacterCount < messageFieldMaxLength ){
                messageCounterElement.style.color = "#FF8A65";
            } else if( messageCharacterCount >= messageFieldMaxLength ){
                messageCounterElement.style.color = "#FF3D00";
            } else {
                messageCounterElement.style.color = "#000000";
            } 
        }        
    },

    handleFromNumberComponentEvent : function(component, event, helper) {
        helper.logConsoleDebug('selected number before' + component.get('v.selectedPhoneNumber'), 'log'); 
        var fromNumber = event.getParam("selectedFromNumber"); 
        component.set('v.selectedPhoneNumber', fromNumber);
        helper.logConsoleDebug('selected number parent' + fromNumber, 'log'); 
    },

    handleTemplateComponentEvent : function(component, event, helper) {
        var message = event.getParam("selectedTemplateText"); 
        console.log('message received '+message);
        
        component.set("v.currentMessage", message);

        var messageinput;
        
        messageinput = document.querySelector(".message-input"); 
        

        if(messageinput){
            messageinput.value = message;
            messageinput.style.height = 'max-content';
        }

        helper.logConsoleDebug(' message received' + message, 'log');

    },

    openConfirm: function(component, event, helper) {
        helper.openConfirm(component, event);
    

    }
    ,

    handleFilesChange: function (component, event, helper) {
        var fileName = 'No File Selected..';
        helper.logConsoleDebug('fileName ' + fileName, 'log');
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
        if (component.find("fileId").get("v.files").length > 0) {
            helper.logConsoleDebug('fileName ' + fileName, 'log');
            helper.uploadHelper(component, event);
        } else {
            helper.displayMessage('Error', 'Please Select a Valid File ', 'Error', 'dismissible');
        }
    },

    resetFile: function(component, event, helper) {
        component.set('v.mmsPreview', "");
    }

 })