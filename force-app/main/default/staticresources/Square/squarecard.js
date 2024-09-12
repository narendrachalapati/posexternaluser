//######################### Square related scripting classes start#############################
//#############################################################################################
async function initializeCard(payments) {
  console.log('initializeCard');
  const card = await payments.card();
  await card.attach('#card-container');
  return card;
}
async function initSquareCardUi() {
  console.log('initSquareCardUi');
  const appId = 'sandbox-sq0idb-Mq1T5mAUhIYjYDdMVM66cQ';
  const locationId = 'L5AMZP3JG68BG';
  console.log('Square.payments');
  const payments = Square.payments(appId, locationId);
  let card;
  try {
      card = await initializeCard(payments);
      console.log('initializeCard Successfully');
      var cardElement = document.querySelector('#card-container');
      if (cardElement) {
          cardElement.classList.remove('skeleton-active');
      }
  } catch (e) {
      console.error('Initializing Card failed', e);
  }
  const cardButton = document.getElementById('card-button');

  cardButton.addEventListener('click', async () => {

      try {
          const result = await card.tokenize();
          if (result.status === 'OK') {
              cardcreation(result.token);
              console.log('result object' + result.token);
              console.table(result);



          } else {
              throw new Error(errorMessage);
          }
      } catch (e) {
          console.error(e);
      }
  });
}
//######################### Square related scripting classes End#############################
//#############################################################################################


//######################################## Global click listeners function ################################//
function squarePaymentPageCompleted() {
  console.log('squarePaymentPageCompleted');
  var squarePaymentPageListenerAdded = false;
  var squarePaymentWrapperContainer = document.querySelector('.square-payment-wrapper');
  console.log(squarePaymentWrapperContainer);

  if ((squarePaymentWrapperContainer) && (!squarePaymentPageListenerAdded)) {
      posProductPageListenerAdded = true;
      console.log('squarePaymentWrapperContainer');
      // Click handler for entire DIV posPageWrapperContainer
      squarePaymentWrapperContainer.addEventListener('click', function(e) {
        console.log('squarePaymentPageCompleted addEventListener');
        //############################## click for getting card id // #########################
          if ((e.target.classList.contains('card-selection'))) {
              console.log('methodcalled cardid');
              var selectedCardElement = e.target;
              var cardId = selectedCardElement.getAttribute('data-cardId');
              console.log('cardIdNDR : ' + cardId);
              gettingselectedcardId(cardId);
          }


      });
  }
  //################################## onKeyup Event for getting the amount #####################
  //#############################################################################################
  squarePaymentWrapperContainer.addEventListener('keyup', function (e) {
   // Click handler for entire DIV product-wrapper
    if ((e.target.classList.contains('card-input__input'))) {
      
       console.log('methodcalled onkeyup calld tip amount ');
       var tipElement = e.target; //
      var tipamount = tipElement.value;
     var isnumb = isNumber(e);
     if(isnumb){
      const tipamountmod = parseFloat(tipamount);
      console.log('tipamount' + tipamountmod);
      if(tipamountmod > 0 && tipamountmod != null && tipamountmod !='' ){
        addTip(tipamountmod);
      }
      
     }else{
      console.log('text  is entered');
     }
      
     }
  
  });
}




 //############  Functions for changing the tab panel start ##############//
function handelsavedcards() {
  changeActiveTabPanel('saved-cards-tab');
}

function handlenewcard() {
  changeActiveTabPanel('add-card-tab');
}
//############  Functions for changing the tab panel End ##############//
function handelsavedcards1() {
  var Amount = '{!Amount}'
  if (Amount != null) {
      paymenthandler();
  } else {
      console.log('card is added sucessfully');
  }
}


function SavedcardsPaymenthandling() {
  // var cardid =  document.getElementById("cardid").value;
  paymenthandling();
  //alert('test' + cardid);
}

function PaymentsyncronousAPIcall() {
  handleFullfillment();
  paymentAPIcall();
 

}
//################ Payment Handling handler ##########################//
function PaymentsyncronousAPIcallNewcard() {
  newCardPaymentsyncAPIcall();
  handleFullfillment();
}
//################ Handle Fulfillment screen ##########################//
function handleFullfillment() {
  if ((eval("typeof showLoader") == 'function')) {
      showLoader();
  }
  //Finalize Todo
  var todorecordidInputElement = document.querySelector('.square-payment-wrapper .todorecordid');
  var todoRecordId = (todorecordidInputElement) ? todorecordidInputElement.value : '';
  if ((todoRecordId) && (eval("typeof finalizeTodo") == 'function')) {
      finalizeTodo(todoRecordId, true);
  } else {
      if ((eval("typeof hideLoader") == 'function')) {
          hideLoader();
      }

  }
}
function isNumber(evt)
		 {
    evt = (evt) ? evt : window.evt;
    var charCode = (evt.which) ? evt.which : evt.keyCode;
    if (charCode > 31 && (charCode < 48 || charCode > 57)) {
        return false;
    }
    return true; }