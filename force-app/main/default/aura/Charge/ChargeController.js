({
    doInit: function (component, event, helper) {
        console.log('Contact initcheck'+component.get('v.recordId'));
        window.addEventListener("message", receiveMessage, false);
       
        //-----WIZARD INIT------
        if (component.get('v.wizardUuid')) {
            console.log('todo record charge ',component.get("v.todoRecordId"));
        }

        //-----------------------

        function receiveMessage(event) {
            console.log('receiveMessage ');
            if (event.data.paymentRequest) {
                var paymentRequest = JSON.parse(event.data.paymentRequest);
                console.log('paymentRequest');
                console.table(paymentRequest);

                component.checkoutItems(paymentRequest);
            }
        }

        var logApiResponses = true;

        component.apiCall = function (controllerMethodName, params, success, failure) {
            try {
                var action = component.get('c.' + controllerMethodName);
                Object.keys(params).forEach(key => {
                    if (params[key] === undefined) {
                        params[key] = '';
                    }
                });
                //('controllerMethodName! '  + controllerMethodName );
                // alert('params to perform action!'  + JSON.stringify(params) );
                action.setParams(params);
                action.setCallback(this, function (data) {
                    if (logApiResponses) console.log(data.getError());
                    var errors = data.getError();
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        if (failure) {
                            component.set('v.Loading', false);
                            failure(errors[0].message);
                        } else {
                            if (logApiResponses) {
                                console.log(errors);
                                console.log('Failed to perform action!' + controllerMethodName + ' ' + JSON.stringify(errors));
                            }
                        }
                        component.set('v.Loading', false);
                    } else {
                        if (logApiResponses) console.log(data.getReturnValue());
                        if (success) success(data.getReturnValue());
                    }
                });
                $A.enqueueAction(action);
            } catch (error) {
                failure(error);
            }
        };

        
        component.hasRecordId = function () {
            var recordId = component.get('v.recordId');
            if( (recordId != '') && (recordId != null)  && (recordId != undefined) ){
                return true;
            }else{
                return false;
            }
        };

        component.findContact = function () {
            var contact = component.get("v.SelectedContact");
            console.log('contactNDR'+ contact);
            if( (contact != null) && (contact != undefined) && (contact != '') ){
                return contact;
            } else if (component.hasRecordId()) {
                return component.get("v.obj");
            } else {
                return contact;
                // component.displayMessage('Check', 'Please select a contact!', 'warning');
            }
        };

        component.getAmount = function () {
            var amount = component.get("v.PaymentAmount");
            if (amount > 0){
                return amount;
            } 
            else {
                component.displayMessage('Check', 'Please enter a valid amount!', 'warning');
                return 0;
            }
        };

        component.getPhone = function () {
            var phoneNumber = component.get("v.PhoneNumber");
            if (!phoneNumber) {
                component.displayMessage('Check', 'Please provide a valid Phone Number', 'warning');
                return;
            }
            return phoneNumber;
        };

        component.isFailedTransactionwithSelectedContact = function () {
            var isFailedTransaction = component.get('v.isFailedTransaction');
            var SelectedContact = component.get('v.SelectedContact');
            var PaymentAmount = component.get('v.PaymentAmount');
            var contactRecordId = component.get('v.recordId');
            if( (isFailedTransaction == true) && (PaymentAmount > 0) && (SelectedContact != null) ){
                return true;
            }else{
                return false;
            }
        };

        component.goToCheckoutPage = function() {
            component.set('v.initStatus', '');
            component.set('v.ShowPaymentOptions', true);
            component.set('v.ShowTransactionDetails', false);
            component.set('v.ShowDefaultPage', false);
            var contact = component.findContact();
            var recordId = component.get('v.recordId');
            var OrderrecordId = component.get('v.OrderrecordId');
            var amount = component.getAmount();
            var currencySymbol = $A.get("$Locale.currency");
            var payableAmountMessage = 'Proceed to Pay ' + currencySymbol + ' ' + amount ;
            var iFrameUrl = component.get('v.StripeCardUI');
            var ObjiFrameUrl = new URL(iFrameUrl);

            if( ( (contact == null) || (contact == undefined) || (contact == '') ) && ( (recordId == null) || (recordId == undefined) || (recordId == '') ) ){
                component.set('v.isVirtualTerminal', true);
                component.set('v.chargeMessage', payableAmountMessage);

                ObjiFrameUrl.searchParams.set('saveCard', 'false');
                console.log(ObjiFrameUrl.toString()); 
                iFrameUrl = ObjiFrameUrl.toString();
                component.set('v.StripeCardUI', iFrameUrl);
            }else{
                ObjiFrameUrl.searchParams.set('saveCard', 'true');
                console.log(ObjiFrameUrl.toString()); 
                iFrameUrl = ObjiFrameUrl.toString();
                component.set('v.StripeCardUI', iFrameUrl);
            }

            if( (OrderrecordId != null) && (OrderrecordId != undefined) && (OrderrecordId != '') ){
                component.set('v.isFailedTransaction', true);
                component.set('v.chargeMessage', payableAmountMessage);
            }
            console.log('goToCheckoutPage Selected contact ' + contact);
            console.table(contact);
               
        };

        component.apiCallErrorHandling = function (errors, controllerMethodName) {
            var apiCallErrorResponse;
            if (errors && Array.isArray(errors) && errors.length > 0) {
                if (errors[0].message) {
                    console.log(errors[0].message);
                    apiCallErrorResponse = errors[0].message;
                } else {
                    console.log('Failed to perform action! ' + controllerMethodName + ' ' + JSON.stringify(errors));
                    apiCallErrorResponse = 'Failed to perform action! ' + controllerMethodName + ' ' + JSON.stringify(errors);
                }
            } else {
                console.log('Failed to perform action! ' + controllerMethodName + ' ' + JSON.stringify(errors));
                apiCallErrorResponse = 'Failed to perform action! ' + controllerMethodName + ' ' + JSON.stringify(errors);
            }
            return apiCallErrorResponse;
        };

        component.handleChargeResponseStatus = function (component, paymentsResponse) {
            console.log('handleChargeResponseStatus Init');
            var isFailedTransaction = component.get('v.isFailedTransaction');
            var txnstatus, statusMessage, statusCode;

            if ((paymentsResponse != null) && (paymentsResponse != undefined) && (paymentsResponse != '')) {
                if (paymentsResponse.type == 'TXN') {
                    statusMessage = ((paymentsResponse.txn.Status__c != 'failed') ? 'Card Charged Successfully' : paymentsResponse.txn.FailureMessage__c);
                    component.set('v.initStatus', ((paymentsResponse.txn.Status__c != 'failed') ? '' : paymentsResponse.txn.FailureMessage__c));
                    txnstatus = ((paymentsResponse.txn.Status__c != 'failed') ? 'Success' : 'Failed');
                    statusCode = ((paymentsResponse.txn.Status__c != 'failed') ? '' : paymentsResponse.txn.FailureCode__c);
                }
                if (paymentsResponse.type == 'OTHER') {
                    statusMessage = ((paymentsResponse.paymentRequest.Status__c != 'payment_failed') ? 'Card Charged Successfully' : 'Failed to Charge Card: Unknown Error');
                    component.set('v.initStatus', ((paymentsResponse.paymentRequest.Status__c != 'payment_failed') ? '' : 'Failed to Charge Card: Unknown Error'));
                    txnstatus = ((paymentsResponse.paymentRequest.Status__c != 'payment_failed') ? 'Success' : 'Failed');
                    statusCode = ((paymentsResponse.paymentRequest.Status__c != 'payment_failed') ? '' : 'Unknown');
                }
            }
            console.log('txnstatus ' + txnstatus);
            console.log('statusMessage ' + statusMessage);
            console.log('statusCode ' + statusCode);

            if(txnstatus =='Success'){
                component.set('v.paymentResponse', paymentsResponse);	
                console.log('Success Block ' + paymentsResponse);	
                console.table( component.get('v.paymentResponse'));	 
                component.set('v.ShowTransactionDetails', true);
                component.set('v.Loading', false);
                component.set('v.ShowPaymentOptions', false);                    
                component.set('v.ShowDefaultPage', false);
                component.set('v.initStatus', '');
                helper.fireApplicationEventCall(component, event, 'ChargeResponseApply' , { 'paymentStatus' : txnstatus, 'event':'chargeResponse' } );
            }else if( (isFailedTransaction == 'true') ){//Retry Payment on POS Screen
                component.set('v.paymentResponse', paymentsResponse);
                console.log('isFailedTransaction Block ' + paymentsResponse);
                console.table( component.get('v.paymentResponse'));	 				 
                component.set('v.ShowTransactionDetails', false);
                component.set('v.ShowPaymentOptions', true);                    
                component.set('v.ShowDefaultPage', false);
                helper.fireApplicationEventCall(component, event, 'ChargeResponseApply' , { 'paymentStatus' : txnstatus, 'event':'chargeResponse' } );
            }else{//Retry Payment Virtual Terminal
                component.set('v.paymentResponse', paymentsResponse);
                console.log('Payment Virtual Terminal Block ' + paymentsResponse);
                console.table( component.get('v.paymentResponse'));	 					 
                component.set('v.ShowTransactionDetails', false);
                component.set('v.ShowPaymentOptions', true);                    
                component.set('v.ShowDefaultPage', false);
                helper.fireApplicationEventCall(component, event, 'ChargeResponseApply' , { 'paymentStatus' : txnstatus, 'event':'chargeResponse' } );
            }
            component.set('v.Loading', false);
        };

        component.checkoutItems = function (stripePaymentRequest) {
            try {
                console.log('checkoutItems Init');
                component.set('v.Loading', true);
                var savedPaymentIntents = component.get('v.savedPaymentRequests');
                
                component.set('v.paymentResponse','');
                var paymentRequests = component.get('v.CheckoutItems');
                console.log('paymentRequestsNDR '+ paymentRequests);
                if ((Array.isArray(savedPaymentIntents)) && (savedPaymentIntents.length != 0)) {
                    console.log('apiCall use Existing Intent Calling');

                    // Start promise for processPaymentsApiCall async call
                    var processPaymentsApiCallPromise = helper.processPaymentsApiCall(component, savedPaymentIntents, stripePaymentRequest);
                    processPaymentsApiCallPromise
                    .then(
                        // resolve callback of processPaymentsApiCall async call
                        $A.getCallback(function(paymentsResponse) {
                            console.log('processPaymentsAction response ' + paymentsResponse);
                    		console.log('apiCall processPayments Success');
                    		component.handleChargeResponseStatus(component, paymentsResponse);
                        })
                    )
                    .catch(
                        // reject callback
                        $A.getCallback(function(error) {
                            console.error('=========== error = ' + error);
                            console.log('=========== error = ' + error.stack);
                            component.set('v.initStatus', error);
                            component.set('v.Loading', false);
                        })
                    );

                } else {
                    console.log('apiCall createPaymentRequests Calling');
                     // Start promise for createPaymentRequestsApiCallPromise async call
					var createPaymentRequestsApiCallPromise = helper.createPaymentRequestsApiCall(component, paymentRequests, stripePaymentRequest);
                    createPaymentRequestsApiCallPromise
                    .then(
                        // resolve callback of createPaymentRequestsApiCall async call
                        $A.getCallback(function(savedPaymentRequests) {
                            console.log('savedPaymentRequests = ' + savedPaymentRequests);
                            // Start promise for processPaymentsApiCallPromise async call
                            return helper.processPaymentsApiCall(component, savedPaymentRequests, stripePaymentRequest);
                        })
                    )
                    .then(
                        // resolve callback of processPaymentsApiCall async call
                        $A.getCallback(function(paymentsResponse) {
                            console.log('processPaymentsAction response ' + paymentsResponse);
                    		console.log('apiCall processPayments Success');
                    		component.handleChargeResponseStatus(component, paymentsResponse);
                        })
                    )
                    .catch(
                        // reject callback
                        $A.getCallback(function(error) {
                            console.error('=========== error = ' + error);
                            console.log('=========== error = ' + error.stack);
                            component.set('v.initStatus', error);
                            component.set('v.Loading', false);
                        })
                    );
                        
                }
            } catch (error) {
                console.error('=========== error = ' + error);
                console.log('=========== error = ' + error.stack);
                component.set('v.initStatus', error);
                component.set('v.Loading', false);
          }
        }
        
        component.addToCart = function () {
            var contact = component.findContact();

            var amount = component.getAmount();
            var frequency = component.get('v.SelectedFrequency');
            var paymentType = (frequency === 'single') ? 'immediate' : 'subscription';
            var firstChargeDate = component.get('v.FirstChargeDate');

            if (paymentType === 'subscription') {
                if (!frequency) {
                    component.displayMessage('Error', 'Frequency not selected', 'error');
                    return;
                }

                if (!firstChargeDate || !component.isValidDate(firstChargeDate)) {
                    component.displayMessage('Error', 'Enter a valid first payment date', 'error');
                    return;
                }
            } else {
                firstChargeDate = new Date();
            }
            var contactId, contactName, paymentName, accountId, email;
            var orderId = component.get("v.OrderrecordId");
            if( (orderId == null) || (orderId == undefined) || (orderId == '') ){
                orderId = null;
            }

            if( (contact != null) && (contact != undefined) && (contact != '') ){
                contactId = contact.Id;
                contactName = contact.Name;
                paymentName = 'Payment of ' + amount + ' for Services Rendered by ' + contact.Name;
                accountId = component.get("v.obj.AccountId");
                email = component.get("v.obj.Email");
            }else{
                contactId = null;
                contactName = 'Virtual Terminal Payment';
                paymentName = 'Virtual Terminal Payment of ' + amount;
                accountId = null;
                email = '';
            }
            var request = {
                amount: amount,
                contactId:  contactId,
                contactName:  contactName,
                accountId: accountId,
                orderId: orderId,
                paymentName: paymentName,
                paymentType: paymentType,
                email: email,
                frequency: frequency,
                firstChargeDate: firstChargeDate,
                frequencyDisplayName: component.getFrequencyDisplayName(frequency)
            };

            component.set('v.CheckoutItems', []);
            var checkoutItems = component.get('v.CheckoutItems');
            
            checkoutItems.push(request);
            component.set('v.CheckoutItems', checkoutItems);
            console.log('checkoutItems');
            console.table(component.get('v.CheckoutItems') );
        }

        component.uuid4 = function() {
          return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
          });
        }

        component.isValidDate = function(d) {
            var dt = new Date(d);
            dt.setHours(0, 0, 0, 0);
            var today = new Date();
            today.setHours(0, 0, 0, 0);
            return dt > today;
        }

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

        component.loadThirtyPartyPaymentElements = function () {
            component.apiCall('getOrgUrl', {}, function (url) {
                var cardIFrame = document.getElementById('stripeCardUI');
                var GuestSiteLink = $A.get("$Label.c.GuestSiteLink");
                var baseUrl = GuestSiteLink;
                var iFrameUrl = baseUrl + '/apex/StripeCardUI?key=' + component.get('v.StripePublishableKey') + '&saveCard=true';
                console.log('iFrameUrl ' + iFrameUrl);
                component.set('v.StripeCardUI', iFrameUrl);

                // cardIFrame.onload = function() {
                //     console.log('iFrameUrl Loaded ');
                //     component.set('v.StripeCardUILoading', false);
                // };
                component.set('v.Loading', false);
            });
        }

        component.loadAppProperties = function() {
            var AccountId = component.get('v.AccountId');
            console.log('AccountId***NDR :::::'+ AccountId);
            component.apiCall('getProperties', {recordId:AccountId}, function(properties) {

               var result = properties;
               component.set('v.StripePublishableKey', result['PublicKey']);
               component.loadThirtyPartyPaymentElements();
            });
        }

        component.loadUserPaymentMethods = function(contactId) {
            component.set('v.PaymentMethodsLoading', true);
            component.apiCall('getPaymentMethods', {contactId: contactId}, function(paymentMethods) {
                component.set('v.UserCards', paymentMethods.cards);
                component.set('v.PaymentMethodsLoading', false);
                component.set('v.ShowSavedCards', true);
            });
        }

        component.getFrequencyDisplayName = function(frequency) {
            var labels = component.get('v.Labels');
            if(!labels ){
           return 'single';
            }
            return frequency == 'single' ? labels['frequency_single'] :
                frequency == 'month' ? labels['frequency_month'] :
                frequency == 'quarter' ? labels['frequency_quarter'] :
                frequency == 'year' ? labels['frequency_year'] : null;
        }

       component.initData = function () {
            component.apiCall('getObjectAndLabels', {},
            function (labels) {
                component.set('v.Labels', labels);
                component.set('v.FrequencyOptions', [
                    { 'label': labels['frequency_single'], 'value': 'single'},
                    { 'label': labels['frequency_month'], 'value': 'month' },
                    { 'label': labels['frequency_quarter'], 'value': 'quarter' },
                    { 'label': labels['frequency_year'], 'value': 'year' }
                ]);
                console.log('getObjectAndLabels');
                if (component.hasRecordId()) {
                    var contact = component.get("v.obj");
                    if( (contact == null) || (contact == undefined) || (contact == '') ){
                        //component.find("recordLoader").reloadRecord(); 
                        
                        var action = component.get('c.Contactrecordfetch');
                        action.setParams({
                            "recordId" : component.get('v.recordId')
                        });
                        action.setCallback(this, function (response) {
                            var state = response.getState();
                            var contact = response.getReturnValue();
                            console.log('response.getReturnValue()');
                            console.log(response.getReturnValue());
                            if (state == "SUCCESS") {
                                component.set("v.SelectedContact", contact);
                                component.set("v.obj", contact);
                                console.log('contact++++' + component.get('v.SelectedContact'));
                                component.set("v.PhoneNumber", contact.Phone_Number__c);
                                component.loadUserPaymentMethods(contact.Id);
                                if( (contact.Default_Payment_Method__c != null) && (contact.Default_Payment_Method__c != undefined) ){
                                    component.set("v.SelectedPaymentSource", contact.Default_Payment_Method__c);
                                }
                                
                                if(component.isFailedTransactionwithSelectedContact()){
                                    component.addToCart();
                                    component.goToCheckoutPage();
                                }
                                
                                component.set('v.Loading', false);
                                
                            } else { // if any callback error, display error msg
                            	component.set('v.Loading', false);
                                console.log('Error in Fetiching Related Activities for POS Order..');
                            }
                                                        
                        });
                        $A.enqueueAction(action);
                    }else{
                        component.set("v.SelectedContact", contact);
                        console.log('contact++++' + component.get('v.SelectedContact'));
                        component.set("v.PhoneNumber", contact.Phone_Number__c);
                        component.loadUserPaymentMethods(contact.Id);
                        if( (contact.Default_Payment_Method__c != null) && (contact.Default_Payment_Method__c != undefined) ){
                            component.set("v.SelectedPaymentSource", contact.Default_Payment_Method__c);
                        }
                        if(component.isFailedTransactionwithSelectedContact()){
                            component.addToCart();
                            component.goToCheckoutPage();
                        }
						component.set('v.Loading', false);
                    }
                    
                }
                
            });
        };

        component.set('v.DateToday', new Date().toISOString().split('T')[0]);
        component.set('v.FirstChargeDate', component.get('v.DateToday'));
        component.loadAppProperties();
        var recId = component.get('v.recordId');
        var contact = component.findContact();
        if( (recId == null) || (!contact) ) {
            component.initData();
        }
    },
    recordLoaded: function (component, event, helper) {
        component.initData();
    },
    editPhone: function (component, event, helper) {
        component.set('v.ShowPhone', true);
    },
    onCardCharge: function (component, event, helper) {
        component.checkoutItems({'paymentMethod': 'card', 'selectedPaymentSource': component.get('v.SelectedPaymentSource')});
    },
    // selectFrequency: function (component, event, helper) {
    //     component.set('v.SelectedFrequency', event.getSource().get("v.accesskey"));
    // },
    searchAndSelectContact: function (component, event, helper) {
        var contact = event.getParam('search-result');
        component.set('v.SelectedContact', contact);
        component.set('v.obj', contact);
        if (contact) {
            component.loadUserPaymentMethods(contact.Id);
            component.set("v.PhoneNumber", contact.Phone_Number__c );
            component.set("v.SelectedPaymentSource", contact.Default_Payment_Method__c);
        } else {
            component.set('v.UserCards', []);
            component.set('v.ShowPhone', false);
            component.set('v.ShowSavedCards', false);
        }
    },
    stripeCardLoaded: function(component, event, helper) {
        component.set('v.StripeCardUILoading', false);
    },
    handleCheckout: function(component, event, helper) {
        component.addToCart();
        var amount = component.get("v.PaymentAmount");
        if (amount > 0){
            // component.set('v.PaymentAmount', null);
            component.goToCheckoutPage();
        }
        else {
            component.displayMessage('Check', 'Please enter a valid amount!', 'warning');
        }
    },
    selectPaymentSource: function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var selectedPaymentMethodId = selectedItem.dataset.id; 
        console.log('selectedPaymentMethodId ' + selectedPaymentMethodId);
        component.set('v.SelectedPaymentSource', selectedPaymentMethodId);
    },
    goToDefaultPage: function(component, event, helper) {
        component.set('v.ShowDefaultPage', true);
        // component.set('v.PaymentAmount', null);
        component.set('v.ShowTransactionDetails', false);
        component.set('v.ShowPaymentOptions', false);
        component.set('v.EnableCheckoutButton', false);
        component.set('v.chargeMessage', '');
    },
});