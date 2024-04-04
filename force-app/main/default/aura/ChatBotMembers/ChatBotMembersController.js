({
    doint: function (component, event, helper) {
        
        component.set('v.isLoading', true);
        if (!component.get('v.componentUniqueName')) {
            component.set('v.componentUniqueName', helper.uuid4());
            component.set('v.isIsolatedComponent', true);
        }
        helper.logConsoleDebug('componentUniqueName ChatBotMembers init  ' + component.get('v.componentUniqueName'), 'log');
        // helper.fetchScreenHeight();

        helper.logConsoleDebug('helper.isMobile()  ' + helper.isMobile(), 'log');

        // window.setTimeout(
        //     $A.getCallback(function () {
        //         helper.startTimer(component, event, helper);
        //     }), 5000
        // );
        helper.searchContacts(component, event, helper);
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
                component.logConsoleDebug('poll for contactSearch state' + state, 'log');
                if (state == "SUCCESS") {
                    var pooledActivityWrapper = response.getReturnValue();
                    if ((pooledActivityWrapper == null) || (pooledActivityWrapper == undefined) || pooledActivityWrapper == ""){
                        component.set('v.activitywrapper', pooledActivityWrapper);
                    }
                    // if (latestActivityMessages.length != 0) {

                    //     //setting the response from apex class to the attribute     
                    //     if ((fetchSearchText == null) || (fetchSearchText == undefined) || fetchSearchText == "")
                    //         component.set('v.activitywrapper', latestActivityMessages);
                    //     component.setUtilityLabel();
                    //     var currentContact = component.get("v.currentContact");
                    //     component.logConsoleDebug('Stored Contact', 'log');
                    //     component.logConsoleDebug(currentContact, 'table');
                    //     var curContactLatestActivities;
                    //     if ((currentContact != undefined) || (currentContact != null)) {
                    //         for (var currcontactActwrap of latestActivityMessages) {

                    //             if ((currcontactActwrap.contactid == currentContact.Id)) {
                    //                 //Update Current selected Contact Details
                    //                 component.set("v.currentContact", currcontactActwrap.cont);
                    //                 component.logConsoleDebug('Update Contact', 'log');
                    //                 component.logConsoleDebug(component.get("v.currentContact"), 'table');
                    //                 // Update Latest Polling Event Messages Attribute
                    //                 curContactLatestActivities = currcontactActwrap.LatestActivities;
                    //                 curContactLatestActivities = curContactLatestActivities.reverse();
                    //                 currcontactActwrap.LatestActivities = curContactLatestActivities;
                    //                 component.logConsoleDebug(currcontactActwrap, 'table');
                    //                 component.set('v.latestActivitiesFromPolling', currcontactActwrap);
                    //                 component.logConsoleDebug('after setting attribute ', 'log');
                    //                 component.logConsoleDebug(component.get('v.latestActivitiesFromPolling'), 'table');
                    //             }

                    //         }
                    //     }

                    // }
                    // component.logConsoleDebug(latestActivityMessages, 'table');
                    if (showLoader == true) {
                        component.set('v.isLoading', false);
                    }

                    component.set("v.userInteraction", false);
                } else { // if any callback error, display error msg
                    // component.displayMessage('Error', 'An error occurred during Polling ' + state, 'Error', 'dismissible');
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
                var eventName = eventMessageObj.eventName; //clearMemberSelection refreshInboxMemberList
                var eventSource = eventMessageObj.eventSource; //'ChatBotMemberConversation' 
                var eventAction = eventMessageObj.eventAction; //backToMemberScreen refreshInboxMembers
                var groupName = eventMessageObj.groupName; //'randomparentuuid'
                if ((eventName == 'clearMemberSelection') && (eventSource == 'ChatBotMemberConversation') && (componentUniqueName == groupName) ) {
                    if (isLoading == true) {
                        component.set('v.isLoading', true);
                    }
                    component.set('v.SelectedLatestActivityNum', 0);
                    component.set('v.SelectedObjectapiname', '');
                    component.set('v.SelectedRecordId', ''); 
                    component.set('v.SelectedContactPhone', '');

                    helper.searchContacts(component, event, helper);
                    helper.logConsoleDebug('Refreshed Member List ', 'log');

                    var memberslisttabElement;
                    if (isIsolatedComponent) {
                        memberslisttabElement = document.querySelector("." + componentUniqueName + ".memberslisttab");
                    } else {
                        memberslisttabElement = document.querySelector("."+componentUniqueName + " .memberslisttab");
                    }

                    if(memberslisttabElement){
                        memberslisttabElement.classList.add("activetab");
                    }
                    helper.logConsoleDebug('Resetted Selected Member Selection ', 'log');
                    if (isLoading == true) {
                        component.set('v.isLoading', false);
                    }
                } else if((eventName == 'refreshInboxMemberList') && (eventSource == 'ChatBotMemberConversation') && (componentUniqueName == groupName) ){
                    helper.searchContacts(component, event, helper);
                    helper.logConsoleDebug('Refreshed Member List ', 'log');
                } else if ( (eventName == 'openMessageDetails') && (eventSource == 'ChatBotContainer') && (componentUniqueName == groupName) ) {
                    var memberslisttabElement;
                    if (isIsolatedComponent) {
                        memberslisttabElement = document.querySelector("." + componentUniqueName + ".memberslisttab");
                    } else {
                        memberslisttabElement = document.querySelector("."+componentUniqueName + " .memberslisttab");
                    }

                    if(memberslisttabElement){
                        memberslisttabElement.classList.remove("activetab");
                    }
                    helper.logConsoleDebug('Selected a Member form Member List ', 'log');
                    if (isLoading == true) {
                        component.set('v.isLoading', false);
                    }
                } else if ( (eventName == 'hideChatBot') && (eventSource == 'ChatBotMemberConversation') && (componentUniqueName == groupName) ){
                    if (isLoading == true) {
                        component.set('v.isLoading', true);
                    }

                    var memberslisttabElementForHide;
                    if (isIsolatedComponent) {
                        memberslisttabElementForHide = document.querySelector("." + componentUniqueName + ".memberslisttab");
                    } else {
                        memberslisttabElementForHide = document.querySelector("."+componentUniqueName + " .memberslisttab");
                    }

                    if(memberslisttabElementForHide){
                        memberslisttabElementForHide.style.setProperty("display", "none", "important");
                    }

                    if (isLoading == true) {
                        component.set('v.isLoading', false);
                    }
                    
                } else if ( (eventName == 'showChatBot') && (eventSource == 'ChatBotMemberConversation') && (componentUniqueName == groupName) ){
                    if (isLoading == true) {
                        component.set('v.isLoading', true);
                    }

                    var memberslisttabElementForShow;
                    if (isIsolatedComponent) {
                        memberslisttabElementForShow = document.querySelector("." + componentUniqueName + ".memberslisttab");
                    } else {
                        memberslisttabElementForShow = document.querySelector("."+componentUniqueName + " .memberslisttab");
                    }

                    if(memberslisttabElementForShow){
                        memberslisttabElementForShow.style.removeProperty("display");
                    }

                    if (isLoading == true) {
                        component.set('v.isLoading', false);
                    }
                    
                } else {
                    if (isLoading == true) {
                        component.set('v.isLoading', false);
                    }
                }
            } else {
                if (isLoading == true) {
                    component.set('v.isLoading', false);
                }
            }
        } else {
            if (isLoading == true) {
                component.set('v.isLoading', false);
            }
        }
        helper.logConsoleDebug('ChatBotMembers Message Received message ' + message, 'log');
        helper.logConsoleDebug('ChatBotMembers Message Received eventMessage ' + eventMessage, 'log');
        helper.logConsoleDebug('ChatBotMembers Message Received isLoading ' + isLoading, 'log');
    },

    OpenMessageDetails: function (component, event, helper) {
        helper.logConsoleDebug(" Open messageDetails", 'log');
        // component.set("v.userInteraction", true);
        component.set('v.isLoading',true);
        var selectedItem = event.currentTarget;
        var selectedUUID = selectedItem.dataset.uuid;
        selectedUUID = helper.getBlankorNullForInvalidData(selectedUUID, true);
        var contactphonenumber = selectedItem.dataset.contactphonenumber;
        contactphonenumber = helper.getBlankorNullForInvalidData(contactphonenumber, true);
        var latestActivityNumber = selectedItem.dataset.latestactivitynumber;
        latestActivityNumber = helper.getBlankorNullForInvalidData(latestActivityNumber, true);
        var objectapiname = selectedItem.dataset.objectapiname;
        objectapiname = helper.getBlankorNullForInvalidData(objectapiname, true);
        var eventName = 'openMessageDetails';
        var eventSource = 'ChatBotMembers';
        var eventAction = 'MemberClick';
        var isIsolatedComponent = component.get('v.isIsolatedComponent');
        var groupName = component.get('v.componentUniqueName');  
        helper.logConsoleDebug('groupName ChatBotMembers ' + groupName, 'log');     
        helper.fireApplicationEventCallWithParams('componentCommunicationEvent' , { message : '', isLoading:true , eventMessage:'{"eventName":"' + eventName + '","eventSource":"' + eventSource + '","eventAction":"' + eventAction + '","groupName":"' + groupName + '","recordId":"' + selectedUUID + '","contactPhoneNumber":"' + contactphonenumber + '","objectapiname":"' + objectapiname + '","latestActivityNumber":"' + latestActivityNumber + '"}' } );
        component.set('v.SelectedLatestActivityNum', latestActivityNumber);
        component.set('v.SelectedObjectapiname', objectapiname);
        component.set('v.SelectedRecordId', selectedUUID); 
        component.set('v.SelectedContactPhone', contactphonenumber); 

        var memberslisttabElement;
        if (isIsolatedComponent) {
            memberslisttabElement = document.querySelector("." + groupName + ".memberslisttab");
        } else {
            memberslisttabElement = document.querySelector("."+groupName + " .memberslisttab");
        }

        if(memberslisttabElement){
            memberslisttabElement.classList.remove("activetab");
        }
        component.set('v.isLoading',false);
    },    

    onEnterText: function (component, event, helper) {
        var searchText = event.target.value;
        if( (searchText.length == 0) || (searchText.length > 1) ){
            component.set('v.searchText', searchText);
            component.set('v.SelectedLatestActivityNum', 0.0);
            component.set('v.SelectedRecordId', '');
            component.set('v.SelectedObjectapiname', '');
            var searchDelay = component.get('v.searchDelay');
            var searchDelayTimeout = component.get('v.searchDelayTimeout');
            helper.logConsoleDebug('searchText ' + searchText, 'log');
            helper.logConsoleDebug('searchDelay ' + searchDelay +'typeof ' + typeof searchDelay, 'log');
            window.clearTimeout(searchDelayTimeout);
            searchDelayTimeout = window.setTimeout(
                $A.getCallback(function () {
                    helper.searchContacts(component, event, helper);
                }), searchDelay
            ); 
            component.set('v.searchDelayTimeout', searchDelayTimeout);   
        }
    },

    handleDestroy: function (component, event, helper) {
        helper.logConsoleDebug('clear interval due to navigation', 'log');
        window.clearInterval(component.get("v.setIntervalId"));
        component.set("v.setIntervalId", "");
    },

})