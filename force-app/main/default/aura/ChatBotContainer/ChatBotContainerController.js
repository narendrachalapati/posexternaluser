({
    doinit: function (component, event, helper) {

        if (!component.get('v.componentUniqueName')) {
            component.set('v.componentUniqueName', 'inb'+helper.uuid4());
            helper.logConsoleDebug('componentUniqueName ChatBotContainer ' + component.get('v.componentUniqueName'), 'log');
        }

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
            } else { // if any callback error, display error msg
                helper.logConsoleDebug('Error in Retriving CurrentUserWrapper', 'log');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.logConsoleDebug('Failed to Retrive CurrentUserWrapper : ' + errors[0].message, 'log');
                    }
                }
           }
        });
        $A.enqueueAction(fetchUserAction);

        if( component.get('v.onUtilityBar') ) {
            var utilityBarAPI = component.find("utilitybar");
            // var myUtilityLabel = '';
            var newMessageCount = 0, messageCountPrev=0;
            utilityBarAPI.getAllUtilityInfo().then(function(response) {
                var myUtilityInfo = response[0];
                helper.logConsoleDebug('getUtilityInfo ChatBotContainer ', 'log');
                helper.logConsoleDebug(JSON.stringify(myUtilityInfo), 'table');
                // myUtilityLabel = myUtilityInfo.utilityLabel;
                helper.logConsoleDebug('utility label ' + component.get('v.myUtilityLabel'), 'log');
                
                if(myUtilityInfo.panelWidth) {
                    helper.logConsoleDebug('In Utility ChatBotContainer ', 'log');
                    // component.set('v.onUtilityBar', true);
                    component.set('v.utilityWidth', myUtilityInfo.panelWidth);
                    component.set('v.utilityHeight', myUtilityInfo.panelHeight);
                    helper.logConsoleDebug('test ChatBotContainer onUtilityBar ' + component.get('v.onUtilityBar'), 'log');
                    helper.logConsoleDebug('test ChatBotContainer utilityWidth ' + component.get('v.utilityWidth'), 'log');
                    helper.logConsoleDebug('test ChatBotContainer utilityHeight ' + component.get('v.utilityHeight'), 'log');
                }
            });
        }

        component.setUtilityLabel = function(platformEvent) {
            try {
                if(!component.get('v.onUtilityBar')) {
                    return;
                }
                var utilityBarAPI = component.find("utilitybar");
    
                let notification_count = 0;
                let notifyFor = [];
    
                let notified = component.get('v.notifiedActivity');
    
                helper.logConsoleDebug('criteria check '+JSON.stringify(platformEvent) + platformEvent.ActivityId__c + notified[platformEvent.ActivityId__c] 
                + platformEvent.Direction__c + platformEvent.Status__c  , 'log');
    
                if( platformEvent && platformEvent.ActivityId__c && !notified[platformEvent.ActivityId__c] 
                    && platformEvent.Direction__c == 'INBOUND' && platformEvent.Status__c == 'Delivered') {
                        console.log('platform event inside', JSON.stringify(platformEvent, null, 2));
                    
                    let notify = {};
                    notify.tagId = platformEvent.ActivityId__c ? platformEvent.ActivityId__c : '';
                    notify.message = platformEvent.Message__c ? platformEvent.Message__c : '';
                    notify.name = platformEvent.Member_Name__c ? platformEvent.Member_Name__c : '';
                    notify.contactId = platformEvent.WhatId__c ? platformEvent.WhatId__c : '';
                    notify.userNotified = false;
                    notifyFor.push(notify);
    
                    helper.beep(component);
                    utilityBarAPI.getUtilityInfo().then(function(response) {
                        if (!response.utilityVisible) {
                            utilityBarAPI.openUtility();
                        }
                    }).catch(function(error) {
                        helper.logConsoleDebug('Exception on getUtilityInfo ' + error, 'log');
                    }); 

                    utilityBarAPI.setUtilityHighlighted({
                        highlighted: true
                    });
    
                    window.setTimeout(
                        $A.getCallback(function() {
                            utilityBarAPI.setUtilityHighlighted({
                                highlighted: false
                            });
                        }), 5000);
    
                }
                
                // component.get('v.activitywrapper').forEach(i=>{
                //     let notified = component.get('v.notifiedActivity');
    
                //     console.log('wrapper',i.newMessagesCount, i, !notified[(i && i.activity && i.activity.Id) ? i.activity.Id : '']);
                //     if(i.newMessagesCount > 0 && !notified[i.activity.Id]) {
                //         let notify = {};
                //         notify.tagId = (i && i.activity && i.activity.Id) ? i.activity.Id : '';
                //         notify.message = (i && i.newMessage)? i.newMessage : '';
                //         notify.name = (i && i.cont && i.cont.Name)? i.cont.Name : '';
                //         notify.contactId = (i && i.contactid) ? i.contactid : '';
                //         notify.userNotified = false;
                //         notifyFor.push(notify);
                //     }
                //     notification_count += i.newMessagesCount;
                // });
                console.log('notify json ', JSON.stringify(notifyFor, null, 2));
                component.set('v.browserNotification', notifyFor);
    
                // console.table(component.get('v.activitywrapper'));
                // console.log('wrapper',JSON.stringify(component.get('v.activitywrapper'), null, 2));
                console.log('SP count ',notification_count, messageCountPrev);
                
                utilityBarAPI.setUtilityLabel({
                    label: component.get('v.myUtilityLabel').concat(notification_count == 0 ? '' : notification_count > 99 ? ' (99+)' : ' ('+notification_count+')')
                });
                utilityBarAPI.setPanelHeaderLabel({
                    label: component.get('v.myUtilityLabel').concat(notification_count == 0 ? '' : notification_count > 99 ? ' (99+)' : ' ('+notification_count+')')
                });
                utilityBarAPI.setPanelHeaderIcon({
                    icon : 'chat',
                    options:{
                        iconVariant:"warning"
                    }
                });
                utilityBarAPI.setUtilityIcon({ icon : 'chat' } );
                //TODO check browser notification
                // helper.notifyUser(component);
    
                // if(notification_count > messageCountPrev) {
                //     helper.beep(component);
                //     helper.notifyUser(component);
                //     messageCountPrev = notification_count;
                // }
                // if(notification_count > newMessageCount) {
                //     utilityBarAPI.setUtilityHighlighted({
                //         highlighted: true
                //     });
                // } else if(notification_count < newMessageCount) {
                //     newMessageCount = notification_count;
                //     utilityBarAPI.setUtilityHighlighted({
                //         highlighted: false
                //     });
                // } else {
                //     utilityBarAPI.setUtilityHighlighted({
                //         highlighted: false
                //     });
                // }

            } catch(e) {
                helper.logConsoleDebug('Exception on setUtility ' + e, 'log');
            }
            
            
        };
        if( component.get('v.onUtilityBar') ) {
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
                    helper.logConsoleDebug('Received payloadmessage container component: ' + JSON.stringify(payloadmessage), 'log');
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
                    if(payloadmessage) {
                        var fetchRecordId = component.get('v.selectedRecordId');
                        fetchRecordId = helper.getBlankorNullForInvalidData(fetchRecordId, true);
                        var fetchContactPhoneNumber = component.get('v.selectedContactPhone');
                        fetchContactPhoneNumber = helper.getBlankorNullForInvalidData(fetchContactPhoneNumber, true);

                        var whattId = payloadmessage.WhatId__c;
                        whattId = helper.getBlankorNullForInvalidData(whattId, true);
                        var activityPhone = payloadmessage.Formatted_Phone__c;
                        activityPhone = helper.getBlankorNullForInvalidData(activityPhone, true);

                        component.set('v.selectedRecordId', whattId);
                        component.set('v.selectedContactPhone', activityPhone);
                        if( !( ((fetchRecordId != '') || (fetchContactPhoneNumber != '')) && ((fetchRecordId == whattId) || (fetchContactPhoneNumber == activityPhone)) ) ){//Conversation is Not active
                            var groupName = component.get('v.componentUniqueName');
                            var eventName = 'openMessageDetails';
                            var eventSource = 'ChatBotContainer';
                            var eventAction = 'UtilityMemberClick';
                            helper.fireApplicationEventCallWithParams('componentCommunicationEvent', {
                                message: '',
                                isLoading: true,
                                eventMessage: '{"eventName":"' + eventName + '","eventSource":"' + eventSource + '","groupName":"' + groupName + '","eventAction":"' + eventAction + '","recordId":"' + payloadmessage.WhatId__c + '","contactPhoneNumber":"' + payloadmessage.Formatted_Phone__c + '","objectapiname":"","latestActivityNumber":"0"}'
                            });
                        }

                        window.setTimeout(
                            $A.getCallback(function () {
                                component.setUtilityLabel(payloadmessage);
                            }), 2000
                        );                    
                    }
                    
                    helper.logConsoleDebug('unique val '+component.get('v.componentUniqueName'), 'log');
                    
                    
                })).then(subscription => {
                    // Confirm that we have subscribed to the event channel.
                    // We haven't received an event yet.
                    // Subscription response received.
                    helper.logConsoleDebug('Subscribed to channel '+ subscription.channel, 'log');
                    
                });

                // Register error listener and pass in the error handler function
                empApi.onError($A.getCallback(error => {
                    // Error can be any type of error (subscribe, unsubscribe...)
                    helper.logConsoleDebug('EMP API error: '+ JSON.stringify(error), 'log');
                }));
            }catch(e){
                helper.logConsoleDebug('Exception on Platform event ' + e, 'log');
            }
        }
        
        component.set('v.showChild', true);

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
    },
})