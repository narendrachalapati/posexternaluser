({
    pollApex: function (component, event, helper) {
       helper.callApexMethod(component, helper);
 
       //execute callApexMethod() again after 5 sec each
       window.setInterval(
          $A.getCallback(function () {
             helper.callApexMethod(component, helper);
          }), 5000
       );
    },
    callApexMethod: function (component, helper) {
       var action = component.get('c.getTransactionDetails');
       var transactionId = component.get('v.transactionId');
       action.setParams({
          "txId": transactionId,
       });
       action.setCallback(this, function (response) {
          var state = response.getState();
          console.log('getTransactionDetails ASYNC Init ' + state);
          if (state == 'SUCCESS') {
             var transactionrec = response.getReturnValue();
             console.log('transactionrec ');
             console.table(transactionrec);
             console.log('transactionrec status ' + transactionrec.Status__c);
             if (transactionrec.Status__c == 'succeeded') {
                component.fireApplicationEventCall('componentCommunicationEvent', {
                   message: '',
                   isLoading: false,
                   eventMessage: ''
                });
                component.redirectToHome(true, 'Successfully Charged Order..');
             } else {
                console.log('Poll Again  ');
             }
 
          } else {
             console.log('Failed to Fetch Transaction ');
             var errors = response.getError();
             if (errors) {
                if (errors[0] && errors[0].message) {
                   component.displayMessage('Failure!', 'Failed to Fetch Transaction : ' + errors[0].message, 'error', 'dismissible');
                }
             } else {
                component.displayMessage('Failure!', 'Failed to Fetch Transaction : Unknown error', 'error', 'dismissible');
             }
          }
       });
       $A.enqueueAction(action);
 
    },
 
    walletmoneyHandeling: function (component) {
       var Walletmoney = component.get('v.orderRecord.Member__r.Balance__c');
       var Paywithwallet = component.get('c.Paywithwallet');
       console.log('Paywithwallet' + Paywithwallet);
       var currentOrderRecord = component.get('v.orderRecord');
       Paywithwallet.setParams({
          orderrecd: currentOrderRecord,
          Discountedprice: '-' + currentOrderRecord.Total_Price__c,
          walletbalance: Walletmoney,
          deductionAmount: currentOrderRecord.Total_Price__c
 
       });
       Paywithwallet.setCallback(this, function (response) {
          var state = response.getState();
          if (state == "SUCCESS") {
             console.log('state:::::' + response.getState());
          } else { // if any callback error, display error msg
             component.set("v.isLoading", false);
             var errors = response.getError();
             if (errors) {
                if (errors[0] && errors[0].message) {
                  // component.displayMessage('Error!', 'Failed to Load Scheduling Products: ' + errors[0].message, 'error');
                }
             } else {
              //  component.displayMessage('Error!', 'Failed to Load Scheduling Products. Status: Unknown error', 'error');
             }
          }
       });
 
       $A.enqueueAction(Paywithwallet);
    },
    insufficientwalletmoneyHandeling: function (component) {
       var Walletmoney = component.get('v.orderRecord.Member__r.Balance__c');
      console.log('Walletmoneyinsufficient'+Walletmoney);
       var Paywithwallet = component.get('c.Paywithwallet');
       console.log('Paywithwallet' + Paywithwallet);
       var currentOrderRecord = component.get('v.orderRecord');
       Paywithwallet.setParams({
          orderrecd: currentOrderRecord,
          Discountedprice: '-' + Walletmoney,
          walletbalance: Walletmoney,
          deductionAmount: Walletmoney
       });
       Paywithwallet.setCallback(this, function (response) {
          var state = response.getState();
          if (state == "SUCCESS") {
             console.log('state:::::' + response.getState());
          } else { // if any callback error, display error msg
             component.set("v.isLoading", false);
             var errors = response.getError();
             if (errors) {
                if (errors[0] && errors[0].message) {
                   component.displayMessage('Error!', 'Failed to Load Scheduling Products: ' + errors[0].message, 'error');
                }
             } else {
                component.displayMessage('Error!', 'Failed to Load Scheduling Products. Status: Unknown error', 'error');
             }
          }
       });
 
       $A.enqueueAction(Paywithwallet);
    },
    handleAddTipandCharge: function (component) {
      try{
    
       console.log('handleAddTipandCharge');
       var TotalbillableAmountbeforecommit = component.get('v.TotalAmount');
       component.set('v.TotalbillableAmountbeforecommit', TotalbillableAmountbeforecommit);
       console.log('TotalbillableAmountbeforecommit' + TotalbillableAmountbeforecommit);
       var Walletmoney = component.get('v.orderRecord.Member__r.Balance__c');
       console.log('Orderrecordcheckin****handle add tip and charge *****');
       console.log(component.get('v.orderRecord'));
       console.log('Member wallet balance'+ Walletmoney);
       var TipAmount = component.get('v.TipAmount');
       console.log('TipAmount::::NDR'+TipAmount);
       var TipPercent = component.get('v.selectedTipPercent');
       var currentOrderRecord = component.get('v.orderRecord');
       var allowComplimentaryOrders = currentOrderRecord.Member__r.AllowComplimentaryOrders__c;
 
       if (TipAmount == 0 || TipAmount == 0.0) {
        //  component.set('v.showCartComponent', true);
        //  component.set('v.isAddTipPopupOpen', false);
          if (allowComplimentaryOrders == false) {
             //Call Handle Charge 
             console.log('helperNDRcrossedstart');
             if (Walletmoney > 0 && Walletmoney >= TotalbillableAmountbeforecommit) {
               console.log('your with no tip your wallet is sufficient to bill ');
                this.walletmoneyHandeling(component);
                console.log('helperNDRcrossed:::::walletmoneyHandeling');
                component.handleComplimentaryCharge();
             }
             if (Walletmoney > 0 && Walletmoney < TotalbillableAmountbeforecommit) {
               console.log('your with no tip your wallet is  not sufficient to bill');
                var funddeductfromgateway = TotalbillableAmountbeforecommit - Walletmoney;
                component.set('v.funddeductfromgateway', funddeductfromgateway);
                console.log('funddeductfromgateway :::' + funddeductfromgateway);
                this.insufficientwalletmoneyHandeling(component);
                console.log('helperNDRcrossed:::::insufficientwalletmoneyHandeling');
                component.handleCharge();
             } if (Walletmoney <= 0 ) {
               console.log('with no tip your wallet is Zero ');
               component.handleCharge();
             }
             var TotalbillableAmountAfterCommit = component.get('v.orderRecord.Total_Price__c');
             console.log('TotalbillableAmountAfterCommit' + TotalbillableAmountAfterCommit);
 
          } else {
             //Call Handle Complimentary Charge 
             component.handleComplimentaryCharge();
          }
       } else {
          component.fireApplicationEventCall('componentCommunicationEvent', {
             message: 'Adding Tip to Order Please Wait...',
             isLoading: true,
             eventMessage: ''
          });
 
          // Create Tip Order Line Item
          var createTipOrderItemAction = component.get('c.createTipOrderItem');
          createTipOrderItemAction.setParams({
             "orderId": currentOrderRecord.Id,
             "TipAmount": TipAmount,
             "TipPercent": TipPercent,
          });
          createTipOrderItemAction.setCallback(this, function (response) {
             var state = response.getState();
             if (state == 'SUCCESS') {
                var orderRecordData = response.getReturnValue();
                component.set('v.orderRecord', orderRecordData);
                component.set('v.orderItemRecord', orderRecordData.Order_Items__r);
              //  var displayMessage = 'Added Tip to Order Successfully.. Processing Payment Please Wait...';
               // component.displayMessage('Success', displayMessage, 'Success', 'dismissible');
               //  component.fireApplicationEventCall('componentCommunicationEvent', {
               //     message: '',
               //     isLoading: false,
               //     eventMessage: 'showproducts'
               //  });
              //  component.set('v.showCartComponent', true);
              //  component.set('v.isAddTipPopupOpen', false);
                if (allowComplimentaryOrders == false) {
                   //Call Handle Charge 
                   console.log('helperNDRcrossedstart');
                   if (Walletmoney > 0 && Walletmoney >= TotalbillableAmountbeforecommit) {
                     console.log('with Tip you wallet money is Suffiecent to pay');
                      this.walletmoneyHandeling(component);
                      console.log('helperNDRcrossed:::::walletmoneyHandeling');
                      component.handleComplimentaryCharge();
                   }
                   if (Walletmoney > 0 && Walletmoney < TotalbillableAmountbeforecommit) {
                     console.log('with Tip you wallet money is insufficentto pay');
                      var funddeductfromgateway = TotalbillableAmountbeforecommit - Walletmoney;
                      component.set('v.funddeductfromgateway', funddeductfromgateway);
                      console.log('funddeductfromgateway :::' + funddeductfromgateway);
                      this.insufficientwalletmoneyHandeling(component);
                      console.log('helperNDRcrossed:::::insufficientwalletmoneyHandeling');
                      component.handleCharge();
                   }if(Walletmoney<=0){
                     console.log('with Tip you wallet money is ZERO');
                     component.handleCharge();
                   }
                   var TotalbillableAmountAfterCommit = component.get('v.orderRecord.Total_Price__c');
                   console.log('TotalbillableAmountAfterCommit' + TotalbillableAmountAfterCommit);
 
                } else {
                   //Call Handle Complimentary Charge 
                   component.handleComplimentaryCharge();
                }
             } else {
                component.fireApplicationEventCall('componentCommunicationEvent', {
                   message: '',
                   isLoading: false,
                   eventMessage: ''
                });
                var errors = response.getError();
                var errormessage = 'Failed to Add Tip to Order Item: Unknown error';
                if (errors) {
                   console.table(errors[0]);
                   if (errors[0] && errors[0].message) {
                      errormessage = 'Failed to Add Tip to Order Item: ' + errors[0].message;
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
 
                component.displayMessage('Failure', errormessage, 'Error', 'dismissible');
 
             }
          });
          $A.enqueueAction(createTipOrderItemAction);
       }
      }catch (error) {
         console.error(error);
         // Expected output: ReferenceError: nonExistentFunction is not defined
         // (Note: the exact output may be browser-dependent)
       }
    },
    handleNoTipOnlyCharge: function (component) {
       var TipAmount = component.set('v.TipAmount', 0);
       var TotalbillableAmountbeforecommit = component.get('v.orderRecord.Total_Price__c');
       component.set('v.TotalbillableAmountbeforecommit', TotalbillableAmountbeforecommit);
       console.log('TotalbillableAmountbeforecommit' + TotalbillableAmountbeforecommit);
       var Walletmoney = component.get('v.orderRecord.Member__r.Balance__c');
 
       var currentOrderRecord = component.get('v.orderRecord');
       var allowComplimentaryOrders = currentOrderRecord.Member__r.AllowComplimentaryOrders__c;
       component.fireApplicationEventCall('componentCommunicationEvent', {
          message: 'Skipping Tip Adding to Order Please Wait...',
          isLoading: true,
          eventMessage: ''
       });
      //  component.fireApplicationEventCall('componentCommunicationEvent', {
      //     message: '',
      //     isLoading: false,
      //     eventMessage: 'showproducts'
      //  });
     //  component.set('v.showCartComponent', true);
     //  component.set('v.isAddTipPopupOpen', false);
       if (allowComplimentaryOrders == false) {
          //Call Handle Charge 
          console.log('helperNDRcrossedstart');
          if (Walletmoney > 0 && Walletmoney >= TotalbillableAmountbeforecommit) {
             this.walletmoneyHandeling(component);
             console.log('helperNDRcrossed:::::walletmoneyHandeling');
             component.handleComplimentaryCharge();
          }
          if (Walletmoney > 0 && Walletmoney < TotalbillableAmountbeforecommit) {
             var funddeductfromgateway = TotalbillableAmountbeforecommit - Walletmoney;
             component.set('v.funddeductfromgateway', funddeductfromgateway);
             console.log('funddeductfromgateway :::' + funddeductfromgateway);
             this.insufficientwalletmoneyHandeling(component);
             console.log('helperNDRcrossed:::::insufficientwalletmoneyHandeling');
             component.handleCharge();
          }if(Walletmoney<= 0){
            component.handleCharge();
          }
       } else {
          //Call Handle Complimentary Charge 
          component.handleComplimentaryCharge();
       }
 
    },
    //this method is used for fetching the user credit cards 
    paymentcardfetch: function (component, membercontactid) {
     
       var paymentcardswrap = component.get('c.getmemberPaymentMethods');
       paymentcardswrap.setParams({
          contactId: membercontactid,
       });
       paymentcardswrap.setCallback(this, function (response) {
          var state = response.getState();
          if (state == "SUCCESS") {
             console.log('state:::::stripcardcollection' + response.getState());
             console.table(response.getState());
             var paymentcardswrapresp = response.getReturnValue();
 
             //stripcardcollection
             component.set("v.UserCards", paymentcardswrapresp.cards);
             console.table(component.get("v.UserCards"));
             component.set('v.ShowSavedCards', true);
             component.set('v.isLoading', false);
          } else { // if any callback error, display error msg
             component.set("v.isLoading", false);
             var errors = response.getError();
             if (errors) {
                if (errors[0] && errors[0].message) {
                   component.displayMessage('Error!', 'Failed to Load Scheduling Products: ' + errors[0].message, 'error');
                }
             } else {
                component.displayMessage('Error!', 'Failed to Load Scheduling Products. Status: Unknown error', 'error');
             }
          }
       });
 
       $A.enqueueAction(paymentcardswrap);
    },
    //Check is Valid Number or not
    IsValidNumber : function (number) {
      return typeof number == "number" ? true : false;
  },
  selecteditemincrementquantity: function(component, event, currentselectedquantity, currentselectedproductid) {
   console.log('*****helper started selecteditemincrementquantity******');
   var logApiResponses = true;
//   var selectedItem = event.currentTarget;
   var Selectedproductid = currentselectedproductid;
   console.log('Selectedproductid'+ Selectedproductid);
   if ((Selectedproductid == null) && (Selectedproductid == undefined) && (Selectedproductid == '')) {
      var Itemselected = event.currentTarget;
      Selectedproductid = Itemselected.dataset.proditemitemid; 
      console.log('Selectedproductid2'+Selectedproductid);
   }
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
 if(currentselectedquantity< currentSelectedProductFromDataMap.availableStockQuantity){

 var productQuantity = currentselectedquantity;
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
   GuestuserCheck: function (component) {
      var action = component.get('c.Guestusercheck');
      var isGuestUser = component.get('v.IsGuestUser');
      action.setCallback(this, function (response) {
         var state = response.getState();
         console.log('Is guestuser check' + state);
         if (state == 'SUCCESS') {
            var Guestusercheck = response.getReturnValue();
            component.set('v.IsGuestUser', Guestusercheck);
            console.log('GuestusercheckNDR'+ component.get('v.IsGuestUser'));
             } else {
            console.log('Failed to Fetch Transaction ');
            var errors = response.getError();
          console.log(errors);
               
         }
      });
      $A.enqueueAction(action);

   }
 })