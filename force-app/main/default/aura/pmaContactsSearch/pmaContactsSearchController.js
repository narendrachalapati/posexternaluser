({
    doInit: function (component, event, helper) {
        var logApiResponses = true;
        function initToaster() {
            toastr.options = {
                "closeButton": true,
                "newestOnTop": false,
                "progressBar": true,
                "positionClass": "toast-top-right",
                "preventDuplicates": true,
                "onclick": null,
                "showDuration": "300",
                "hideDuration": "1000",
                "timeOut": "5000",
                "extendedTimeOut": "1000",
                "showEasing": "swing",
                "hideEasing": "linear",
                "showMethod": "fadeIn",
                "hideMethod": "fadeOut"
            };
        }
         var memberid = component.get('v.memberId');
        var AccountId = component.get('v.AccountId');
        console.log('memberid' + memberid);
        component.displayMessage = function (title, message, type , mode ) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "mode": mode,
                "title": title,
                "type": type,
                "message": message
            });
            toastEvent.fire();
        };
        var fetchUserAction = component.get("c.fetchCurrentUser");
        fetchUserAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
               // set current user information on userInfo attribute
                component.set("v.currentUser", storeResponse);
                console.table(storeResponse);
            } else { // if any callback error, display error msg
            var errors = response.getError();
               if (errors) {
                   if (errors[0] && errors[0].message) {
                       component.displayMessage('Error', 'An error occurred during Initialization User ' + errors[0].message, 'Error', 'dismissible');
                   }
               } else {
                   component.displayMessage('Error', 'An error occurred during Initialization User : Unknown error', 'Error', 'dismissible');
               }
           }
        });
        $A.enqueueAction(fetchUserAction);
         // pos Guest user check
      
        if ( (memberid != null) && (AccountId != null) ) {
            component.set('v.isLoading',true);
            console.log('AccountId' + AccountId);
            var guestuserorderaction = component.get('c.GuestUsercreateDraftOrderRecord');
            guestuserorderaction.setParams({
                "memberId" :memberid ,
                "AccountId":AccountId
            });
            guestuserorderaction.setCallback(this, function (response) {
                var state = response.getState();
                console.log(' response.getReturnValue()');
                console.log(response.getReturnValue());
                if (state == "SUCCESS") {
                    var orderUUID = response.getReturnValue();
                    console.log('Init orderUUID');
                    console.log(orderUUID);
                    component.navigateToPOSOrderSelection(orderUUID); 
                    
                    component.set('v.isLoading',false);           
                } else { // if any callback error, display error msg
                    var errors = response.getError();
                    component.set('v.isLoading',false);
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            component.displayMessage('Error', 'An error occurred during order Creation ' + errors[0].message, 'Error', 'dismissible');
                        }
                    } else {
                        component.displayMessage('Error', 'An error occurred during order Creation : Unknown error', 'Error', 'dismissible');
                    }
                }
                
            });
            $A.enqueueAction(guestuserorderaction);
        }
       // End of check
        component.isExternalAppsUser = function () {
            var currentUser = component.get('v.currentUser');
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

        component.isMobile = function() {
            var a = navigator.userAgent||navigator.vendor||window.opera;
            return /(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4));
        };

        component.navigateToPOSOrderSelection = function ( orderUUID ) {
            console.log('navigateToPOSOrderSelection');
            console.log('isExternalAppsUser ' + component.isExternalAppsUser());
            var navigateLightning = component.find('navigate');
            if(component.isExternalAppsUser()){
                var pageReference = {
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: 'pos-selection'
                    },
                    state: {
                        c__order: orderUUID
                    } 
                };
                // navigateLightning.navigate(pageReference);
                console.log('externaluser');
            }else{
               
             
                    component.set('v.orderUUID' , orderUUID);
                    component.set('v.showPosContainer' , true);
                    // navigateLightning.navigate(pageReference);
                
                
            }
        };
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



        var subscriptioncatalog = component.get('c.subscriptioncatalog');
        subscriptioncatalog.setCallback(this, function (response) {
            var state = response.getState();
           if (state == "SUCCESS") {
               var allsubscriptioncatlog = response.getReturnValue();
                //For Aura attribute Iterate for UI
                component.set('v.subscriptioncatlog',allsubscriptioncatlog);
              
                 
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
        $A.enqueueAction(subscriptioncatalog);
      
        
        /*
        my change for product load
        */
        var productdata = component.get('c.initialproductsfetch');
        productdata.setCallback(this, function (response) {
            var state = response.getState();
           if (state === "SUCCESS") {
               var allProductsMap = response.getReturnValue();
               component.set('v.allProductsMap',allProductsMap);
               //For Aura attribute Iterate for UI
                var productObjectData = Object.values(allProductsMap);
                component.set('v.productData',productObjectData);
                console.log('allproductdata' + productObjectData);   
                 console.table(productObjectData);
                 component.set('v.productsfromcontactserch',true); 
                 console.log('productsfromcontactserch'+ component.get('v.productsfromcontactserch'));  
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
        $A.enqueueAction(productdata);  
    },
    onEnterText: function (component, event, helper) {
        var action = component.get('c.searchActiveMembers');
        component.set('v.searchText',event.target.value);
        action.setParams({
            keyword: component.get('v.searchText')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var searchResults = response.getReturnValue();
                 component.set('v.searchResult',searchResults);
                 console.table(searchResults);
                 console.log(searchResults);
                // get section Div element using aura:id
                if(component.find("searchResultSection")){
                    var sectionDiv = component.find("searchResultSection").getElement();
                    $A.util.addClass(sectionDiv, 'slds-is-open'); 
                }
               
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
        $A.enqueueAction(action);

    },
    // common reusable function for toggle sections
    toggleSection : function(component, event, helper) {
        // dynamically get aura:id name from 'data-auraId' attribute
        var sectionAuraId = event.target.getAttribute("data-auraId");
        // get section Div element using aura:id
        var sectionDiv = component.find(sectionAuraId).getElement();
        /* The search() method searches for 'slds-is-open' class, and returns the position of the match.
         * This method returns -1 if no match is found.
        */
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        $A.util.toggleClass(sectionDiv, 'slds-is-open');
    },
    openPOSOrderScreen : function(component, event, helper) {
        component.set('v.isLoading',true);
        var selectedItem = event.currentTarget;
        var selectedOrderUUID = selectedItem.dataset.orderuuid;
        component.navigateToPOSOrderSelection(selectedOrderUUID);
        component.set('v.isLoading',false);
    },
    CreateOrder : function(component, event, helper) {
        component.set('v.isLoading',true);
        var selectedItem = event.currentTarget;
        var selectedMemberId = selectedItem.dataset.memberid;
        var action = component.get('c.createDraftOrderRecord');
        action.setParams({
            "memberId" : selectedMemberId,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log(' response.getReturnValue()');
               console.log(response.getReturnValue());
           if (state == "SUCCESS") {
               var orderUUID = response.getReturnValue();
               console.log('Init orderUUID');
               console.log(orderUUID);
               component.navigateToPOSOrderSelection(orderUUID.UUID__c); 

               component.set('v.isLoading',false);           
           } else { // if any callback error, display error msg
               var errors = response.getError();
               component.set('v.isLoading',false);
               if (errors) {
                   if (errors[0] && errors[0].message) {
                       component.displayMessage('Error', 'An error occurred during order Creation ' + errors[0].message, 'Error', 'dismissible');
                   }
               } else {
                   component.displayMessage('Error', 'An error occurred during order Creation : Unknown error', 'Error', 'dismissible');
               }
           }
            
        });
        $A.enqueueAction(action);
       
    },

    handleproductevents : function(component, event, helper) {
    var message = event.getParam("message");
    var showchild = event.getParam("showchild");
    var showparent = event.getParam("showparent");
    console.log('Message Received message ' + message);
    console.log('Message Received eventMessage ' + showparent);
    console.log('Message Received isLoading ' + showchild);
    component.set('v.showPosContainer',showchild);
   helper.getallopentabs(component)
    
    }
});