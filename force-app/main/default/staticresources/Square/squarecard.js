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
       if(cardElement) {
           cardElement.classList.remove('skeleton-active');
       }
   } catch (e) {
       console.error('Initializing Card failed', e);
   }


//const payments = Square.payments('sandbox-sq0idb-Mq1T5mAUhIYjYDdMVM66cQ', 'L5AMZP3JG68BG');
//const card = await payments.card();
//await card.attach('#card-container');
 
 const cardButton = document.getElementById('card-button');
 cardButton.addEventListener('click', async () => {
  // const statusContainer = document.getElementById('payment-status-container');
 
   try {
     const result = await card.tokenize();
     if (result.status === 'OK') {
       cardcreation(result.token);
       console.log('result object' + result.token);
       console.table(result);


     //  statusContainer.innerHTML = "Payment Successful";
      // statusContainer.style.display = 'block';
     } else {
      //// let errorMessage = Tokenization failed with status: ${result.status};
      // if (result.errors) {
       //  errorMessage += ` and errors: ${JSON.stringify(
         //  result.errors
       //  )}`;
       //}
 
       throw new Error(errorMessage);
     }
   } catch (e) {
     console.error(e);
   //  statusContainer.innerHTML = "Payment Failed";
   //  statusContainer.style.display = 'block';
   }
 });
}
function handelsavedcards1() {
  var Amount = '{!Amount}'
  if(Amount != null){
    paymenthandler();
  }else{
    console.log('card is added sucessfully');
  }
   }


   function handelsavedcards() {
    document.getElementById('newcard').style.display = 'none';
    document.getElementById('savedcards').style.display = 'block';
    var tab1 = document.querySelector('#tab1');
    tab1.classList.add('active');
    var tab2 = document.querySelector('#tab2');
    tab2.classList.remove('active');
    // You can also call an Apex controller method using AJAX
    // var action = '{!myControllerMethod}';
    // action();
  }
  function onIdselection() {
   var cardid =  document.getElementById("cardid").value;
   gettingselectedcardId(cardid);
  //alert('test' + cardid);
  }
  function SavedcardsPaymenthandling() {
   // var cardid =  document.getElementById("cardid").value;
   paymenthandling();
  //alert('test' + cardid);
   }
   function PaymentsyncronousAPIcall() {
    // var cardid =  document.getElementById("cardid").value;
    handleFullfillment();
    paymentAPIcall();
   
 
   //alert('test' + cardid);
    }
    function PaymentsyncronousAPIcallNewcard() {
      // var cardid =  document.getElementById("cardid").value;
      newCardPaymentsyncAPIcall();
      handleFullfillment();
   
     //alert('test' + cardid);
      }
  function handleFullfillment() {
      showLoader();
      //Finalize Todo
      var todorecordidInputElement = document.querySelector('.square-payment-wrapper .todorecordid');
      var todoRecordId = (todorecordidInputElement) ? todorecordidInputElement.value: '' ;
      if( (todoRecordId) && (eval("typeof finalizeTodo") == 'function') ) {
          finalizeTodo(todoRecordId, true);
      } else {
        hideLoader();
      }
    }
  function handlenewcard() {
    document.getElementById('savedcards').style.display = 'none';
    document.getElementById('newcard').style.display = 'block';
    var tab1 = document.querySelector('#tab1');
    tab1.classList.remove('active');
    var tab2 = document.querySelector('#tab2');
    tab2.classList.add('active');
    // You can also call an Apex controller method using AJAX
    // var action = '{!myControllerMethod}';
    // action();
  }
 
  async function verifyBuyer(payments, token) {
      const verificationDetails = {
        amount: '1.00',
        billingContact: {
          givenName: 'John',
          familyName: 'Doe',
          email: 'john.doe@square.example',
          phone: '3214563987',
          addressLines: ['123 Main Street', 'Apartment 1'],
          city: 'London',
          state: 'LND',
          countryCode: 'GB',
        },
        currencyCode: 'GBP',
        intent: 'CHARGE',
      };
 
      const verificationResults = await payments.verifyBuyer(
        token,
        verificationDetails,
      );
      return verificationResults.token;
    }
 
    async function createPayment(token, verificationToken) {
      const body = JSON.stringify({
        locationId,
        sourceId: token,
        verificationToken,
        idempotencyKey: window.crypto.randomUUID(),
      });
 
      const paymentResponse = await fetch('/payment', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body,
      });
 
      if (paymentResponse.ok) {
        return paymentResponse.json();
      }
 
      const errorBody = await paymentResponse.text();
      throw new Error(errorBody);
    }
 

