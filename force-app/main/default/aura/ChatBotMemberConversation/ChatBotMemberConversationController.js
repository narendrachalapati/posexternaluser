({
    doint: function (component, event, helper) {
        component.set('v.isLoading', true);
        if (!component.get('v.componentUniqueName')) {
            component.set('v.componentUniqueName', 'inb'+helper.uuid4());
            component.set('v.isIsolatedComponent', true);
        }
        helper.logConsoleDebug('componentUniqueName ChatBotMemberConversation init  ' + component.get('v.componentUniqueName'), 'log');
        
        var recordId = component.get('v.recordId');
        recordId = helper.getBlankorNullForInvalidData(recordId, true);
        var contactPhoneNumber = component.get('v.contactPhoneNumber');
        contactPhoneNumber = helper.getBlankorNullForInvalidData(contactPhoneNumber, true);
        helper.logConsoleDebug('recordId ' + recordId, 'log');
        helper.logConsoleDebug('contactPhoneNumber ' + contactPhoneNumber, 'log');
        
        //Fetch Logged In user data to filter platform events based on Account
        var fetchUserAction = component.get("c.fetchCurrentUserWrapper");
        fetchUserAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
               // set current user and Contact information on userContactWrap attribute
                component.set("v.userContactWrap", storeResponse);
                var userAccountId = component.get("v.AccountId");
                helper.logConsoleDebug('userAccountId ' + userAccountId , 'log');

                //Init Object Related SMS Templates
                helper.getAllSMSTemplates(component, event, helper);

                // helper.getAllFromPhoneNumbers(component, event, helper);
                // helper.getDefaultPhoneNumber(component, event, helper); 
                
                if( (recordId != '') || (contactPhoneNumber != '') ){
                    helper.InitMemberMessagesList(component, event, helper, false);
                } else {
                    component.set('v.isLoading', false);
                } 

            } else { // if any callback error, display error msg
                helper.logConsoleDebug('Error in Retriving CurrentUserWrapper', 'log');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.logConsoleDebug('Failed to Retrive CurrentUserWrapper : ' + errors[0].message, 'log');
                    }
                }

                //Init Object Related SMS Templates
                helper.getAllSMSTemplates(component, event, helper);

                // helper.getAllFromPhoneNumbers(component, event, helper);
                // helper.getDefaultPhoneNumber(component, event, helper); 
                
                if( (recordId != '') || (contactPhoneNumber != '') ){
                    helper.InitMemberMessagesList(component, event, helper, false);
                } else {
                    component.set('v.isLoading', false);
                } 
           }
        });
        $A.enqueueAction(fetchUserAction);
              
        try{
            var channel = '/event/InboxLatestMessage__e';
            const replayId = -1;
            
            // Get the empApi component
            const empApi = component.find('empApi');
            // Uncomment below line to enable debug logging (optional)
            // empApi.setDebugFlag(true);
            
            // Subscribe to the channel and save the returned subscription object.
            // Subscribe to an event
            empApi.subscribe(channel, replayId, $A.getCallback(eventReceived => {
                var payloadmessage = eventReceived.data.payload;
                //Exclude Event subscription based on Account
                var userAccountId = component.get("v.AccountId");
                if(payloadmessage.Account__c != userAccountId){
                    return;
                }
                // Process event (this is called each time we receive an event) 
                helper.logConsoleDebug('Received payloadmessage: ' + JSON.stringify(payloadmessage), 'log');                
                helper.logConsoleDebug('Received Activity: ' + payloadmessage.Type__c, 'log');
                helper.logConsoleDebug('Received Activity: ' + payloadmessage.Direction__c, 'log');
                helper.logConsoleDebug('Received Activity: ' + payloadmessage.Status__c, 'log');
                helper.logConsoleDebug('Received Activity: ' + payloadmessage.Activity_No__c, 'log');
                helper.logConsoleDebug('Received Activity: ' + payloadmessage.ActivityId__c, 'log');
                helper.logConsoleDebug('Received Activity: ' + payloadmessage.Message__c, 'log');
                helper.logConsoleDebug('Received Activity: ' + payloadmessage.media_url__c, 'log');
                helper.logConsoleDebug('Received Activity: ' + payloadmessage.Formatted_Phone__c, 'log');
                helper.logConsoleDebug('Received Activity: ' + payloadmessage.Member_Name__c, 'log');
                helper.logConsoleDebug('Received Activity: ' + payloadmessage.Account__c, 'log');
                //Create Media URL Array like Activity SOQL
                if( (payloadmessage.Type__c == 'mms') && (payloadmessage.media_url__c != '') ){
                    var medialUrlsArray = payloadmessage.media_url__c.split(",");
                    var mediaUrlArrayObject = [];
                    medialUrlsArray.forEach(function(iterMedialUrl, index) {
                        var tempMediaUrlObject = {Name: payloadmessage.ActivityId__c+'_'+index , Media_Url__c: iterMedialUrl};
                        mediaUrlArrayObject.push(tempMediaUrlObject);
                    });
                    //Media_Urls__r
                    if( (mediaUrlArrayObject != undefined) || (mediaUrlArrayObject != '') ){
                        payloadmessage['Media_Urls__r'] = mediaUrlArrayObject;
                    }                    
                }
                helper.logConsoleDebug('Final payloadmessage: ' + JSON.stringify(payloadmessage), 'log');
                helper.logConsoleDebug(payloadmessage, 'table');
                var whattId = payloadmessage.WhatId__c;
                whattId = helper.getBlankorNullForInvalidData(whattId, true);
                var activityId = payloadmessage.ActivityId__c;
                activityId = helper.getBlankorNullForInvalidData(activityId, true);
                var activityPhone = payloadmessage.Formatted_Phone__c;
                activityPhone = helper.getBlankorNullForInvalidData(activityPhone, true);
                var externalPointOfContact = (whattId=='') ? activityPhone : whattId;
                externalPointOfContact = helper.getBlankorNullForInvalidData(externalPointOfContact, true);
                var unreadActivitiesCount = payloadmessage.Unread_Activities__c;
                unreadActivitiesCount = helper.getBlankorNullForInvalidData(unreadActivitiesCount, true);
                unreadActivitiesCount = (unreadActivitiesCount == '') ? 0 : unreadActivitiesCount;

                var fetchRecordId = component.get('v.recordId');
                fetchRecordId = helper.getBlankorNullForInvalidData(fetchRecordId, true);
                var fetchContactPhoneNumber = component.get('v.contactPhoneNumber');
                fetchContactPhoneNumber = helper.getBlankorNullForInvalidData(fetchContactPhoneNumber, true);
                var latestActivitiesMap = component.get('v.latestActivitiesMap');
                latestActivitiesMap = (latestActivitiesMap instanceof Map) ? latestActivitiesMap : new Map();
                var latestActivitiesList = component.get('v.latestActivitiesList');
                latestActivitiesList = (latestActivitiesList instanceof Array) ? latestActivitiesList : [];
                helper.logConsoleDebug('latestActivitiesList: ' + latestActivitiesList, 'log');
                helper.logConsoleDebug('latestActivitiesList: ' + ((fetchRecordId != '') || (fetchContactPhoneNumber != '')), 'log');
                helper.logConsoleDebug('latestActivitiesList: ' + ((fetchRecordId == whattId) || (fetchContactPhoneNumber == activityPhone)), 'log');
                if( ((fetchRecordId != '') || (fetchContactPhoneNumber != '')) && ((fetchRecordId == whattId) || (fetchContactPhoneNumber == activityPhone)) ){//Identify if New Message is for Selected Record or Not
                    //unreadActivitiesCount
                    if(unreadActivitiesCount > 0){
                        helper.markActivitiesAsRead(component, event, helper);
                    }
                    //Check and Upsert to LatestActivitesMap
                    if(activityId != ''){
                        latestActivitiesMap.set(activityId, payloadmessage);
                        //Scroll to Conversation Bottom
                        window.setTimeout($A.getCallback(function () {
                            helper.scrolltoConversationBottom(component, event, helper);
                        }), 500);
                        window.setTimeout($A.getCallback(function () {
                            helper.scrolltoConversationBottom(component, event, helper);
                        }), 2000);
                        //Hide sending spinner
                        component.set('v.showLoadingSpinner', false);
                    }
                    //Check If Map empty or not
                    if(latestActivitiesMap.size > 0){
                        //Convert Map Values to Array
                        latestActivitiesList = Array.from(latestActivitiesMap.values());
                    }else{
                        latestActivitiesList = [];
                    }                    
                    // latestActivitiesList.push(payloadmessage);
                    helper.logConsoleDebug('Final latestActivitiesList: ', 'log');
                    helper.logConsoleDebug(latestActivitiesList, 'table');
                    helper.logConsoleDebug('Final latestActivitiesMap: ', 'log');
                    helper.logConsoleDebug(latestActivitiesMap, 'table');
                    component.set('v.latestActivitiesMap', latestActivitiesMap);
                    component.set('v.latestActivitiesList', latestActivitiesList);
                }
                //send communication event to refresh left component data 
                //Send Event to ChatBotMembers Component to Refresh Members List
                var eventName = 'refreshInboxMemberList';
                var eventSource = 'ChatBotMemberConversation';
                var eventAction = 'refreshInboxMembers';
                var groupName = component.get('v.componentUniqueName');
                helper.logConsoleDebug('groupName ChatBotMemberConversation ' + groupName, 'log');  

                var onUtilityBar = component.get('v.onUtilityBar');
                var isIsolatedComponent = component.get('v.isIsolatedComponent');
                //If utility no need to refresh if only conversation no need to refresh
                // non utility container only refresh
                //if( (onUtilityBar == false) && (isIsolatedComponent == false) ){
                helper.fireApplicationEventCallWithParams('componentCommunicationEvent' , { message : '', isLoading:false , eventMessage:'{"eventName":"' + eventName + '","eventSource":"' + eventSource + '","eventAction":"' + eventAction + '","groupName":"' + groupName + '"}' } );
                //}

            })).then(subscription => {
                // Confirm that we have subscribed to the event channel.
                // We haven't received an event yet.
                // Subscription response received.
                helper.logConsoleDebug('Subscribed to channel '+ subscription.channel, 'log');
                // Save subscription to unsubscribe later
                component.set('v.InboxLatestMessageEventSubscription', subscription);
            });

            // Register error listener and pass in the error handler function
            empApi.onError($A.getCallback(error => {
                // Error can be any type of error (subscribe, unsubscribe...)
                helper.logConsoleDebug('EMP API error: '+ JSON.stringify(error), 'log');
            }));
        }catch(e){
            helper.logConsoleDebug('Exception on Platform event ' + e, 'log');
            //Hide sending spinner
            component.set('v.showLoadingSpinner', false);
        }

        // window.setTimeout(
        //     $A.getCallback(function () {
        //         helper.startTimer(component, event, helper);
        //     }), 5000
        // );
    },

    handleInboxPoolingEvent: function (component, event, helper) {
        //Received Event Params
        var aurcomponentname = event.getParam("aurcomponentname");
        var componentUniqueName = component.get('v.componentUniqueName');
        if (componentUniqueName == aurcomponentname) {
            var showLoader = event.getParam("showLoader");
            var controllermethod = event.getParam("controllermethod");
            var searchkey = event.getParam("searchkey");
            var latestActivityNum = event.getParam("storedActivityNumber");
            var contactPhoneNumber = event.getParam("contactPhoneNumber");
            var recordId = event.getParam("currentContactId");
            helper.logConsoleDebug('Received Pooling Params: ', 'log');
            helper.logConsoleDebug('aurcomponentname: ' + aurcomponentname, 'log');
            helper.logConsoleDebug('showLoader: ' + showLoader, 'log');
            helper.logConsoleDebug('controllermethod: ' + controllermethod, 'log');
            helper.logConsoleDebug('searchkey: ' + searchkey, 'log');
            helper.logConsoleDebug('latestActivityNum: ' + latestActivityNum, 'log');
            helper.logConsoleDebug('contactPhoneNumber: ' + contactPhoneNumber, 'log');
            helper.logConsoleDebug('currentContactId: ' + currentContactId, 'log');
            var fetchSearchText = component.get('v.searchText');

            component.set("v.userInteraction", true);
            if (showLoader == true) {
                component.set('v.isLoading', true);
            }
            latestActivityNum = ((latestActivityNum != undefined) && (latestActivityNum != null)) ? latestActivityNum : 0.0;
            this.logConsoleDebug('Parameter to send latestActivityNum is: ' + latestActivityNum, 'log');
            contactPhoneNumber = ((contactPhoneNumber == undefined) || (contactPhoneNumber == null) || (contactPhoneNumber == '')) ? '' : contactPhoneNumber;
            recordId = ((recordId == undefined) || (recordId == null) || (recordId == '')) ? '' : recordId;

            var pollContactActivityList = component.get('c.' + controllermethod);
            pollContactActivityList.setParams({
                'searchkey': fetchSearchText,
                'storedActivityNumber': latestActivityNum,
                'contactPhoneNumber': contactPhoneNumber,
                'currentRecordId': recordId
            });
            pollContactActivityList.setCallback(this, function (response) {
                var state = response.getState();
                helper.logConsoleDebug('poll for contactSearch state' + state, 'log');
                if (state == "SUCCESS") {//memberLatestActivities
                    var latestActivityMessages = response.getReturnValue();
                    helper.logConsoleDebug('latestActivityMessages ' + (latestActivityMessages.length), 'log');
                    if (latestActivityMessages.length != 0) {
                        //setting the response from apex class to the attribute     
                        if ((fetchSearchText == null) || (fetchSearchText == undefined) || fetchSearchText == "")
                            component.set('v.activitywrapper', latestActivityMessages);
                        //helper.setUtilityLabel();
                    }
                    if (showLoader == true) {
                        component.set('v.isLoading', false);
                    }

                    component.set("v.userInteraction", false);
                } else { // if any callback error, display error msg
                    // helper.displayMessage('Error', 'An error occurred during Polling ' + state, 'Error', 'dismissible');
                    component.set("v.userInteraction", false);
                    if (showLoader == true) {
                        component.set('v.isLoading', false);
                    }
                }
            });
            $A.enqueueAction(pollContactActivityList);
        }
    },

    handleComponentCommunicationEvent : function(component, event, helper) {
        var isIsolatedComponent = component.get('v.isIsolatedComponent');
        var componentUniqueName = component.get('v.componentUniqueName');
        var message = event.getParam("message");
        var eventMessage = event.getParam("eventMessage");
        var isLoading = event.getParam("isLoading");

        var eventMessageIsJson = helper.isJson(eventMessage);
        if(eventMessageIsJson){
            var eventMessageObj = JSON.parse(eventMessage);
            if (eventMessageObj.hasOwnProperty('eventName') && eventMessageObj.hasOwnProperty('eventSource') && eventMessageObj.hasOwnProperty('eventAction') && eventMessageObj.hasOwnProperty('groupName')) {
                var eventName = eventMessageObj.eventName; //'openMessageDetails'
                var eventSource = eventMessageObj.eventSource; //'ChatBotMembers'
                var eventAction = eventMessageObj.eventAction; //'MemberClick'
                var groupName = eventMessageObj.groupName; //'randomparentuuid'
                if ( ( (eventName == 'openMessageDetails') && (eventSource == 'ChatBotMembers') && (componentUniqueName == groupName) ) || ( (eventName == 'openMessageDetails') && (eventSource == 'ChatBotContainer') && (componentUniqueName == groupName) ) ) {
                    if(isLoading == true){
                        component.set('v.isLoading', true);
                    }
                    var selectedRecordId = eventMessageObj.recordId;
                    var contactPhoneNumber = eventMessageObj.contactPhoneNumber;
                    var selectedRecordLatestActivityNumber = eventMessageObj.latestActivityNumber;
                    selectedRecordLatestActivityNumber = helper.getBlankorNullForInvalidData(selectedRecordLatestActivityNumber, true);
                    selectedRecordLatestActivityNumber = (selectedRecordLatestActivityNumber == '') ? 0 : parseFloat(selectedRecordLatestActivityNumber);
                    var selectedObjectapiname = eventMessageObj.objectapiname;
                    helper.logConsoleDebug('eventMessageObj.recordId ' + selectedRecordId, 'log');
                    component.set('v.latestActivitiesList', []);
                    component.set('v.latestActivitiesMap', {});

                    component.set('v.recordId', '');
                    component.set('v.recordId', selectedRecordId);
                    component.set('v.contactPhoneNumber', contactPhoneNumber);
                    component.set('v.memberObjectapiname', selectedObjectapiname);
                    component.set('v.latestActivityNum', selectedRecordLatestActivityNumber);
                    //Reset Current Page to First Page
                    //Init Member Related Activities
                    helper.InitMemberMessagesList(component, event, helper, false);     
                    var messageinput;
                    if (isIsolatedComponent) {
                        messageinput = document.querySelector("." + componentUniqueName + ".messagesdetailtab .message-input");
                    } else {
                        messageinput = document.querySelector("." + componentUniqueName + " .message-input");
                    }

                    if(messageinput){
                        messageinput.value = '';
                    }  
                } else if ( (eventName == 'hideChatBot') && (eventSource == 'ChatBotMemberConversation') && (componentUniqueName == groupName) ){
                    if (isLoading == true) {
                        component.set('v.isLoading', true);
                    }

                    var messagesdetailtabElementForHide;
                    if (isIsolatedComponent) {
                        messagesdetailtabElementForHide = document.querySelector("." + componentUniqueName + ".messagesdetailtab");
                    } else {
                        messagesdetailtabElementForHide = document.querySelector("."+componentUniqueName + " .messagesdetailtab");
                    }

                    if(messagesdetailtabElementForHide){
                        messagesdetailtabElementForHide.style.setProperty("display", "none", "important");
                    }

                    if (isLoading == true) {
                        component.set('v.isLoading', false);
                    }
                    
                } else if ( (eventName == 'showChatBot') && (eventSource == 'ChatBotMemberConversation') && (componentUniqueName == groupName) ){
                    if (isLoading == true) {
                        component.set('v.isLoading', true);
                    }

                    var messagesdetailtabElementForShow;
                    if (isIsolatedComponent) {
                        messagesdetailtabElementForShow = document.querySelector("." + componentUniqueName + ".messagesdetailtab");
                    } else {
                        messagesdetailtabElementForShow = document.querySelector("."+componentUniqueName + " .messagesdetailtab");
                    }

                    if(messagesdetailtabElementForShow){
                        messagesdetailtabElementForShow.style.removeProperty("display");
                    }

                    if (isLoading == true) {
                        component.set('v.isLoading', false);
                    }
                    
                }


            }
            
        }

        if (eventMessage =='CloseInboxPopup'){
            helper.navigateToInboxFromPOS(component, event); 
        }
        
        if (eventMessage =='CloseSchedulingPopup'){
            helper.navigateToInboxFromScheduler(component, event); 
        }
        
        helper.logConsoleDebug('ChatBotMemberConversation Message Received message ' + message, 'log');
        helper.logConsoleDebug('ChatBotMemberConversation Message Received eventMessage ' + eventMessage, 'log');
        helper.logConsoleDebug('ChatBotMemberConversation Message Received isLoading ' + isLoading, 'log');
        helper.logConsoleDebug('Message Received in ChatBotMemberConversation Component', 'log');
    },

    // Load Previous Messages
    fetchPreviousMessages: function (component, event, helper) {      
        component.set('v.isLoading', true);  
        var currentMessagesListPage = component.get('v.currentMessagesListPage');
        currentMessagesListPage += 1;
        component.set('v.currentMessagesListPage' , currentMessagesListPage);
        var messagesLimitPerPage = component.get('v.messagesLimitPerPage');
        helper.logConsoleDebug('Page Size: ' + messagesLimitPerPage + 'Current Page: ' + currentMessagesListPage, 'log');
        helper.getMessagesList(component, event, helper, true);
    },

    inputkeyCheck : function(component, event, helper){
        var isIsolatedComponent = component.get('v.isIsolatedComponent');
        var componentUniqueName = component.get('v.componentUniqueName');
        var currentMessage = component.get('v.currentMessage');

        var messageinput;
        if (isIsolatedComponent) {
            messageinput = document.querySelector("." + componentUniqueName + ".messagesdetailtab .message-input");
        } else {
            messageinput = document.querySelector("."+componentUniqueName + " .message-input"); 
        }

        if(event.which == 13 && event.shiftKey) {
            currentMessage = currentMessage.trim();
            if(messageinput){
                messageinput.value = currentMessage;
            }
        } else if (event.which == 13){
            event.target.blur();
            helper.logConsoleDebug('Enter Key Sending Message ', 'log');
            helper.sendOutboundSMS(component, event, helper);  
        }    
    },

    onFocusSendMessageHandler: function (component, event, helper) {
        helper.onFocusSendMessage(component);
    },

    onFocusOutSendMessageHandler: function (component, event, helper) {
        helper.onFocusOutSendMessage(component);
    },

    updateActivityMesssage: function (component, event, helper) {
        var isIsolatedComponent = component.get('v.isIsolatedComponent');
        var componentUniqueName = component.get('v.componentUniqueName');
        var currentMessage = event.target.value;
        component.set('v.currentMessage', currentMessage);   

        var messageFieldMaxLength = component.get('v.messageFieldMaxLength');		
        var messageinputElement, messageCounterElement;
        if (isIsolatedComponent) {
            messageinputElement = document.querySelector("." + componentUniqueName + ".messagesdetailtab .message-input");
            messageCounterElement = document.querySelector("." + componentUniqueName + ".messagesdetailtab .message-counter");
        } else {
            messageinputElement = document.querySelector("." + componentUniqueName + " .message-input");
            messageCounterElement = document.querySelector("." + componentUniqueName + " .message-counter");
        }
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

    sendMessage: function (component, event, helper) {
        helper.logConsoleDebug('Send Message Called', 'log');
        event.target.blur();
        helper.sendOutboundSMS(component, event, helper);
    },

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
    
    handleAttachmentLoad: function(component, event, helper) {
        helper.logConsoleDebug('handleAttachmentLoad Successfully Uploaded: ', 'log');
        helper.sendOutboundMMS(component, event, helper);
    },
    
    updateContactPointConsentStatus: function (component, event, helper) {
        helper.checkContactPointConsentStatus(component, event, helper);
    },
    
    BacktoInbox: function (component, event, helper) {
        var isIsolatedComponent = component.get('v.isIsolatedComponent');
        var componentUniqueName = component.get('v.componentUniqueName');
        //Reset Selection Attributes
        component.set('v.recordId', ''); 
        component.set('v.contactName', ''); 
        component.set('v.contactPhoneNumber', '');
        component.set('v.hasPictureURL', false); 
        component.set('v.pictureURL', '');
        component.set('v.shortNameCode', ''); 
        component.set('v.objectapiname', ''); 
        component.set('v.latestActivityNum', 0); 
        component.set('v.currentMessage', '');
        component.set('v.selectedPhoneNumber', '');
        component.set('v.selectedTemplate', '');
        component.set('v.ShowPosQuickActions', false);
        component.set('v.isMemberOptedOut', false);
        component.set('v.memberConsentStatus', ''); 
        var messageinput;
        if (isIsolatedComponent) {
            messageinput = document.querySelector("." + componentUniqueName + ".messagesdetailtab .message-input");
        } else {
            messageinput = document.querySelector("."+componentUniqueName + " .message-input"); 
        }

        if(messageinput){
            messageinput.value = '';
        }
        
        //Reset Wrappers
        component.set('v.memberInitRelatedActivities', '');
        component.set('v.memberPreviousRelatedActivities', '');
        component.set('v.memberLatestActivities', '');
        component.set('v.latestActivitiesList', []);
        component.set('v.latestActivitiesMap', {});
        //Reset Paginated Attributes
        component.set('v.currentMessagesListPage', 1);
        component.set('v.totalPages', 0);
        component.set('v.totalActivityRecords', 0);
        component.set('v.scrollToBottom',true);
        //Send Event to ChatBotMembers Component to Clear Selection
        var eventName = 'clearMemberSelection';
        var eventSource = 'ChatBotMemberConversation';
        var eventAction = 'backToMemberScreen';
        helper.fireApplicationEventCallWithParams('componentCommunicationEvent' , { message : '', isLoading:false , eventMessage:'{"eventName":"' + eventName + '","eventSource":"' + eventSource + '","eventAction":"' + eventAction + '","groupName":"' + componentUniqueName + '"}' } );

        var messagesdetailtabElement;
        if (isIsolatedComponent) {
            messagesdetailtabElement = document.querySelector("." + componentUniqueName + ".messagesdetailtab");
        } else {
            messagesdetailtabElement = document.querySelector("." + componentUniqueName + " .messagesdetailtab"); 
        }
        if(messagesdetailtabElement){
            messagesdetailtabElement.classList.remove("activetab");
        }
    },

    //Call Contact using PHLO 
    phoneCall: function (component, event, helper) {
        component.set('v.isLoading',true);
        component.set("v.userInteraction", true);
        var recordId = component.get('v.recordId');
        helper.logConsoleDebug('phoneCall Init', 'log');
        let action = component.get("c.calloutSynchronousOutbound");
        action.setParams({
            "recId": recordId,//Dynamic
            "objSetting": 'Plivo_PHLO_Call',
            "apexHandler": 'SYS_ApplicationService',
            "direction": 'OUT',
            "accountMergeField" : 'AccountId'//Dynamic
        });

        action.setCallback(this, function (response) {
            let state = response.getState();
            helper.logConsoleDebug('phoneCall Callback ' + state, 'log');
            if (state === 'SUCCESS') {
                var sysLogStatus = response.getReturnValue();
                helper.logConsoleDebug('Apex response:'+ sysLogStatus, 'log');
                component.set("v.userInteraction", false);
                component.set('v.isLoading',false);
                if (sysLogStatus.toUpperCase() == 'DONE') {
                    helper.displayMessage('Success!', 'Check your Phone to Answer Call ', 'success', 'dismissible');

                } else {
                    helper.displayMessage('Failure!', 'Failed to arrange a call. Status: ' + sysLogStatus, 'error', 'dismissible');

                }

            } else if (state === "ERROR") {
                var errors = response.getError();
                component.set("v.userInteraction", false);
                component.set('v.isLoading',false);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.displayMessage('Failure!', 'Failed to arrange a call ' + errors[0].message, 'error', 'dismissible');
                    }
                } else {
                    helper.displayMessage('Failure!', 'Failed to arrange a call Error Details: Unknown error', 'error', 'dismissible');
                }

            }
        });

        $A.enqueueAction(action);
    },

    handleDestroy : function( component, event, helper ) {
        helper.logConsoleDebug('clear interval due to navigation', 'log');
        window.clearInterval(component.get("v.setIntervalId"));
        component.set("v.setIntervalId","");
    },

    setup: function(component, event, helper) {
        helper.logConsoleDebug('Jquery scriptloaded', 'log');
    },

    fancyboxsetup: function(component, event, helper) {
        helper.logConsoleDebug('setupFancybox scriptloaded', 'log');
        helper.setupFancybox();
    },


    // handleTemplateChange: function(component, event, helper) {
    //     let template = component.find('select-template').get('v.value');
    //     helper.logConsoleDebug('template' + template, 'log');
    //     component.set('v.isLoading', true);
    //     helper.getParsedBody(component, event, helper, template);
    // }, 

    handleTemplateComponentEvent : function(component, event, helper) {
        var message = event.getParam("selectedTemplateText"); 
        helper.logConsoleDebug('message received ' + message, 'log');
        var componentUniqueName = component.get('v.componentUniqueName');
        var isIsolatedComponent = component.get('v.isIsolatedComponent');
        component.set("v.currentMessage", message);

        var messageFieldMaxLength = component.get('v.messageFieldMaxLength');
        var messageinput, messageCounterElement;
        if (isIsolatedComponent) {
            messageinput = document.querySelector("." + componentUniqueName + ".messagesdetailtab .message-input");
            messageCounterElement = document.querySelector("." + componentUniqueName + ".messagesdetailtab .message-counter");
        } else {
            messageinput = document.querySelector("."+componentUniqueName + " .message-input"); 
            messageCounterElement = document.querySelector("." + componentUniqueName + " .message-counter");
        }

        if(messageinput){
            messageinput.value = message;
            messageinput.style.height = 'max-content';

            // Call the helper function to calculate the character count, SMS count, and Max character Length
            var result = helper.countCharactersAndSMS(message);
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

        helper.logConsoleDebug(' message received' + message, 'log');

    },

    handleFromNumberComponentEvent : function(component, event, helper) {
        var fromNumber = event.getParam("selectedFromNumber"); 
        component.set('v.selectedPhoneNumber', fromNumber);
        helper.logConsoleDebug('selected number parent' + fromNumber, 'log'); 
    },

    // handlePhoneNumber: function(component, event, helper) {
    //     let fromNumber = component.find('select-from-number').get('v.value');
    //     helper.logConsoleDebug('selected number' + fromNumber, 'log');
    // },
    
    //Open Scheduling Screen
    
    schedulingscreenhandler: function (component, event, helper) {
        var componentUniqueName = component.get('v.componentUniqueName');
        component.set('v.isLoading', true);
        var currentcontact = component.get('v.recordId');
        if (currentcontact != undefined) {
            var ctarget = event.currentTarget;
            var id_str = ctarget.dataset.selectedactivityrecordid;
            helper.logConsoleDebug('Activityrecordid ' + id_str, 'log'); 

            //Send Event to ChatBot Component to Hide ChatBot
            var eventName = 'hideChatBot';
            var eventSource = 'ChatBotMemberConversation';
            var eventAction = 'hideChatBot';
            helper.fireApplicationEventCallWithParams('componentCommunicationEvent' , { message : '', isLoading:false , eventMessage:'{"eventName":"' + eventName + '","eventSource":"' + eventSource + '","eventAction":"' + eventAction + '","groupName":"' + componentUniqueName + '"}' } );

            if(id_str != undefined ){
                component.set('v.activityid',id_str);
                // window.clearInterval(component.get("v.setIntervalId"));
                // component.set("v.setIntervalId","");
                component.set("v.ShowScheduling", true);
            }else{
                // window.clearInterval(component.get("v.setIntervalId"));
                // component.set("v.setIntervalId","");
                component.set("v.ShowScheduling", true);
            }
            component.set('v.isLoading', false);
        } else {
            helper.displayMessage('Error', 'Appointment Link was not Generated... ', 'Error', 'dismissible');
            component.set('v.isLoading', false);
        }
    },

    //Open POS Screen
    createandOpenPOSOrder : function(component, event, helper) {
        var componentUniqueName = component.get('v.componentUniqueName');
        component.set('v.isLoading',true);
        // component.set("v.userInteraction", true);
        var selectedItem = event.currentTarget;
        var selectedMemberId = selectedItem.dataset.memberid;
        helper.logConsoleDebug('createandOpenPOSOrder ' + selectedMemberId, 'log'); 
        var selectedactivityrecordid = selectedItem.dataset.selectedactivityrecordid;
        if( (selectedactivityrecordid != undefined) && (selectedactivityrecordid != null) && (selectedactivityrecordid != '') ){
            component.set('v.activityid',selectedactivityrecordid);
        }
        
        helper.logConsoleDebug('selectedContactRecord ' + component.get('v.selectedContactRecord'), 'log'); 
        helper.logConsoleDebug(component.get('v.selectedContactRecord'), 'table'); 
        var contactRecordType = component.get('v.selectedContactRecord.RecordType.Name');
        if(contactRecordType != 'Member'){
            helper.displayMessage('Error', 'Cannot Create Order for Non POS Members ', 'Error','dismissible');
            component.set('v.isLoading',false);
            // component.set("v.userInteraction", false);
            return;
        }
        if( (selectedMemberId == null) || (selectedMemberId == undefined) || (selectedMemberId=='') ){
            helper.displayMessage('Error', 'Cannot Create Order Without a Contact ', 'Error','dismissible');
            component.set('v.isLoading',false);
            // component.set("v.userInteraction", false);
            return;
        }
        var action = component.get('c.createDraftOrderRecord');
        action.setParams({
            "memberId" : selectedMemberId,
            "activityRecordId" : selectedactivityrecordid,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            helper.logConsoleDebug('createDraftOrderRecord Response ' + selectedMemberId, 'log');
           if (state == "SUCCESS") {
               var orderUUID = response.getReturnValue();
               helper.logConsoleDebug('Init orderUUID', 'log');
               helper.logConsoleDebug(orderUUID, 'table');

               //Send Event to ChatBot Component to Hide ChatBot
               var eventName = 'hideChatBot';
               var eventSource = 'ChatBotMemberConversation';
               var eventAction = 'hideChatBot';
               helper.fireApplicationEventCallWithParams('componentCommunicationEvent' , { message : '', isLoading:false , eventMessage:'{"eventName":"' + eventName + '","eventSource":"' + eventSource + '","eventAction":"' + eventAction + '","groupName":"' + componentUniqueName + '"}' } );

               component.set('v.isLoading',false);
            //    component.set("v.userInteraction", false);
               helper.navigateToPOSOrderSelection(component, orderUUID.UUID__c);              
           } else { // if any callback error, display error msg
            component.set('v.isLoading',false);
            // component.set("v.userInteraction", false);
            helper.displayMessage('Error', 'An error occurred during order Creation ' + state, 'Error','dismissible');
           }
            
        });
        $A.enqueueAction(action);
    },

    //Navigate to POS
    navigateBackToInboxFromPOS: function(component, event, helper) {
        helper.navigateToInboxFromPOS(component, event); 
    },

    //Navigate to Scheduler
    navigateBackToInboxFromScheduler: function(component, event, helper) {
        helper.navigateToInboxFromScheduler(component, event); 
    },

})