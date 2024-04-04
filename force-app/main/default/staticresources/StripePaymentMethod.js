var j$ = jQuery.noConflict();

var stripe, CardElements, customLabels;

var currencyCodes = {
    'ALL': '&#76;&#101;&#107;',
    'AFN': '&#1547;',
    'ARS': '&#36;',
    'AWG': '&#402;',
    'AUD': '&#36;',
    'AZN': '&#1084;&#1072;&#1085;',
    'BSD': '&#36;',
    'BBD': '&#36;',
    'BYN': '&#66;&#114;',
    'BZD': '&#66;&#90;&#36;',
    'BMD': '&#36;',
    'BOB': '&#36;&#98;',
    'BAM': '&#75;&#77;',
    'BWP': '&#80;',
    'BGN': '&#1083;&#1074;',
    'BRL': '&#82;&#36;',
    'BND': '&#36;',
    'KHR': '&#6107;',
    'CAD': '&#36;',
    'KYD': '&#36;',
    'CLP': '&#36;',
    'CNY': '&#165;',
    'COP': '&#36;',
    'CRC': '&#8353;',
    'HRK': '&#107;&#110;',
    'CUP': '&#8369;',
    'CZK': '&#75;&#269;',
    'DKK': '&#107;&#114;',
    'DOP': '&#82;&#68;&#36;',
    'XCD': '&#36;',
    'EGP': '&#163;',
    'SVC': '&#36;',
    'EUR': '&#8364;',
    'FKP': '&#163;',
    'FJD': '&#36;',
    'GHS': '&#162;',
    'GIP': '&#163;',
    'GTQ': '&#81;',
    'GGP': '&#163;',
    'GYD': '&#36;',
    'HNL': '&#76;',
    'HKD': '&#36;',
    'HUF': '&#70;&#116;',
    'ISK': '&#107;&#114;',
    'INR': '&#8377;',
    'IDR': '&#82;&#112;',
    'IRR': '&#65020;',
    'IMP': '&#163;',
    'ILS': '&#8362;',
    'JMD': '&#74;&#36;',
    'JPY': '&#165;',
    'JEP': '&#163;',
    'KZT': '&#1083;&#1074;',
    'KPW': '&#8361;',
    'KRW': '&#8361;',
    'KGS': '&#1083;&#1074;',
    'LAK': '&#8365;',
    'LBP': '&#163;',
    'LRD': '&#36;',
    'MKD': '&#1076;&#1077;&#1085;',
    'MYR': '&#82;&#77;',
    'MUR': '&#8360;',
    'MXN': '&#36;',
    'MNT': '&#8366;',
    'MZN': '&#77;&#84;',
    'NAD': '&#36;',
    'NPR': '&#8360;',
    'ANG': '&#402;',
    'NZD': '&#36;',
    'NIO': '&#67;&#36;',
    'NGN': '&#8358;',
    'NOK': '&#107;&#114;',
    'OMR': '&#65020;',
    'PKR': '&#8360;',
    'PAB': '&#66;&#47;&#46;',
    'PYG': '&#71;&#115;',
    'PEN': '&#83;&#47;&#46;',
    'PHP': '&#8369;',
    'PLN': '&#122;&#322;',
    'QAR': '&#65020;',
    'RON': '&#108;&#101;&#105;',
    'RUB': '&#1088;&#1091;&#1073;',
    'SHP': '&#163;',
    'SAR': '&#65020;',
    'RSD': '&#1044;&#1080;&#1085;&#46;',
    'SCR': '&#8360;',
    'SGD': '&#36;',
    'SBD': '&#36;',
    'SOS': '&#83;',
    'ZAR': '&#82;',
    'LKR': '&#8360;',
    'SEK': '&#107;&#114;',
    'CHF': '&#67;&#72;&#70;',
    'SRD': '&#36;',
    'SYP': '&#163;',
    'TWD': '&#78;&#84;&#36;',
    'THB': '&#3647;',
    'TTD': '&#84;&#84;&#36;',
    'TRY': '&#;',
    'TVD': '&#36;',
    'UAH': '&#8372;',
    'GBP': '&#163;',
    'USD': '&#36;',
    'UYU': '&#36;&#85;',
    'UZS': '&#1083;&#1074;',
    'VEF': '&#66;&#115;',
    'VND': '&#8363;',
    'YER': '&#65020;',
    'ZWD': '&#90;&#36;'
};

function getCurrencySymbol(code) {
    return currencyCodes[code] ? j$('<div>').html(currencyCodes[code]).text() : code;
}

function hideLoading() {
    j$('#spinner').hide();
}

function showLoading() {
    j$('#spinner').show();
}

function chargeComplete(newCard) {
    hideLoading();
    j$('.payment-form').hide();
    j$('.charge-output').show();
    j$('.payment-button').removeProp("disabled");
    scrollUp();
}

function addorReplaceCard() {
    showLoading();
    j$('.existingcards').hide();
    j$('.newcardform').show();
    j$('.replacecard-button').hide();
    hideLoading();
}

function scrollUp() {
    j$(window).scrollTop(0);
    j$('html').scrollTop(0);
    j$('body').scrollTop(0);
}

function addNewCard() {
    j$('.payment-button').prop("disabled", 'disabled');
    showLoading();
    var saveCard = j$('#save-card').is(':checked');
    var paymentRequest = {};
    stripe.createToken(CardElements[0]).then(function(result) {
        if (result.error) {
            var errorElement = document.getElementById('card-errors');
            errorElement.textContent = result.error.message;
            hideLoading();
            j$('.payment-button').removeAttr("disabled");
        } else {
            paymentRequest.paymentMethod = 'new-card';
            paymentRequest.stripeToken = result.token.id;
            paymentRequest.saveCard = saveCard;
            saveNewCardToken(JSON.stringify(paymentRequest));
        }
    })
}

function getPublishableKey() {
    var stripePublishableKey = j$('#stripePublishableKey').val();
    return stripePublishableKey;
}

function getAllowSaveCard() {
    const urlParams = new URLSearchParams(window.location.search);
    var saveCard = urlParams.get('saveCard');
    if (saveCard == 'false') {
        j$('#save-card').prop('checked', false);
    }else{
        j$('#save-card').prop('checked', true);
    }
    return j$('#save-card').is(':checked');
}

function initInputElementsEventListener() {
    // Floating labels
    var StripeFloatinginputs = document.querySelectorAll('.stripe-label-input');
    Array.prototype.forEach.call(StripeFloatinginputs, function (StripeFloatinginput) {
        StripeFloatinginput.addEventListener('focus', function () {
            StripeFloatinginput.classList.add('focused');
        });
        StripeFloatinginput.addEventListener('blur', function () {
            StripeFloatinginput.classList.remove('focused');
        });
        StripeFloatinginput.addEventListener('keyup', function () {
            if (StripeFloatinginput.value.length === 0) {
                StripeFloatinginput.classList.add('empty');
            } else {
                StripeFloatinginput.classList.remove('empty');
            }
        });
    });
}

function registerStripeCardLayout() {
    hideLoading();
    stripe = Stripe(getPublishableKey()); 
    var elements = stripe.elements({
        fonts: [{
            cssSrc: 'https://fonts.googleapis.com/css?family=Source+Code+Pro',
        }, ],
        // Stripe's examples are localized to specific languages, but if
        // you wish to have Elements automatically detect your user's locale,
        // use `locale: 'auto'` instead.
        locale: 'auto',
    });

    var elementStyles = {
        base: {
            color: '#FFFFFF',
            fontWeight: 500,
            fontFamily: 'Source Code Pro, Consolas, Menlo, monospace',
            fontSize: '16px',
            fontSmoothing: 'antialiased',
            '::placeholder': {
                color: '#CFD7DF',
            },
            ':-webkit-autofill': {
                color: '#e39f48',
            },
        },
        invalid: {
            color: '#E25950',
            '::placeholder': {
                color: '#FFCCA5',
            },
        },
    };

    var elementClasses = {
        focus: 'focused',
        empty: 'empty',
        invalid: 'invalid',
    };
    
    var cardNumberElement = elements.create('cardNumber', {
        style: elementStyles,
        classes: elementClasses,
        placeholder: 'Card Number',
        showIcon : true,
        iconStyle: 'solid',
    });
    cardNumberElement.mount('#stripe-card-number');

    var cardExpiryElement = elements.create('cardExpiry', {
        style: elementStyles,
        classes: elementClasses,
    });
    cardExpiryElement.mount('#stripe-card-expiry');

    var cardCvcElement = elements.create('cardCvc', {
        style: elementStyles,
        classes: elementClasses,
    });
    cardCvcElement.mount('#stripe-card-cvc');

    CardElements = [cardNumberElement, cardExpiryElement, cardCvcElement];
    var errorElement = document.getElementById('card-errors');
    var savedErrors = {};
    //Iterate Over Card Elements and Handle events
    CardElements.forEach(function (CardElement, idx) {
        // Listen for errors from each Element, and show error messages in the UI.
        CardElement.on('change', function (event) {
            console.log('event.error ' + event.error);
            console.table(event.error);
            console.log('savedErrors ' + (savedErrors == undefined) );
            console.table(savedErrors);
            if (event.error) {
                errorElement.classList.add('visible');
                savedErrors[idx] = event.error.message;
                errorElement.textContent = event.error.message;
            } else {
                savedErrors[idx] = null;

                // Loop over the saved errors and find the first one, if any.
                var nextError = Object.keys(savedErrors)
                    .sort()
                    .reduce(function (maybeFoundError, key) {
                        return maybeFoundError || savedErrors[key];
                    }, null);

                if (nextError) {
                    // Now that they've fixed the current error, show another one.
                    errorElement.textContent = nextError;
                } else {
                    // The user fixed the last error; no more errors.
                    errorElement.classList.remove('visible');
                    errorElement.textContent = '';
                }
            }

            console.log('event.error ' + event.error);
            console.table(event.error);
            console.log('savedErrors ' + (savedErrors == undefined) );
            console.table(savedErrors);

        });
    });

    j$('.charge-output').hide();
}

function initCustomLabels() {
    if (j$('#customLabels').length > 0) {
        customLabels = JSON.parse(j$('#customLabels').val());
    }
}
function hidestripeErrorBlock(){
    showLoading();
    resetStripeError();
    startup();
    j$('.payment-form').show();
    hideLoading();
}

function startup() {
    j$ = jQuery.noConflict();

    j$(document).ready(function () {

        if (j$('#stripe-card-number').length > 0) {
            initInputElementsEventListener();
            registerStripeCardLayout();
        } else {
            hideLoading();
        }

        initCustomLabels();

        var isallowdtoSaveCard = getAllowSaveCard();
        j$('.payment-form-body').show();
        var cardsExists = j$('#cardsExists').val();
        if (cardsExists == 'true') {
            j$('#newcardform').hide();
        } else {
            j$('.newcardform').show();
        }

    });
}

startup();