
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
alert('test' + cardid);
}
function SavedcardsPaymenthandling() {
 // var cardid =  document.getElementById("cardid").value;
 paymenthandling();
alert('test' + cardid);
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