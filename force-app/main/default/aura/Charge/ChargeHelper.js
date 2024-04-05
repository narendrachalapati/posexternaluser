({
	processPaymentsApiCall : function(component, helper, savedPaymentIntents, stripePaymentRequest) {
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
                    component.handleChargeResponseStatus(paymentsResponse);
                    
                } else {
                    console.log(processPaymentsActionData.getError());
                    var processPaymentsActionErrors = processPaymentsActionData.getError();
                    var paymentErrorResponse = component.apiCallErrorHandling(processPaymentsActionErrors, 'processPayments');
                    reject(paymentErrorResponse);
                    console.log('apiCall processPayments Failed');
                    console.log('processPayments Response ' + paymentErrorResponse);
                    component.set('v.initStatus', paymentErrorResponse);
                    component.set('v.Loading', false);
                }
                
            });
            $A.enqueueAction(processPaymentsAction);
        }));
	},
    
    createPaymentRequestsApiCall : function(component, helper, paymentRequests, stripePaymentRequest) {
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
                    // component.processPayments(savedPaymentRequests, stripePaymentRequest);
                    
                    var processPaymentsAction_Immediate = component.get('c.processPayments');
                    processPaymentsAction_Immediate.setParams({
                        "paymentRequests": (savedPaymentRequests== undefined) ? '' : savedPaymentRequests,
                        "stripePaymentRequest": stripePaymentRequest
                    });
                    processPaymentsAction_Immediate.setCallback(this, function (processPaymentsData) {
                        var processPaymentsAction_State = processPaymentsData.getState();
                        console.log('processPaymentsAction_Immediate state ' + processPaymentsAction_State);
                        if (processPaymentsAction_State == "SUCCESS") {
                            var paymentsResponse_Immediate = processPaymentsData.getReturnValue();
                            console.log('processPaymentsAction_Immediate response ' + paymentsResponse_Immediate);
                            console.log('apiCall processPayments Success');
                            console.table(paymentsResponse_Immediate);
                            
                            component.handleChargeResponseStatus(paymentsResponse_Immediate);
                            
                        } else {
                            console.log(processPaymentsData.getError());
                            var processPayments_Errors = processPaymentsData.getError();
                            var paymentErrorResponse_Error = component.apiCallErrorHandling(processPayments_Errors, 'processPayments');
                            
                            console.log('apiCall processPayments Failed');
                            console.log('processPayments Response ' + paymentErrorResponse_Error);
                            component.set('v.initStatus', paymentErrorResponse_Error);
                            component.set('v.Loading', false);
                        }
                        
                    });
                    $A.enqueueAction(processPaymentsAction_Immediate);
                    
                } else {
                    console.log(createPaymentRequestsActionResponseData.getError());
                    var createPaymentRequests_Errors = createPaymentRequestsActionResponseData.getError();
                    console.log(createPaymentRequests_Errors);
                    var createPaymentRequests_Error = component.apiCallErrorHandling(createPaymentRequests_Errors, 'createPaymentRequests');
                    console.log('apiCall createPaymentRequests Failed');
                    console.log('createPaymentRequests Response ' + createPaymentRequests_Error);
                    component.set('v.initStatus', createPaymentRequests_Error);
                    component.set('v.Loading', false);
                }
            });
            $A.enqueueAction(createPaymentRequestsAction);
        }));
    }
})