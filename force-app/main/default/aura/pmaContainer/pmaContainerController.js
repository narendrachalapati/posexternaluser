({
    setup: function (component, event, helper) {
        console.info('Styles loaded successfully.');
    },
    onInit: function (component, event, helper) {
        var contactId = component.get('v.memberId');
       
        if(contactId !=null){
           component.set('v.currentMember', contactId);
        }
        console.log('ContainermemberId' + component.get('v.currentMember'));
        helper.GuestuserCheck(component);
        var logApiResponses = true;
        var productfromcontact = component.get('v.productData');
        console.log('productfromcontact' + productfromcontact);
        component.apiCall = function (controllerMethodName, params, success, failure) {
            var action = component.get('c.' + controllerMethodName);
            action.setParams(params);
            action.setCallback(this, function (data) {
                if (logApiResponses){
                    console.log( controllerMethodName +' Callback Response ErrorsList: ');
                    console.table(data.getError());
                } 
                var errors = data.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    if (failure) {
                        component.displayMessage('Error',  errors[0].message, 'error');
                        failure(errors[0].message);                        
                    } else {
                        if (logApiResponses) {
                            console.log( controllerMethodName +' Callback Response Error: ' );
                            console.table( errors);
                        }
                        component.displayMessage('Error',  controllerMethodName +' Callback Response Error: ', 'error');
                        component.set('v.Loading', false);
                    }
                } else {
                    if (logApiResponses){
                        console.log( controllerMethodName +' Callback Response Success: ');
                        console.table(data.getReturnValue());
                    } 
                    if (success) success(data.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        };
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

        component.isExternalAppsUser = function () {
            var currentUser = component.get('v.userInfo');
            console.table(currentUser);
            if( (currentUser != null) && (currentUser != undefined) && (currentUser != '') ){
                if( (currentUser.ContactId != null) && (currentUser.ContactId != undefined) && (currentUser.ContactId != '') ){
                    return true;
                }else{
                    return false;
                }
            }else{
                return false;
            }
        };

        component.redirectToHome = function (status,message) {
            var navigateLightning = component.find('navigate');
            var urlPath = '/'; //Invalid POS Member Open Tab
            if(message!=''){
                if(status==true){
                    component.displayMessage('Success', message, 'Success','dismissible');
                }else{
                    component.displayMessage('Failure', message, 'Error','dismissible');
                }
            }
            var currentuserrec = component.get("v.userInfo");
            console.log('currentuserrec ' + currentuserrec);
            if( ( (currentuserrec!= undefined) || (currentuserrec != null) ) && component.isExternalAppsUser() ){
                console.log('currentuserrec ' + currentuserrec.Contact.RecordType.Name);
                if( ( currentuserrec.Contact.RecordType.Name == 'Manager' ) ){
                    urlPath = '/search-members'; //Invalid POS Member Open Tab For Manager
                }
            }
            console.log('isExternalAppsUser ' + component.isExternalAppsUser());
            if(!component.isExternalAppsUser()){
                var pageReference = {
                    type: 'standard__navItemPage',
                    attributes: {
                        apiName: 'POS_Search'
                    }
                };
                navigateLightning.navigate(pageReference);
            }else{
                $A.get("e.force:navigateToURL").setParams({ 
                    "url": urlPath 
                 }).fire();  
            }
        };
        var orderUUID = component.get('v.orderUUID');
        const params = new URLSearchParams(location.search);
        if( (orderUUID == undefined) || (orderUUID == null) || (orderUUID =='') ){
         orderUUID = ( ( params.has('c__order') === true ) && ( params.get('c__order')!='' ) ) ? params.get('c__order') : '';
        }
        component.set('v.orderUUID',orderUUID);
        console.log('orderUUID ' + orderUUID);
        if(orderUUID ==''){
            component.redirectToHome(false, 'POS Invalid or Expired Order..');
        }

        var fetchUserAction = component.get("c.fetchCurrentUserWrapper");
        fetchUserAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
               // set current user and Contact information on userContactWrap attribute
                component.set("v.userContactWrap", storeResponse);
                // set current user information on userInfo attribute
                component.set("v.userInfo", storeResponse.userRecord);
            } else { // if any callback error, display error msg
            component.displayMessage('Error', 'An error occurred during Initialization ' + state, 'Error','dismissible');
           }
        });
        $A.enqueueAction(fetchUserAction);
        
        var action = component.get('c.getOrderDetailsByIdOrUUID');
        action.setParams({
            "orderIdOrUUID" : orderUUID,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('response.getReturnValue()');
               console.log(response.getReturnValue());
           if (state == "SUCCESS") {
               var orderRecord = response.getReturnValue();
               console.log('orderRecord '  + orderRecord);
               console.log('Member__c '  + orderRecord.Member__c);
               component.set('v.memberName' , orderRecord.Member__r.Name);            
               component.set('v.currentMember',orderRecord.Member__c); 
               component.set("v.showChild", true);
               var fetchActivitiesaction = component.get('c.fetchActionRecordRelatedActivities');
               fetchActivitiesaction.setParams({
                   "actionRecordId": orderRecord.Id,
               });
               fetchActivitiesaction.setCallback(this, function (response) {
                   var state = response.getState();
                   if (state == "SUCCESS") {
                       var orderRelatedActivities = response.getReturnValue();
                       console.log('orderRelatedActivities ' + orderRelatedActivities);
                       console.table(orderRelatedActivities);
                       component.set('v.orderRelatedActivities', orderRelatedActivities);
                   } else { // if any callback error, display error msg
                       console.log('Error in Fetiching Related Activities for POS Order..');
                   }

               });
               $A.enqueueAction(fetchActivitiesaction);
           } else { // if any callback error, display error msg
            component.redirectToHome(false, 'POS Invalid or Expired Order..');
           }
            
        });
        $A.enqueueAction(action);

    },
    handleComponentCommunicationEvent : function(cmp, event) {
        var message = event.getParam("message");
        var eventMessage = event.getParam("eventMessage");
        var isLoading = event.getParam("isLoading");
        console.log('Message Received message ' + message);
        console.log('Message Received eventMessage ' + eventMessage);
        console.log('Message Received isLoading ' + isLoading);
        // cmp.displayMessage('Alert', message, 'Alert','dismissible');
        cmp.set('v.isLoading',isLoading);
        cmp.set('v.message',message);
        console.log('Message Received in Container Component');
    },

    returnBacktoSearch : function (component, event) {
        component.redirectToHome(true, '');
    },

    toggleopenRelatedActivities : function (component, event) {
        var openRelatedActivities = component.get('v.openRelatedActivities');
        if(openRelatedActivities == true){
            component.set("v.openRelatedActivities" , false);
        }else{
            component.set("v.openRelatedActivities" , true);
        }
    },
    
})