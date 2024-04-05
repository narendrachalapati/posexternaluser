({
    logApiResponses : true,
    
    fireApplicationEventCall : function (component, event, eventControllerName, params) {
            var appEvent = $A.get('e.c:' + eventControllerName);
            if (this.logApiResponses) { console.log('*** ' + 'Sending messagedata' + ' *** ' + params ); }  
            appEvent.setParams(params);
            if (this.logApiResponses) { console.log('*** ' + 'Sending messagedata' + ' *** ' + params ); }   
            if (this.logApiResponses) { console.log('*** ' + 'Sending application event' + ' *** ' + eventControllerName ); }   
            appEvent.fire();
            if (this.logApiResponses) { console.log('*** ' + 'Sent application event successfully' + ' *** ' + eventControllerName); }   
	},
            
    createPaymentRequestsApiCall : function(component, paymentRequests, stripePaymentRequest) {
        return new Promise($A.getCallback(function(resolve, reject) {
            var createPaymentRequestsAction = component.get('c.createPaymentRequests');
            createPaymentRequestsAction.setParams({
                "chargeRequests": paymentRequests
            });
            createPaymentRequestsAction.setCallback(this, function (createPaymentRequestsActionResponseData) {
                var createPaymentRequestsActionResponseState = createPaymentRequestsActionResponseData.getState();
                if (createPaymentRequestsActionResponseState == "SUCCESS") {
                    var savedPaymentRequests = createPaymentRequestsActionResponseData.getReturnValue();
                    component.set('v.savedPaymentRequests', savedPaymentRequests);
                    console.log('apiCall createPaymentRequests Success');
                    resolve(savedPaymentRequests);
                    
                } else {
                    console.log(createPaymentRequestsActionResponseData.getError());
                    var createPaymentRequests_Errors = createPaymentRequestsActionResponseData.getError();
                    console.log(createPaymentRequests_Errors);
                    var createPaymentRequests_Error = component.apiCallErrorHandling(createPaymentRequests_Errors, 'createPaymentRequests');
                    console.log('apiCall createPaymentRequests Failed');
                    console.log('createPaymentRequests Response ' + createPaymentRequests_Error);
                    reject(createPaymentRequests_Error);
                }
            });
            $A.enqueueAction(createPaymentRequestsAction);
        }));
    },
    
	processPaymentsApiCall : function(component, savedPaymentIntents, stripePaymentRequest) {
		return new Promise($A.getCallback(function(resolve, reject) {
            var processPaymentsAction = component.get('c.processPayments');
            processPaymentsAction.setParams({
                "paymentRequests" : (savedPaymentIntents == undefined) ? '' : savedPaymentIntents,
                stripePaymentRequest: stripePaymentRequest
            });
            processPaymentsAction.setCallback(this, function (processPaymentsActionData) {
                var processPaymentsActionState = processPaymentsActionData.getState();
                console.log('processPaymentsAction state ' + processPaymentsActionState);
                if (processPaymentsActionState == "SUCCESS") {
                    var paymentsResponse = processPaymentsActionData.getReturnValue();
                    console.log('processPaymentsAction response ' + paymentsResponse);
                    console.log('apiCall processPayments Success');
                    console.table(paymentsResponse);
                    resolve(paymentsResponse);
                    
                } else {
                    console.log(processPaymentsActionData.getError());
                    var processPaymentsActionErrors = processPaymentsActionData.getError();
                    var paymentErrorResponse = component.apiCallErrorHandling(processPaymentsActionErrors, 'processPayments');
                    
                    console.log('apiCall processPayments Failed');
                    console.log('processPayments Response ' + paymentErrorResponse);
                    reject(paymentErrorResponse);
                }
                
            });
            $A.enqueueAction(processPaymentsAction);
        }));
	},
    
})