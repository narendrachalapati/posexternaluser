({
   setup: function (component, event, helper) {
      console.info('bootstrap loaded successfully.');
   },

   onInit: function (component, event, helper) {
      var contactId = component.get('v.memberId');
      console.log('CartmemberId' + contactId);
        if(contactId !=null){
         component.set('v.contactRecordId', contactId);
      }
      
      console.log('CartmemberId' + component.get('v.contactRecordId'));
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
    var logApiResponses = true;
      component.set('v.SelectedPaymentSource','');
      try {
         var bodyStyles = document.body.style;
         var screenHeight = window.screen.height;
         var gridSizeMaxHeight = screenHeight - 370;
         gridSizeMaxHeight = gridSizeMaxHeight - (gridSizeMaxHeight % 205);
         bodyStyles.setProperty('--scroll-height', screenHeight + 'px');
         bodyStyles.setProperty('--scroll-height-gridsize', gridSizeMaxHeight + 'px');
      } catch (ex) {
         console.log('Exception ' + ex);
         console.table(ex);
      }

      component.set('v.isLoading', true);

      component.redirectToHome = function (status, message) {
        try{
         console.log('isExternalAppsUser ' + component.isExternalAppsUser());
         var activityRecordid = component.get('v.activityRecordid');
         console.log('activityRecordidNDR' + activityRecordid);
         var navigateLightning = component.find('navigate');
         var urlPath = '/'; //Invalid POS Member Open Tab
         if (message != '') {
            if (status == true) {
           //    component.displayMessage('Success', message, 'Success', 'dismissible');
            } else {
          //     component.displayMessage('Failure', message, 'Error', 'dismissible');
            }
         }

         var currentuserrec = component.get("v.userInfo");
         console.log('currentuserrec ');
         console.table(currentuserrec);
         if (((currentuserrec != undefined) || (currentuserrec != null)) && component.isExternalAppsUser()) {
            console.log('currentuserrec currentuserrec.Contact.RecordType.Name ');
            console.log('currentuserrec ' + currentuserrec.Contact.RecordType.Name);
            if ((currentuserrec.Contact.RecordType.Name == 'Manager')) {
               urlPath = '/search-members'; //Invalid POS Member Open Tab For Manager
            }
         }

         if ((activityRecordid != null) && (activityRecordid != undefined) && (activityRecordid != '')) {
            component.fireApplicationEventCall('componentCommunicationEvent', {
               message: '',
               isLoading: false,
               eventMessage: 'CloseInboxPopup'
            });
         } else {
            if (!component.isExternalAppsUser()) {
               component.set('v.showCartComponent', false);    
               component.set('v.isAddTipPopupOpen', false); 
               component.set('v.isLoading', false);  

               component.fireApplicationEventCall('componentCommunicationEvent', {
                  message: 'sucessfully charged',
                  isLoading: false,
                  eventMessage: ''
               });
               component.set('v.Paymentsucess', true); 
               /*var pageReference = {
                  type: 'standard__navItemPage',
                  attributes: {
                     apiName: 'POS_Search'
                  }
               };
               navigateLightning.navigate(pageReference);

            } else {
               $A.get("e.force:navigateToURL").setParams({
                  "url": urlPath
               }).fire();*/
            }
         }

        }catch(error){
           console.log('error' + error.stackTrace);
          }
      };

      component.fireApplicationEventCall = function (eventControllerName, params) {
         var appEvent = $A.get('e.c:' + eventControllerName);
         appEvent.setParams(params);
         if (logApiResponses) {
            console.log('*** ' + 'Sending messagedata' + ' *** ' + params);
         }
         if (logApiResponses) {
            console.log('*** ' + 'Sending application event' + ' *** ' + eventControllerName);
         }
         appEvent.fire();
         if (logApiResponses) {
            console.log('*** ' + 'Sent application event successfully' + ' *** ' + eventControllerName);
         }
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

      component.isTipAdded = function () {
         var curOrderItems = component.get('v.orderItemRecord');
         var hasTipItem = curOrderItems.some(function (oritem) {
            return (oritem.Product_Name__c === 'Tip');
         });
         return hasTipItem;
      };

      component.isExternalAppsUser = function () {
         var currentUser = component.get('v.userInfo');
         console.table(currentUser);
         if ((currentUser != null) && (currentUser != undefined) && (currentUser != '')) {
            if ((currentUser.ContactId != null) && (currentUser.ContactId != undefined) && (currentUser.ContactId != '')) {
               return true;
            } else {
               return false;
            }
         } else {
            return false;
         }
      };

      component.sendOutboundSMS = function (messageSubject, messageText) {
         console.log('sendOutboundSMS Called');
         component.set('v.isLoading', true);
         console.log('messageText ' + messageText);
         var orderRecord = component.get('v.orderRecord');
         var selectedcontactid = orderRecord.Member__c;
         var createActivityAction = component.get('c.createActivity');
         createActivityAction.setParams({
            'messageBody': messageText,
            'messageSubject': messageSubject,
            'recordId': selectedcontactid
         });
         createActivityAction.setCallback(this, function (response) {
            var state = response.getState(); // getting the state
            if (state === "SUCCESS") {
               console.log('SUCCESSFULLY Created SMS activity Creation');
               var activityrecordId = response.getReturnValue();
               if ((activityrecordId != undefined) && (activityrecordId != null)) {
                  let SMSCalloutaction = component.get("c.calloutSynchronousOutbound");
                  SMSCalloutaction.setParams({
                     "recId": activityrecordId,
                     "objSetting": 'PlivoSMS',
                     "apexHandler": 'Plivo_Outbound_SYS_ApplicationService',
                     "direction": 'OUT',
                     "accountMergeField": 'Account__c'
                  });

                  SMSCalloutaction.setCallback(this, function (response) {
                     let state = response.getState();
                     console.log('SMS Callback ' + state);
                     if (state === 'SUCCESS') {
                        var sysLogStatus = response.getReturnValue();
                        console.log('Apex response:', sysLogStatus);
                        if (sysLogStatus.toUpperCase() == 'DONE') {
                           console.log('SMS Successfully Sent ');
                           component.displayMessage('Success!', 'Card Update Request Successfully Sent', 'success', 'dismissible');
                           component.set('v.isLoading', false);
                        } else {
                           component.displayMessage('Failure!', 'Failed to Send Card Update Request. Status: ' + sysLogStatus, 'error', 'dismissible');
                           component.set('v.isLoading', false);

                        }

                     } else if (state === "ERROR") {
                        var errors = response.getError();
                        component.set('v.isLoading', false);
                        if (errors) {
                           if (errors[0] && errors[0].message) {
                              component.displayMessage('Failure!', 'Failed to Send Card Update Request. Status: ' + errors[0].message, 'error', 'dismissible');
                           }
                        } else {
                           component.displayMessage('Failure!', 'Failed to Send Card Update Request. Status: Unknown error', 'error', 'dismissible');
                        }

                     }
                  });

                  $A.enqueueAction(SMSCalloutaction);
               }

            } else {
               // Failure
               console.log('Error in Creation of Card Update Request SMS Activity ');
               component.set('v.isLoading', false);
               var errors = response.getError();
               if (errors) {
                  if (errors[0] && errors[0].message) {
                     component.displayMessage('Failure!', 'Failed to Create Card Update Request SMS : ' + errors[0].message, 'error', 'dismissible');
                  }
               }
            }
         });
         $A.enqueueAction(createActivityAction);

      };

      component.openChargeRetryModal = function (modalErrorMesage) {
         component.fireApplicationEventCall('componentCommunicationEvent', {
            message: '',
            isLoading: false,
            eventMessage: 'hideproducts'
         });
         component.set('v.showCartComponent', false);
         // Set isChargeRetryPopupOpen attribute to true
         component.set("v.isChargeRetryPopupOpen", true);
         var currentOrderRecord = component.get('v.orderRecord');
         var orderId = currentOrderRecord.Id;
         var contactId = currentOrderRecord.Member__c;
         var PaymentAmount = currentOrderRecord.Total_Price__c;
         component.set('v.OrderrecordId', orderId);
         component.set('v.contactRecordId', contactId);
         component.set('v.PaymentAmount', PaymentAmount);
         component.set('v.isFailedTransaction', true);
         
         modalErrorMesage = (modalErrorMesage == '') ? 'Failed to Charge for Order ' : modalErrorMesage;
         component.set('v.initStatus', modalErrorMesage);
         console.log('orderId ' + orderId);
         console.log('contactId ' + contactId);
         console.log('PaymentAmount ' + PaymentAmount);
      };

      component.calculateAndSetTipByPercent = function () {
         var walletAmount = component.get('v.orderRecord.Member__r.Balance__c');
         walletAmount = (helper.IsValidNumber(walletAmount))? parseFloat(walletAmount): 0.00;
         var selectedTipPercent = component.get('v.selectedTipPercent');
         var currentOrderRecord = component.get('v.orderRecord');
         var tempOrderTotal, tempTipAmount, tempTotal = 0.0;
         if ((currentOrderRecord != null) && (currentOrderRecord != undefined)) {
            tempOrderTotal = currentOrderRecord.Total_Price__c;
         }
         tempTipAmount = +(Math.round(tempOrderTotal * selectedTipPercent * 0.01 + "e+2") + "e-2");
         tempTotal = +(Math.round(tempOrderTotal + tempTipAmount + "e+2") + "e-2");
         component.set('v.TipAmount', tempTipAmount);
         component.set('v.TotalAmount', tempTotal);
         var walletdeduction = 0.0;
         var Bankdeduction = 0.0;
         var remainwalletTotal = 0.0;
        if (walletAmount > tempTotal) {
           remainwalletTotal = +(Math.round(walletAmount - tempTotal + "e+2") + "e-2");
           walletdeduction = tempTotal;
        } else { 
           walletdeduction = walletAmount;
        }
        if (tempTotal > walletdeduction) {
           Bankdeduction = +(Math.round(tempTotal - walletdeduction + "e+2") + "e-2");
        } 
        
        component.set('v.BankDeduction', Bankdeduction);
        component.set('v.WalletDeduction', walletdeduction);
          
      };

      component.calculateAndSetTipAmount = function () {
         var walletAmount = component.get('v.orderRecord.Member__r.Balance__c');
         walletAmount = (helper.IsValidNumber(walletAmount))? parseFloat(walletAmount): 0.00;
         var TipAmount = component.get('v.TipAmount');
         TipAmount = parseFloat(TipAmount);
         TipAmount = isNaN(TipAmount) ? 0 : TipAmount;
         var currentOrderRecord = component.get('v.orderRecord');
         var tempOrderTotal, tempTipPercent, tempTotal = 0.0;
         if ((currentOrderRecord != null) && (currentOrderRecord != undefined)) {
            tempOrderTotal = currentOrderRecord.Total_Price__c;
         }
         tempTotal = +(Math.round(tempOrderTotal + TipAmount + "e+2") + "e-2");
         tempTipPercent = parseFloat((TipAmount / tempOrderTotal) * 100).toFixed(2);
         component.set('v.TotalAmount', tempTotal);
         component.set('v.selectedTipPercent', tempTipPercent);
         var walletdeduction = 0.0;
         var Bankdeduction = 0.0;
         var remainwalletTotal = 0.0;
        if (walletAmount > tempTotal) {
           remainwalletTotal = +(Math.round(walletAmount - tempTotal + "e+2") + "e-2");
           walletdeduction = tempTotal;
        } else { 
           walletdeduction = walletAmount;
        }
        if (tempTotal > walletdeduction) {
           Bankdeduction = +(Math.round(tempTotal - walletdeduction + "e+2") + "e-2");
        } 
         
         component.set('v.WalletDeduction', walletdeduction);
         component.set('v.BankDeduction', Bankdeduction);
      };

      component.handleComplimentaryCharge = function () {
         console.log('*** ' + 'handleComplimentaryCharge' + ' ***');
         component.fireApplicationEventCall('componentCommunicationEvent', {
            message: 'Closing Tab Please Wait...',
            isLoading: true,
            eventMessage: ''
         });
         var selectedItem = document.querySelector('.cartclosetabbutton');
         selectedItem.disabled = true;
         selectedItem.innerHTML = '<i class="fa fa-credit-card fa-flip" aria-hidden="true"></i> Please Wait Closing Tab';
         TotalbillableAmountAfterCommit
         var TotalbillableAmountAfterCommit = component.get('v.TotalbillableAmountAfterCommit');
         var TipAmount = component.get('v.TipAmount');
         var orderAmount = component.get('v.TotalbillableAmountbeforecommit');

        //  if (TipAmount != 0 || TipAmount != 0.0) {
        //     orderAmount = orderAmount + TipAmount
        //  }
         var currentOrderRecord = component.get('v.orderRecord');
         
         var createintentaction = component.get('c.createPaymentFromOrder');
         createintentaction.setParams({
            "orderId": currentOrderRecord.Id,
            "paymentAmount": orderAmount
         });
         createintentaction.setCallback(this, function (response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
               var createdPaymentIntentList = response.getReturnValue();
               var paymentrequest = createdPaymentIntentList[0];
               var processPaymentaction = component.get('c.processComplimentaryPayment');
               processPaymentaction.setParams({
                  paymentRequest: paymentrequest,
                  currentOrderRecord:currentOrderRecord
               });
               processPaymentaction.setCallback(this, function (response) {
                  var state = response.getState();
                  if (state == 'SUCCESS') {
                     var chargeResponse = response.getReturnValue();
                     component.fireApplicationEventCall('componentCommunicationEvent', {
                        message: '',
                        isLoading: false,
                        eventMessage: ''
                     });
                     selectedItem.disabled = false;
                     selectedItem.innerHTML = '<i class="fa fa-credit-card" aria-hidden="true"></i> Close Tab';
                     var walletAmount = component.get('v.orderRecord.Member__r.Balance__c');
                     walletAmount = (helper.IsValidNumber(walletAmount))? parseFloat(walletAmount): 0.00;
                     var currentOrderRecord = component.get('v.orderRecord');
                     var allowComplimentaryOrders = currentOrderRecord.Member__r.AllowComplimentaryOrders__c;
                     if(walletAmount> 0 && allowComplimentaryOrders==false){
                       component.redirectToHome(true, 'Successfully Charged');
                     }else{
                       component.redirectToHome(true, 'Successfully Charged Complimentary Order..');
                     }
                   
                  } else {
                     component.fireApplicationEventCall('componentCommunicationEvent', {
                        message: '',
                        isLoading: false,
                        eventMessage: ''
                     });
                     selectedItem.disabled = false;
                     selectedItem.innerHTML = '<i class="fa fa-credit-card" aria-hidden="true"></i> Close Tab';
                     var errors = response.getError();
                     if (errors) {
                        if (errors[0] && errors[0].message) {
                           component.displayMessage('Failure!', 'Failed to Complimentary Order : ' + errors[0].message, 'error', 'dismissible');
                        }
                     } else {
                        component.displayMessage('Failure!', 'Failed to Complimentary Order : Unknown error', 'error', 'dismissible');
                     }

                  }
               });
               $A.enqueueAction(processPaymentaction);
            } else {
               component.fireApplicationEventCall('componentCommunicationEvent', {
                  message: '',
                  isLoading: false,
                  eventMessage: ''
               });
               selectedItem.disabled = false;
               selectedItem.innerHTML = '<i class="fa fa-credit-card" aria-hidden="true"></i> Close Tab';
               var errors = response.getError();
               if (errors) {
                  if (errors[0] && errors[0].message) {
                     component.displayMessage('Failure!', 'Failed to Create Payment From Order : ' + errors[0].message, 'error', 'dismissible');
                  }
               } else {
                  component.displayMessage('Failure!', 'Failed to Create Payment From Order : Unknown error', 'error', 'dismissible');
               }

            }
         });
         $A.enqueueAction(createintentaction);
      };


      component.handleCharge = function () {
       
 
          try{
         console.log('*** ' + 'handleCharge' + ' ***');
         var selectedItem = document.querySelector('.cartclosetabbutton');
         selectedItem.disabled = true;
         selectedItem.innerHTML = '<i class="fa fa-credit-card fa-flip" aria-hidden="true"></i> Please Wait Closing Tab';

         component.fireApplicationEventCall('componentCommunicationEvent', {
            message: 'Closing Tab Please Wait...',
            isLoading: true,
            eventMessage: ''
         });
         //var selectedpaymentsource = component.get('v.selectedpaymentsource');
         var currentOrderRecord = component.get('v.orderRecord');
         var defaultPaymentSource = component.get('v.SelectedPaymentSource'); 
         if(defaultPaymentSource == null || defaultPaymentSource == undefined || defaultPaymentSource == 'undefined'){
           defaultPaymentSource = currentOrderRecord.Member__r.Default_Payment_Method__c;
         }
         console.log('defaultPaymentSource NDR:: ' + defaultPaymentSource);
         var Walletmoney = component.get('v.orderRecord.Member__r.Balance__c');
         Walletmoney = (helper.IsValidNumber(Walletmoney))?parseFloat(Walletmoney): 0.00;
            
         var orderAmount = currentOrderRecord.Total_Price__c;
         
         console.log('orderAmountNDR+' + orderAmount);
         var TipAmount = component.get('v.TipAmount');
     //  if (TipAmount != 0 || TipAmount != 0.0) {
     //      orderAmount = orderAmount + TipAmount
     //     }
         console.log('orderAmountNDRAfterTip+' + orderAmount);
         if(Walletmoney>0){
           var orderAmountSUB = currentOrderRecord.Total_Price__c;
           orderAmount = orderAmountSUB - Walletmoney;
           console.log('orderAmountsubwallet'+orderAmount);
         }
        
         if ((defaultPaymentSource == null) || (defaultPaymentSource == undefined)  || (defaultPaymentSource == 'undefined')) {
            component.fireApplicationEventCall('componentCommunicationEvent', {
               message: '',
               isLoading: false,
               eventMessage: ''
            });
          //  component.displayMessage('Failure!', 'Failed to Charge for Order : No Default Source Found on Contact', 'error', 'dismissible');
            selectedItem.disabled = false;
            selectedItem.innerHTML = '<i class="fa fa-credit-card" aria-hidden="true"></i> Close Tab';
            component.openChargeRetryModal('Default Payment Method not Found');
            return;
         }else{
            var stripePaymentRequest = {
               'paymentMethod': 'card',
               'selectedPaymentSource': defaultPaymentSource
            };
         
         var createintentaction = component.get('c.createPaymentFromOrder');
         createintentaction.setParams({
            "orderId": currentOrderRecord.Id,
            "paymentAmount": orderAmount
         });
         createintentaction.setCallback(this, function (response) {
            var state = response.getState();
            var currentOrderRecord = component.get('v.orderRecord');
            if (state == 'SUCCESS') {
               var createdPaymentIntentList = response.getReturnValue();
               var processPaymentaction = component.get('c.processPaymentsByDefaultSource');
               processPaymentaction.setParams({
                  paymentRequests: createdPaymentIntentList,
                  stripePaymentRequest: stripePaymentRequest
               });
               processPaymentaction.setCallback(this, function (response) {
                  var state = response.getState();
                  if (state == 'SUCCESS') {
                     var chargeResponse = response.getReturnValue();
                     var txnstatus, statusMessage, statusCode;
                     if (chargeResponse.type == 'TXN') {
                        statusMessage = ((chargeResponse.txn.Status__c != 'failed') ? 'Card Charged Successfully' : chargeResponse.txn.FailureMessage__c);
                        txnstatus = ((chargeResponse.txn.Status__c != 'failed') ? 'Success' : 'Failed');
                        statusCode = ((chargeResponse.txn.Status__c != 'failed') ? '' : chargeResponse.txn.FailureCode__c);
                     } else if (chargeResponse.type == 'OTHER') {
                        statusMessage = ((chargeResponse.paymentRequest.Status__c != 'payment_failed') ? 'Card Charged Successfully' : 'Failed to Charge Card: Unknown Error');
                        txnstatus = ((chargeResponse.paymentRequest.Status__c != 'payment_failed') ? 'Success' : 'Failed');
                        statusCode = ((chargeResponse.paymentRequest.Status__c != 'payment_failed') ? '' : 'Unknown');
                     }
                     if ((txnstatus != 'Failed') && (txnstatus != null) && (txnstatus != undefined)) {
                        //execute redirectToHome() again after 5 sec each
                        window.setTimeout(
                           $A.getCallback(function () {
                             //  component.fireApplicationEventCall('componentCommunicationEvent', {
                             //     message: '',
                             //     isLoading: true,
                             //     eventMessage: ''
                             // });
                             //  selectedItem.disabled = false;
                             //  selectedItem.innerHTML = '<i class="fa fa-credit-card" aria-hidden="true"></i> Close Tab';
                             //  component.redirectToHome(true, 'Successfully Charged Order..');
                           }), 5000
                        );
                        selectedItem.disabled = false;
                              selectedItem.innerHTML = '<i class="fa fa-credit-card" aria-hidden="true"></i> Close Tab';
                              component.redirectToHome(true, 'Successfully Charged Order..');
 
                     } else {
                        component.fireApplicationEventCall('componentCommunicationEvent', {
                           message: '',
                           isLoading: false,
                           eventMessage: ''
                        });
                        component.displayMessage('Failure!', 'Failed to Charge Order : ' + statusMessage + ' : ' + statusCode, 'error', 'dismissible');
                        var messageSubject = 'Failed to Auto-Charge SMS to ' + currentOrderRecord.Member__r.Name;
                        var smsFailedSmsText = 'Dear ' + currentOrderRecord.Member__r.Name + ' Oops! ' + statusMessage + ' Please Update Card using this link ' + currentOrderRecord.Member__r.Card_Update_Link__c;
                        component.sendOutboundSMS(messageSubject, smsFailedSmsText);
                        selectedItem.disabled = false;
                        selectedItem.innerHTML = '<i class="fa fa-credit-card" aria-hidden="true"></i> Close Tab';
                        component.fireApplicationEventCall('componentCommunicationEvent', {
                           message: '',
                           isLoading: false,
                           eventMessage: 'hideproducts'
                        });
                        component.set('v.showCartComponent', false);
                        component.set("v.isChargeRetryPopupOpen", true);
                        var orderId = currentOrderRecord.Id;
                        var contactId = currentOrderRecord.Member__c;
                        var PaymentAmount = currentOrderRecord.Total_Price__c;
                        component.set('v.OrderrecordId', orderId);
                        component.set('v.contactRecordId', contactId);
                        component.set('v.PaymentAmount', PaymentAmount);
                        component.set('v.isFailedTransaction', true);
                        component.set('v.initStatus', 'Failed to Charge for Order ' + statusMessage + ' : ' + statusCode);
                     }
                  } else {
                     component.fireApplicationEventCall('componentCommunicationEvent', {
                        message: '',
                        isLoading: false,
                        eventMessage: ''
                     });
                     selectedItem.disabled = false;
                     selectedItem.innerHTML = '<i class="fa fa-credit-card" aria-hidden="true"></i> Close Tab';
                     var errors = response.getError();
                     if (errors) {
                        if (errors[0] && errors[0].message) {
                           component.displayMessage('Failure!', 'Failed to Charge Order : ' + errors[0].message, 'error', 'dismissible');
                           var messageSubjectvar = 'Failed to Auto-Charge SMS to ' + currentOrderRecord.Member__r.Name;
                           var smsFailedSmsTextvar = 'Dear ' + currentOrderRecord.Member__r.Name + ' Oops! ' + errors[0].message + ' Please Update Card using this link ' + currentOrderRecord.Member__r.Card_Update_Link__c;
                           component.sendOutboundSMS(messageSubjectvar, smsFailedSmsTextvar);
                        }
                     } else {
                        component.displayMessage('Failure!', 'Failed to Charge Order : Unknown error', 'error', 'dismissible');
                        var smsmessageSubject = 'Failed to Auto-Charge SMS to ' + currentOrderRecord.Member__r.Name;
                        var smsFailedSmsTextUnkwn = 'Dear ' + currentOrderRecord.Member__r.Name + ' Oops! Failed to Charge Order : Unknown error. Please Update Card using this link ' + currentOrderRecord.Member__r.Card_Update_Link__c;
                        component.sendOutboundSMS(smsmessageSubject, smsFailedSmsTextUnkwn);
                     }

                  }
               });
               $A.enqueueAction(processPaymentaction);
            } else {
               component.fireApplicationEventCall('componentCommunicationEvent', {
                  message: '',
                  isLoading: false,
                  eventMessage: ''
               });
               selectedItem.disabled = false;
               selectedItem.innerHTML = '<i class="fa fa-credit-card" aria-hidden="true"></i> Close Tab';
               var errors = response.getError();
               if (errors) {
                  if (errors[0] && errors[0].message) {
                     component.displayMessage('Failure!', 'Failed to Create Payment From Order : ' + errors[0].message, 'error', 'dismissible');
                  }
               } else {
                  component.displayMessage('Failure!', 'Failed to Create Payment From Order : Unknown error', 'error', 'dismissible');
               }

            }
         });
         $A.enqueueAction(createintentaction);
      }
         }catch(e){
              console.log('Exception ' + e);
          }
      };
   
      var userContactWrap = component.get("v.userContactWrap");
      component.set("v.userInfo", userContactWrap.userRecord);
      var orderUUID = component.get("v.orderUUID");
      var action = component.get('c.getOrderDetails');
      action.setParams({
         "orderIdOrUUID": orderUUID,
      });
      action.setCallback(this, function (response) {
         var state = response.getState();
         if (state == 'SUCCESS') {
            var orderRecordData = response.getReturnValue();
            component.set('v.orderRecord', orderRecordData);
            console.log('orderRecord ' + orderRecordData);
          
           // var defaultPaymentSource = orderRecordData.Member__r.Default_Payment_Method__c;
           // component.set('v.SelectedPaymentSource', defaultPaymentSource);
          // console.log('defaultPaymentSource:::NDR' + defaultPaymentSource);
            
           component.set('v.orderItemRecord', orderRecordData.Order_Items__r);
            component.set('v.isLoading', false);
            console.log('Order_Items__r ' + orderRecordData.Order_Items__r);
            console.table(orderRecordData);

            var AccountRecordId = orderRecordData.Account__c;
            console.log('AccountRecordIdNDR'+AccountRecordId);
            var getIntegrationMetadataAction = component.get('c.getIntegrationMetadata');
            getIntegrationMetadataAction.setParams({
               "accountRecordId": AccountRecordId,
               "IntegrationType": "Stripe"
            });
            getIntegrationMetadataAction.setCallback(this, function (response) {
               var state = response.getState();
               console.log('integrationmetaSTATE'+state);
               if (state == 'SUCCESS') {
                  var IntegrationMetadata = response.getReturnValue();
                  component.set('v.IntegrationMetadata', IntegrationMetadata);
                  console.log('IntegrationMetadata ');
                  console.table(IntegrationMetadata);
                  console.log('NDR Memberid' + component.get('v.orderRecord.Member__c'));
                  var membercontactid = orderRecordData.Member__c;
                  helper.paymentcardfetch(component, membercontactid);
               } else {
                // const integrationmetadataMap: Record<string, string> = {};
                 // var  integrationmetadataMap = new Map();
                 // integrationmetadataMap.set('allowTip', 'true');
                 // integrationmetadataMap.set('int-set', 'Stripe');
                 // integrationmetadataMap.set('subscriptionPlans', 'Membership Fees,Family Add-on');
                 // component.set('v.IntegrationMetadata', integrationmetadataMap);
                 const integrationmetadataMap = new Map([
                    ["allowTip", "true"],
                    ["int-set", "Stripe"],
                    ["subscriptionPlans", "Membership Fees,Family Add-on"]
                  ]);
                 console.log('elsepartintegrationmetadata');
                 component.set('v.IntegrationMetadata', integrationmetadataMap);
                
                 console.table(integrationmetadataMap);
                 console.table( component.get('v.IntegrationMetadata'));
                 var membercontactid = orderRecordData.Member__c;
                 helper.paymentcardfetch(component, membercontactid);
                  console.log('Failed to get IntegrationMetadata Action ');
                  if(integrationmetadataMap.size===0){
                  var errors = response.getError();
                  if (errors) {
                     if (errors[0] && errors[0].message) {
                        component.displayMessage('Failure!', 'Failed to Fetch IntegrationMetadata: ' + errors[0].message, 'error', 'dismissible');
                     }
                  } else {
                     component.displayMessage('Failure!', 'Failed to Fetch IntegrationMetadata: Unknown error', 'error', 'dismissible');
                  }
                 }
               }
            });
            $A.enqueueAction(getIntegrationMetadataAction);

         } else {
            console.log('Failed  getOrderDetails action ');
            var errors = response.getError();
            component.set('v.isLoading', false);
            if (errors) {
               if (errors[0] && errors[0].message) {
                  component.displayMessage('Failure!', 'Failed to Fetch Order Details: ' + errors[0].message, 'error', 'dismissible');
               }
            } else {
               component.displayMessage('Failure!', 'Failed to Fetch Order Details: Unknown error', 'error', 'dismissible');
            }
         }
      });
      $A.enqueueAction(action);

   },

   handleProductSelectionEvent: function (cmp, event) {
      var logApiResponses = true;
      var orderUUID = cmp.get("v.orderUUID");
      var action = cmp.get('c.getOrderDetails');
      action.setParams({
         "orderIdOrUUID": orderUUID,
      });
      action.setCallback(this, function (response) {
         var state = response.getState();
         if (state == 'SUCCESS') {
            var orderRecordData = response.getReturnValue();
            cmp.set('v.orderRecord', orderRecordData);
            cmp.set('v.orderItemRecord', orderRecordData.Order_Items__r);
         } else {
            cmp.redirectToHome(false, 'POS Invalid or Expired Order..');
         }
      });
      $A.enqueueAction(action);

      var message = event.getParam("message");
      if (logApiResponses) {
         console.log('Received Message: ' + message);
      }
      //Received JSON String
      var selectedproductsString = event.getParam("selectedproducts");
      // set the handler attributes based on event data
      cmp.set("v.messageFromEvent", message);
      cmp.set("v.selectedproductsString", selectedproductsString);

      //1 Json String to JSON Object Conversion
      let productObjectData = JSON.parse(selectedproductsString);
      console.log('ObjType:: ' + typeof productObjectData);
      console.table(productObjectData);

      // 2 JSON Object To Map Conversion
      let allSelectedProductsMap = new Map();
      for (var value in productObjectData) {
         allSelectedProductsMap.set(value, productObjectData[value]);
      }
      //Not able to Assign map to Aura Attribute 
      console.log('ObjType:: ' + typeof allSelectedProductsMap);
      console.table(productObjectData);
      //3 extract valuesfrom map to store in Aura attribute List
      var selectedProductsValues = new Array();
      var chargeAmount = 0;
      for (var value in productObjectData) {
         selectedProductsValues.push(productObjectData[value]);
         chargeAmount = chargeAmount + productObjectData[value].totalProductPrice;
      }
      if (logApiResponses) {
         console.log('Current chargeAmount: ' + chargeAmount);
      }
      cmp.set("v.totalChargeAmount", chargeAmount);
      cmp.set("v.selectedProductsValues", selectedProductsValues);


      if (logApiResponses) {
         console.log('Received Product Values List(Array): ');
      }
      if (logApiResponses) {
         console.table(selectedProductsValues);
      }
   },

   deleteOrderItemHandler: function (cmp, event) {
      var message = 'Product Deleted Successfully';
      var selectedItem = event.currentTarget;
      var selectedOrderId = selectedItem.dataset.id; // Selected Order Id
      var selectedOrderItemId = selectedItem.dataset.orderitemid; // Selected OrderItem Id

      var action = cmp.get('c.deleteOrderItem');
      action.setParams({
         "orderId": selectedOrderId,
         "orderItemId": selectedOrderItemId,
      });
      action.setCallback(this, function (response) {
         var state = response.getState();
         if (state == 'SUCCESS') {
            var orderRecordData = response.getReturnValue();
            cmp.set('v.orderRecord', orderRecordData);
            console.log('orderRecord ' + orderRecordData);

            cmp.set('v.orderItemRecord', orderRecordData.Order_Items__r);
            console.log('Order_Items__r ' + orderRecordData.Order_Items__r);
            console.table(orderRecordData);
            cmp.displayMessage('Success!', message, 'success', 'dismissible');
         } else {
            console.log('Failed  getOrderDetails action ');
            var errors = response.getError();
            var errormessage = 'Failed to Delete Order Item: Unknown error';
            if (errors) {
               console.table(errors[0]);
               if (errors[0] && errors[0].message) {
                  errormessage = 'Failed to Delete Order Item: ' + errors[0].message;
                  cmp.displayMessage('Failure!', errormessage, 'error', 'dismissible');
                  return;
               }
               if ((errors[0]) && (errors[0].pageErrors.length > 0)) {
                  errormessage = errors[0].pageErrors[0].message;
                  console.log(errors[0].pageErrors[0].message);
                  cmp.displayMessage('Failure!', errormessage, 'error', 'dismissible');
                  return;
               }
            } else {
               cmp.displayMessage('Failure!', errormessage, 'error', 'dismissible');
               return;
            }
            cmp.redirectToHome(false, 'POS Invalid or Expired Order..');
         }
      });
      $A.enqueueAction(action);

   },
   AllselectedproductDeleteHandler: function (cmp, event) {
     var logApiResponses = true;
     var message = 'Product Deleted Successfully';
     var selectedItem = event.currentTarget;
     var selectedProdId = selectedItem.dataset.id; // Selected Product Id
     var selectedproductsString = cmp.get("v.selectedproductsString");

     //1 Json String to JSON Object Conversion
     let productObjectData = JSON.parse(selectedproductsString);
     // 2 JSON Object To Map Conversion
     let allSelectedProductsMap = new Map();
     for (var value in productObjectData) {
        allSelectedProductsMap.set(value, productObjectData[value]);
     }
     //Not able to Assign map to Aura Attribute 

     //3 extract valuesfrom map to store in Aura attribute List
     var selectedProductsValues = new Array();
     for (var value in productObjectData) {
        selectedProductsValues.push(productObjectData[value]);
     }
     if (logApiResponses) {
        console.log('Current selectedProductsValues: ');
     }
     if (logApiResponses) {
        console.table(selectedProductsValues);
     }

     var currentSelectedProductFromDataMap = allSelectedProductsMap.get(selectedProdId);
     if (logApiResponses) {
        console.log('Current currentSelectedProductFromDataMap: ');
     }
     if (logApiResponses) {
        console.table(currentSelectedProductFromDataMap);
     }

     if (currentSelectedProductFromDataMap.quantity > 1) {
        var productQuantity = currentSelectedProductFromDataMap.quantity - 1;
        var singleProductPrice = currentSelectedProductFromDataMap.product.Option_Total_Price__c;
        var netUnitPrice = singleProductPrice * productQuantity;
        currentSelectedProductFromDataMap.quantity = productQuantity;
        currentSelectedProductFromDataMap.productPrice = singleProductPrice;
        currentSelectedProductFromDataMap.totalProductPrice = netUnitPrice;
        allSelectedProductsMap.set(selectedProdId, currentSelectedProductFromDataMap);
        allSelectedProductsMap.delete(selectedProdId);
     } else {
        allSelectedProductsMap.delete(selectedProdId);
     }
     var selectedProductsValues = [...allSelectedProductsMap.values()];
     if (logApiResponses) {
        console.table(selectedProductsValues);
     }
     console.log('selectedProductsValues ');
     console.log(selectedProductsValues);
     var preprocessMapToObject = Object.fromEntries(allSelectedProductsMap);
     var processedObjectToString = JSON.stringify(preprocessMapToObject);
     cmp.set('v.selectedproductsString', processedObjectToString);
     cmp.set("v.selectedProductsValues", selectedProductsValues);

     var chargeAmount = 0;
     for (let allSelectedProductsMapValue of allSelectedProductsMap.values()) {
        chargeAmount = chargeAmount + allSelectedProductsMapValue.totalProductPrice;
     }
     if (logApiResponses) {
        console.log('Current chargeAmount: ' + chargeAmount);
     }
     cmp.set("v.totalChargeAmount", chargeAmount);

     cmp.fireApplicationEventCall('cartCommunicationEvent', {
        message: message,
        selectedproducts: processedObjectToString
     });
     if (logApiResponses) {
        console.log('Called Cart Event Call: ');
     }

  },
   productDeleteHandler: function (cmp, event) {
      var logApiResponses = true;
      var message = 'Product Deleted Successfully';
      var selectedItem = event.currentTarget;
      var selectedProdId = selectedItem.dataset.id; // Selected Product Id
      var selectedproductsString = cmp.get("v.selectedproductsString");

      //1 Json String to JSON Object Conversion
      let productObjectData = JSON.parse(selectedproductsString);
      // 2 JSON Object To Map Conversion
      let allSelectedProductsMap = new Map();
      for (var value in productObjectData) {
         allSelectedProductsMap.set(value, productObjectData[value]);
      }
      //Not able to Assign map to Aura Attribute 

      //3 extract valuesfrom map to store in Aura attribute List
      var selectedProductsValues = new Array();
      for (var value in productObjectData) {
         selectedProductsValues.push(productObjectData[value]);
      }
      if (logApiResponses) {
         console.log('Current selectedProductsValues: ');
      }
      if (logApiResponses) {
         console.table(selectedProductsValues);
      }

      var currentSelectedProductFromDataMap = allSelectedProductsMap.get(selectedProdId);
      if (logApiResponses) {
         console.log('Current currentSelectedProductFromDataMap: ');
      }
      if (logApiResponses) {
         console.table(currentSelectedProductFromDataMap);
      }

      if (currentSelectedProductFromDataMap.quantity > 1) {
         var productQuantity = currentSelectedProductFromDataMap.quantity - 1;
         var singleProductPrice = currentSelectedProductFromDataMap.product.Option_Total_Price__c;
         var netUnitPrice = singleProductPrice * productQuantity;
         currentSelectedProductFromDataMap.quantity = productQuantity;
         currentSelectedProductFromDataMap.productPrice = singleProductPrice;
         currentSelectedProductFromDataMap.totalProductPrice = netUnitPrice;
         allSelectedProductsMap.set(selectedProdId, currentSelectedProductFromDataMap);
       
      } else {
         allSelectedProductsMap.delete(selectedProdId);
      }
      var selectedProductsValues = [...allSelectedProductsMap.values()];
      if (logApiResponses) {
         console.table(selectedProductsValues);
      }
      console.log('selectedProductsValues ');
      console.log(selectedProductsValues);
      var preprocessMapToObject = Object.fromEntries(allSelectedProductsMap);
      var processedObjectToString = JSON.stringify(preprocessMapToObject);
      cmp.set('v.selectedproductsString', processedObjectToString);
      cmp.set("v.selectedProductsValues", selectedProductsValues);

      var chargeAmount = 0;
      for (let allSelectedProductsMapValue of allSelectedProductsMap.values()) {
         chargeAmount = chargeAmount + allSelectedProductsMapValue.totalProductPrice;
      }
      if (logApiResponses) {
         console.log('Current chargeAmount: ' + chargeAmount);
      }
      cmp.set("v.totalChargeAmount", chargeAmount);

      cmp.fireApplicationEventCall('cartCommunicationEvent', {
         message: message,
         selectedproducts: processedObjectToString
      });
      if (logApiResponses) {
         console.log('Called Cart Event Call: ');
      }

   },

   handleFinialize: function (cmp, event, helper) {
     try{
      console.log('*** ' + 'handleFinialize' + ' ***');
      var selectedItem = event.currentTarget;
      selectedItem.disabled = true;
      selectedItem.innerHTML = '<i class="fa fa-shopping-cart fa-flip" aria-hidden="true"></i> Please Wait Adding Items to Tab';
      var orderedQuantity = 0;
      var currentOrderRecord = cmp.get('v.orderRecord');
      var currentOrderItems = currentOrderRecord.Order_Items__r;
      if(currentOrderItems != null){
        currentOrderItems.forEach(function (currentOrderItem) {
           orderedQuantity = orderedQuantity + currentOrderItem.Quantity__c;
        });
      }
     
      var currentSelectedProducts = cmp.get("v.selectedProductsValues");
      var orderedQuantity = 0;
      currentSelectedProducts.forEach(function (singleprodwrapper) {
         orderedQuantity = orderedQuantity + singleprodwrapper.quantity;
      });

      var selectedProductsValues = JSON.stringify(cmp.get("v.selectedProductsValues"));
      cmp.fireApplicationEventCall('componentCommunicationEvent', {
         message: 'Adding to Order Please Wait...',
         isLoading: true,
         eventMessage: ''
      });
      var action = cmp.get('c.createOrderItems');
      action.setParams({
         "orderId": currentOrderRecord.Id,
         "selectedProductsValues": selectedProductsValues,
      });
      action.setCallback(this, function (response) {
         var state = response.getState();
         if (state == 'SUCCESS') {
            cmp.set("v.selectedProductsValues", []);
            var orderRecordData = response.getReturnValue();
            cmp.set('v.orderRecord', orderRecordData);
            console.log('orderRecord ' + orderRecordData);
            cmp.set('v.orderItemRecord', orderRecordData.Order_Items__r);
            cmp.set('v.selectedproductsString', '');
            console.log('Order_Items__r ' + orderRecordData.Order_Items__r);
            console.table(cmp.get('v.orderItemRecord'));

            var committedOrderedQuantity = 0;
            var orderItemsList = orderRecordData.Order_Items__r;
            if (orderItemsList instanceof Array) {
               orderItemsList.forEach(function (orderitemRec) {
                  committedOrderedQuantity = committedOrderedQuantity + orderitemRec.Quantity__c;
               });
            }
            var message = 'Product Selection Deleted Successfully';
            var displayMessage = 'Added to Order Successfully..';
            if (orderedQuantity != committedOrderedQuantity) {
               displayMessage = 'Added to Order Successfully..';
            }

            cmp.fireApplicationEventCall('cartCommunicationEvent', {
               message: message,
               selectedproducts: ''
            });
            cmp.fireApplicationEventCall('componentCommunicationEvent', {
               message: '',
               isLoading: false,
               eventMessage: ''
            });
          //  cmp.displayMessage('Success', displayMessage, 'Success', 'dismissible');
            selectedItem.disabled = false;
            selectedItem.innerHTML = '<i class="fa fa-shopping-cart" aria-hidden="true"></i> Add to Order';
         } else {
            console.log('Failed to Add Order Item action ');
            cmp.fireApplicationEventCall('componentCommunicationEvent', {
               message: '',
               isLoading: false,
               eventMessage: ''
            });
            selectedItem.disabled = false;
            selectedItem.innerHTML = '<i class="fa fa-shopping-cart" aria-hidden="true"></i> Add to Order';
            var errors = response.getError();
            var errormessage = 'Failed to Add Order Item: Unknown error';
            if (errors) {
               console.table(errors[0]);
               if (errors[0] && errors[0].message) {
                  errormessage = 'Failed to Add Order Item: ' + errors[0].message;
                  cmp.displayMessage('Failure!', errormessage, 'error', 'dismissible');
                  return;
               }
               if ((errors[0]) && (errors[0].pageErrors.length > 0)) {
                  errormessage = errors[0].pageErrors[0].message;
                  console.log(errors[0].pageErrors[0].message);
                  cmp.displayMessage('Failure!', errormessage, 'error', 'dismissible');
                  return;
               }
            } else {
               cmp.displayMessage('Failure!', errormessage, 'error', 'dismissible');
               return;
            }

            cmp.displayMessage('Failure', errormessage, 'Error', 'dismissible');

         }
      });
      $A.enqueueAction(action);
     }catch(ex){
        console.log('Exception ' + ex);
        console.table(ex);
    }
     },

   deletePOSTab: function (cmp, event, helper) {
      console.log('*** ' + 'deletePOSTab' + ' ***');
      if (confirm('Do You Really want to Delete this Tab?') == false) {
         return false;
      }
      cmp.fireApplicationEventCall('componentCommunicationEvent', {
         message: 'Deleting Tab Please Wait...',
         isLoading: true,
         eventMessage: ''
      });

      var currentOrderRecord = cmp.get('v.orderRecord');

      var action = cmp.get('c.deleteOrderRecord');
      action.setParams({
         "orderId": currentOrderRecord.Id,
      });
      action.setCallback(this, function (response) {
         var state = response.getState();
         if (state == 'SUCCESS') {
            var message = 'Deleted POS Tab Successfully';
            cmp.fireApplicationEventCall('cartCommunicationEvent', {
               message: message,
               selectedproducts: ''
            });
            cmp.fireApplicationEventCall('componentCommunicationEvent', {
               message: '',
               isLoading: false,
               eventMessage: ''
            });

            console.log('Deleted POS Tab Successfully: ');
            cmp.redirectToHome(true, 'Deleted POS Tab Successfully..');

         } else {
            console.log('Failed to Delete Tab ');
            cmp.fireApplicationEventCall('componentCommunicationEvent', {
               message: '',
               isLoading: false,
               eventMessage: ''
            });
            var errors = response.getError();
            if (errors) {
               if (errors[0] && errors[0].message) {
                  cmp.displayMessage('Failure!', 'Failed to Delete Tab : ' + errors[0].message, 'error', 'dismissible');
               }
            } else {
               cmp.displayMessage('Failure!', 'Failed to Delete Tab : Unknown error', 'error', 'dismissible');
            }

         }
      });
      $A.enqueueAction(action);
   },

   //Foucs Tip Amount Input Element
   editTipAmount: function (component, event, helper) {
       component.set('v.Tippercentageshow',false);
      let tipamountinputs = document.querySelectorAll(".tipamountinput");
      tipamountinputs.forEach(tipamountinputElement => {
         tipamountinputElement.focus();
      });
   },

   //Onchange if Tip Amount
   onEnterTipAmount: function (component, event, helper) {
      var newTipAmount = parseFloat(event.target.value);
      
      newTipAmount = isNaN(newTipAmount) ? 0 : newTipAmount;
      console.log('newTipAmountNDR2 '+ newTipAmount);
      if(newTipAmount<0){
        newTipAmount = '0';
      }
      component.set('v.TipAmount', newTipAmount);
      component.calculateAndSetTipAmount();
   },

   //Onchange if Tip Picklist
   reCalculateTip: function (component, event, helper) {
      var selectedItem = event.currentTarget;
      var selectedTipVal = selectedItem.dataset.tipval; // Selected Tip Value
      var selectedTipPercent = component.get('v.selectedTipPercent');
      var selectedTipVal = ((selectedTipVal != null) && (selectedTipVal != undefined)) ? selectedTipVal : selectedTipPercent;
      component.set('v.selectedTipPercent', selectedTipVal);
      component.calculateAndSetTipByPercent();
   },

   handleChargeTipsCollectionPopup: function (component, event, helper) {
      var currentOrderRecord = component.get('v.orderRecord');
      var IntegrationMetadata = component.get('v.IntegrationMetadata');
      component.set('v.SelectedPaymentSource',currentOrderRecord.Member__r.Default_Payment_Method__c);
      console.log('currentOrderRecord.Member__r.Default_Payment_Method__c =' + currentOrderRecord.Member__r.Default_Payment_Method__c);
      console.log('IntegrationMetadatainHandlecharge'+IntegrationMetadata);
      console.table(IntegrationMetadata);
      var allowTip = IntegrationMetadata['allowTip'];
      if(allowTip==undefined){
        allowTip= 'true';
      }
      console.log('allowTipNDR'+allowTip);
      var allowComplimentaryOrders = currentOrderRecord.Member__r.AllowComplimentaryOrders__c;
      console.log('allowComplimentaryOrders NDR*******'+allowComplimentaryOrders);
      var selectedItem = event.currentTarget;
      selectedItem.disabled = true;
      selectedItem.innerHTML = '<i class="fa fa-credit-card fa-flip" aria-hidden="true"></i> Please Wait Closing Tab';
      var istipadded = component.isTipAdded();
      console.log('istipaddedNDR'+istipadded);
      if (allowTip == 'true') {
         if (istipadded == false) {
            component.calculateAndSetTipByPercent();
            component.fireApplicationEventCall('componentCommunicationEvent', {
               message: '',
               isLoading: false,
               eventMessage: 'hideproducts'
            });
            component.set('v.showCartComponent', false);
            component.set('v.isAddTipPopupOpen', true);
            console.log( 'popupopen? '+component.get('v.isAddTipPopupOpen'));
         } else {
            component.set('v.TipAmount', 0.0);
            if (allowComplimentaryOrders == false) {
               //Call Handle Charge 
               component.handleCharge();
            } else {
               //Call Handle Complimentary Charge 
               component.handleComplimentaryCharge();
            }
         }
      } else {
         component.set('v.TipAmount', 0.0);
         if (allowComplimentaryOrders == false) {
            //Call Handle Charge 
            component.handleCharge();
         } else {
            //Call Handle Complimentary Charge 
            component.handleComplimentaryCharge();
         }
      }


   },




   returnBacktoSearch: function (component, event) {
      component.redirectToHome(true, '');
   },

   Backtocontactsearch: function (component, event) {
     
  },


   EditNotes: function (component, event, helper) {
      console.log('EditNotes');
      var selectedItem = event.currentTarget;
      var selectedProdId = selectedItem.dataset.id; // Selected Product Id
      var currentInput = selectedProdId + "inputId";
      component.set("v.editNotesTag", currentInput);
      console.log('currentInput ' + currentInput);
      // setTimeout(function(){
      //     component.find(currentInput).getElement().focus();
      //     console.log('focus' +currentInput);
      // }, 100);
   },
   onNotesChange: function (component, event, helper) {
      console.log('onNotesChange');
      // if(event.getSource().get("v.value").trim() != ''){
      // component.set("v.showSaveCancelBtn",true);
      // }
   },
   closeNotesBox: function (component, event, helper) {
      component.set("v.editNotesTag", '');
      if (event.getSource().get("v.value") == '') {
         component.set("v.showErrorClass", true);
      } else {
         component.set("v.showErrorClass", false);
      }
   },
   openChargeRetryPopup: function (component, event, helper) {
      component.openChargeRetryModal('');
   },

   closeChargeRetryPopup: function (component, event, helper) {
      component.fireApplicationEventCall('componentCommunicationEvent', {
         message: '',
         isLoading: false,
         eventMessage: 'showproducts'
      });
      component.set('v.showCartComponent', true);
      component.set('v.isAddTipPopupOpen', false);
      // Set isChargeRetryPopupOpen attribute to false  
      component.set("v.isChargeRetryPopupOpen", false);
   },
   handleChargeResponseApplyEvent: function (component, event) {
      var paymentStatus = event.getParam("paymentStatus");
      var event = event.getParam("event");
      console.log('Message Received paymentStatus ' + paymentStatus);
      console.log('Message Received event ' + event);
      // component.displayMessage('Alert', message, 'Alert','dismissible');
      component.set('v.paymentStatus', paymentStatus);
      console.log('Message Received from Charge Component');
   },
   closeTipModule: function (component, event, helper) {
      component.set('v.isAddTipPopupOpen', false);
      component.set('v.showCartComponent', true);
      component.fireApplicationEventCall('componentCommunicationEvent', {
         message: '',
         isLoading: false,
         eventMessage: ''
      });
      component.fireApplicationEventCall('componentCommunicationEvent', {
         message: '',
         isLoading: false,
         eventMessage: 'showproducts'
      });
    
      var selectedItem = document.querySelector('.cartclosetabbutton');
      selectedItem.disabled = false;
      selectedItem.innerHTML = '<i class="fa fa-credit-card" aria-hidden="true"></i> Close Tab';

   },

   Notipgiven: function (component, event, helper) {
      console.log('methodcalled');
      var currentOrderRecord = component.get('v.orderRecord');
      var tempOrderTotal = currentOrderRecord.Total_Price__c;

      if ((currentOrderRecord != null) && (currentOrderRecord != undefined)) {
         tempOrderTotal = currentOrderRecord.Total_Price__c;
         console.log('methodcalled' + tempOrderTotal);
         var walletAmount = component.get('v.orderRecord.Member__r.Balance__c');
         walletAmount = (helper.IsValidNumber(walletAmount))?parseFloat(walletAmount): 0.00;
         component.set('v.TipAmount', 0.0);
         component.set('v.TotalAmount', tempOrderTotal);
      }
      var Bankdeduction = 0.0;
      var walletdeduction = 0.0;
      var remainwalletTotal = 0.0;
     if (walletAmount > tempOrderTotal) {
        remainwalletTotal = +(Math.round(walletAmount - tempOrderTotal + "e+2") + "e-2");
        walletdeduction = tempOrderTotal;
     } else { 
        walletdeduction = walletAmount;
     }
     if (tempOrderTotal > walletdeduction) {
        Bankdeduction = +(Math.round(tempOrderTotal - walletdeduction + "e+2") + "e-2");
     } 

     component.set('v.WalletDeduction', walletdeduction);
     component.set('v.BankDeduction', Bankdeduction);
     component.set('v.selectedTipPercent', 0.0);

   },
   PaymentHandling: function (component, event, helper) { //handleAddTipandCharge
     try{
      var TipAmount = component.get('v.TipAmount'); //handleNoTipOnlyCharge
      console.log(TipAmount);
      if (TipAmount > 0) {
         helper.handleAddTipandCharge(component);

      } else {
         helper.handleNoTipOnlyCharge(component);
      }
     } catch (error) {
        console.error(error);
        // Expected output: ReferenceError: nonExistentFunction is not defined
        // (Note: the exact output may be browser-dependent)
      }

   },
   
   selectPaymentSource: function(component, event, helper) {
       var selectedItem = event.currentTarget;
       var selectedPaymentMethodId = selectedItem.dataset.id; 
       console.log('selectedPaymentMethodId ' + selectedPaymentMethodId);
       component.set('v.SelectedPaymentSource', selectedPaymentMethodId);
   },       
   Backtopercentage: function(component, event, helper) {
     component.set('v.Tippercentageshow', true);

   },
   IncrementorderlineitemNew: function(component, event, helper) {
     console.log('first one called')
     var logApiResponses = true;
     var selectedItem = event.currentTarget;
     var Selectedproductid = selectedItem.dataset.prodid;
     console.log('Selectedproductid'+ Selectedproductid);
     var selectedproductsString = component.get("v.selectedproductsString");

      //1 Json String to JSON Object Conversion
   let productObjectData = JSON.parse(selectedproductsString);
   // 2 JSON Object To Map Conversion
   let allSelectedProductsMap = new Map();
   for (var value in productObjectData) {
      allSelectedProductsMap.set(value, productObjectData[value]);
   }
   //Not able to Assign map to Aura Attribute 

   //3 extract valuesfrom map to store in Aura attribute List
   var selectedProductsValues = new Array();
   for (var value in productObjectData) {
      selectedProductsValues.push(productObjectData[value]);
   }
   if (logApiResponses) {
      console.log('Current selectedProductsValues: ');
   }
   if (logApiResponses) {
      console.table(selectedProductsValues);
   }

   var currentSelectedProductFromDataMap = allSelectedProductsMap.get(Selectedproductid);
   if (logApiResponses) {
      console.log('Current currentSelectedProductFromDataMap: ');
   }
   if (logApiResponses) {
      console.table(currentSelectedProductFromDataMap);
   }
   if(currentSelectedProductFromDataMap.quantity< currentSelectedProductFromDataMap.availableStockQuantity){

   var productQuantity = currentSelectedProductFromDataMap.quantity + 1;
     var singleProductPrice = currentSelectedProductFromDataMap.product.Option_Total_Price__c;
     var netUnitPrice = singleProductPrice * productQuantity;
     currentSelectedProductFromDataMap.quantity = productQuantity;
     currentSelectedProductFromDataMap.productPrice = singleProductPrice;
     currentSelectedProductFromDataMap.totalProductPrice = netUnitPrice;
     allSelectedProductsMap.set(Selectedproductid, currentSelectedProductFromDataMap);
     console.log('selectedProductsValues ');
   console.log(selectedProductsValues);
   var preprocessMapToObject = Object.fromEntries(allSelectedProductsMap);
   var processedObjectToString = JSON.stringify(preprocessMapToObject);
   component.set('v.selectedproductsString', processedObjectToString);
   component.set("v.selectedProductsValues", selectedProductsValues);
   var chargeAmount = 0;
   for (let allSelectedProductsMapValue of allSelectedProductsMap.values()) {
      chargeAmount = chargeAmount + allSelectedProductsMapValue.totalProductPrice;
   }
   if (logApiResponses) {
      console.log('Current chargeAmount: ' + chargeAmount);
   }
   component.set("v.totalChargeAmount", chargeAmount);

   component.fireApplicationEventCall('cartCommunicationEvent', {
      message: '',
      selectedproducts: processedObjectToString
   });
   if (logApiResponses) {
      console.log('Called Cart Event Call: ');
   }
   }else{
     component.displayMessage('Failure', 'Maximum stock limit reached', 'Error', 'dismissible');
   }
     },
  //        IncrementorderlineitemNew: function(component, event, helper) {
  //    var logApiResponses = true;
  //    var selectedItem = event.currentTarget;
  //    var Selectedproductid = selectedItem.dataset.prodid;
  //    console.log('Selectedproductid'+ Selectedproductid);
  //    if ((Selectedproductid == null) && (Selectedproductid == undefined) && (Selectedproductid == '')) {
  //       var Itemselected = event.currentTarget;
  //       Selectedproductid = Itemselected.dataset.proditemitemid; 
  //       console.log('Selectedproductid2'+Selectedproductid);
  //    }
  //    var selectedproductsString = component.get("v.selectedproductsString");

  //     //1 Json String to JSON Object Conversion
  //  let productObjectData = JSON.parse(selectedproductsString);
  //  // 2 JSON Object To Map Conversion
  //  let allSelectedProductsMap = new Map();
  //  for (var value in productObjectData) {
  //     allSelectedProductsMap.set(value, productObjectData[value]);
  //  }
  //  //Not able to Assign map to Aura Attribute 

  //  //3 extract valuesfrom map to store in Aura attribute List
  //  var selectedProductsValues = new Array();
  //  for (var value in productObjectData) {
  //     selectedProductsValues.push(productObjectData[value]);
  //  }
  //  if (logApiResponses) {
  //     console.log('Current selectedProductsValues: ');
  //  }
  //  if (logApiResponses) {
  //     console.table(selectedProductsValues);
  //  }

  //  var currentSelectedProductFromDataMap = allSelectedProductsMap.get(Selectedproductid);
  //  if (logApiResponses) {
  //     console.log('Current currentSelectedProductFromDataMap: ');
  //  }
  //  if (logApiResponses) {
  //     console.table(currentSelectedProductFromDataMap);
  //  }
  //  if(currentSelectedProductFromDataMap.quantity< currentSelectedProductFromDataMap.availableStockQuantity){

  //  var productQuantity = currentSelectedProductFromDataMap.quantity + 1;
  //    var singleProductPrice = currentSelectedProductFromDataMap.product.Option_Total_Price__c;
  //    var netUnitPrice = singleProductPrice * productQuantity;
  //    currentSelectedProductFromDataMap.quantity = productQuantity;
  //    currentSelectedProductFromDataMap.productPrice = singleProductPrice;
  //    currentSelectedProductFromDataMap.totalProductPrice = netUnitPrice;
  //    allSelectedProductsMap.set(Selectedproductid, currentSelectedProductFromDataMap);
  //    console.log('selectedProductsValues ');
  //  console.log(selectedProductsValues);
  //  var preprocessMapToObject = Object.fromEntries(allSelectedProductsMap);
  //  var processedObjectToString = JSON.stringify(preprocessMapToObject);
  //  component.set('v.selectedproductsString', processedObjectToString);
  //  component.set("v.selectedProductsValues", selectedProductsValues);
  //  var chargeAmount = 0;
  //  for (let allSelectedProductsMapValue of allSelectedProductsMap.values()) {
  //     chargeAmount = chargeAmount + allSelectedProductsMapValue.totalProductPrice;
  //  }
  //  if (logApiResponses) {
  //     console.log('Current chargeAmount: ' + chargeAmount);
  //  }
  //  component.set("v.totalChargeAmount", chargeAmount);

  //  component.fireApplicationEventCall('cartCommunicationEvent', {
  //     message: '',
  //     selectedproducts: processedObjectToString
  //  });
  //  if (logApiResponses) {
  //     console.log('Called Cart Event Call: ');
  //  }
  //  }else{
  //    component.displayMessage('Failure', 'Maximum stock limit reached', 'Error', 'dismissible');
  //  }
  //    },
     // used for adding the order line item by click
AddOrderItemHandler: function (component, event) {
       var  orderlineitems = component.get('v.orderItemRecord');
       console.table(orderlineitems);
        var logApiResponses = true;
        var selectedItem = event.currentTarget;
        var Selectedorderitemid = selectedItem.dataset.orderitemid;
      
        var selectedorderrecordId = component.get('v.orderRecord.Id');
        console.log('Selectedorderitemid'+ Selectedorderitemid);
        console.log('Selectedorderidid'+ selectedorderrecordId);
       
      var action = component.get('c.updateOrderItem');
      action.setParams({
         "orderId": selectedorderrecordId,
         "orderItemId": Selectedorderitemid,
        
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state == 'SUCCESS') {
           var orderitemupdate = response.getReturnValue();
           
           
           const index = orderlineitems.findIndex(obj => {
              return obj.Id === Selectedorderitemid;
            });
            orderlineitems[index].Quantity__c = orderitemupdate[0].Quantity__c;
            orderlineitems[index].Total_Price__c = orderitemupdate[0].Total_Price__c;
            component.set("v.orderItemRecord", orderlineitems);
           console.log('orderitemupdate' + orderitemupdate);
           console.table(orderitemupdate);
           component.displayMessage('Success!', 'order successfully updated', 'success', 'dismissible');
        } else {
           console.log('Failed  getOrderDetails action');
           var errors = response.getError();
           var errormessage = 'Failed to Delete Order Item: Unknown error';
           if (errors) {
              console.table(errors[0]);
              if (errors[0] && errors[0].message) {
                 errormessage = 'Failed to Delete Order Item: ' + errors[0].message;
                 component.displayMessage('Failure!', errormessage, 'error', 'dismissible');
                 return;
              }
              if ((errors[0]) && (errors[0].pageErrors.length > 0)) {
                 errormessage = errors[0].pageErrors[0].message;
                 console.log(errors[0].pageErrors[0].message);
                 component.displayMessage('Failure!', errormessage, 'error', 'dismissible');
                 return;
              }
           } else {
              component.displayMessage('Failure!', errormessage, 'error', 'dismissible');
              return;
           }
           
        }
     });
     $A.enqueueAction(action);
    },

    RepeatitemHandler: function (component, event) { 
     var selectedItem = event.currentTarget;
        var selectedproductoptionid = selectedItem.dataset.proditemitemid;
        var selectedproductid = selectedItem.dataset.productid;
        console.log('selectedproductid ' + selectedproductid);
        console.log('selectedproductoptionid  ' + selectedproductoptionid);
        var selectedprodQty = parseInt(selectedItem.dataset.proditemquantity);
        console.log('selectedprodQty' + selectedprodQty);
        let prodrepeatvalues = {
           productid : selectedproductid,
           prodoptionid : selectedproductoptionid,
           quantity  :1,
          
         };
        var reatedordervalues = JSON.stringify(prodrepeatvalues);
        console.log(reatedordervalues);
        component.fireApplicationEventCall('componentCommunicationEvent', {
         message:reatedordervalues ,
         isLoading: false,
         eventMessage: 'Repeating order' 
      }); 
    },
    productquantityhandler: function (component, event , helper) {
     var currentselectedquantity = parseInt(event.target.value);
     console.log('newquantity '+ currentselectedquantity);
     var selectedItem = event.currentTarget;
     console.log('selectedItem ' + selectedItem);
     var currentselectedproductid = selectedItem.dataset.productid;
   //  let orderId = event.currentTarget.dataset.order;
     console.log('currentselectedproductid '+ currentselectedproductid);
     component.set('v.QtyofinputBox', currentselectedquantity);
     if(currentselectedquantity != null && currentselectedquantity != 'undefined' && currentselectedquantity !=' ' &&  Number.isInteger(currentselectedquantity)== true && currentselectedproductid != 'undefined' ){
        helper.selecteditemincrementquantity(component, event, currentselectedquantity, currentselectedproductid);
     }
   
    },
    communicationforcontactsearch : function(component, event,helper) {
     var allproductsmap = component.get('v.allProductsMap');  
     console.log('allproductsmap++' + allproductsmap);
     var processedObjectToString = JSON.stringify(allproductsmap);
     console.log('processedObjectToString' + processedObjectToString);
     component.fireApplicationEventCall('ContactcommunicationEvent', {
      
      message: processedObjectToString,
      showchild:false,
      showparent:true
   });

    }
})// This is just a sample script. Paste your real code (javascript or HTML) here.

if ('this_is'==/an_example/){of_beautifier();}else{var a=b?(c%d):e[f];}