public without sharing class TransactionController {
    private static StripeService stripeService = new StripeService();
    private static CustomLabelsService customLabelsService = new CustomLabelsService();
	private static TransactionService txnService = new TransactionService();
    
    public List<Stripe.Card> cards { get; set; }

    public String organization { get; set; }

    public String stripePaymentRequestJson { get; set; }
    public String error { get; set; }
    public String stripeError { get; set; }
    public static String stripePublishableKey { get; set; }
    public static String stripeAccessToken { get; set; }
    public Boolean appMode { get; set; }
    public static PMA_SearchController.StripeApiTokensWrap apiKeyWrap { get; set; }

    public String labelsJson { get; set; }
    public Map<String, Object> labels { get; set; }
    public List<Payment_Intent__c> paymentRequests { get; set; }
    public Payment_Intent__c paymentIntent { get; set; }
    public Stripe.Payments payments { get; set; }
    public Stripe.Payments paymentReceipt { get; set; }
    public Contact contact { get; set; }

    public TransactionController() {
        //Get Payment Request Details
        paymentRequests = PaymentIntentService.getPaymentRequestByUUID(ApexPages.currentPage().getParameters().get('reqid'));
        assert(!paymentRequests.isEmpty(), 'No payment requests found');
        if(!paymentRequests.isEmpty()){
            paymentIntent = paymentRequests[0];
            contact = [SELECT Id, Name, StripeCustomerId__c, AccountId, Account.Name, Account.OwnerId ,
            Account.Plivo_Country_Code__c,Account.Plivo_Sender_Id__c, Account.Plivo_PHLO_Id__c FROM Contact WHERE Id =:
            paymentIntent.Contact__r.Id];
            apiKeyWrap = PMA_SearchController.fetchStripeApiToken(paymentIntent.Account__c);
            if(paymentIntent.Status__c == 'payment_expired') {
                assert(false, 'Payment Request is Expired');
            }
            else if(paymentIntent.Status__c == 'payment_done') {
                assert(false, 'Payment is Completed');
                paymentReceipt = new Stripe.Payments();
                // List<Payment> payment = new List<Payment>();
                paymentReceipt.registerPayment(paymentIntent);
                Transaction__c completedTxn = txnService.getTransactionPaymentIntentId(paymentIntent.Id);
                paymentReceipt.registerPayment(completedTxn);

            }
        }
        if( String.isBlank(apiKeyWrap.accessToken) ){
            assert( false, System.Label.error_message_stripe_setup_error);
        } 

        organization = apiKeyWrap.Name;
        stripePublishableKey = apiKeyWrap.PublicKey;
        stripeAccessToken = apiKeyWrap.accessToken;
        appMode = apiKeyWrap.testMode;
        assert(organization != null, System.Label.error_message_invalid_organization);
        assert(stripePublishableKey != null, System.Label.error_message_stripe_setup_error);
		
        //Custom Labels Collection
        labels = customLabelsService.getCustomLabels();
        labelsJson = JSON.serialize(labels);

    }
    public void assert(Boolean condition, String message) {
        if (!condition) {
            this.error = message;
        }
    }

    public void resetStripeError(){
        stripeError = null;
    }

    public void refreshStripeError(){
        stripeError = this.stripeError;
    }


    public void initCards() {
        stripeError = null;
        if(!paymentRequests.isEmpty()){
            try {
                Stripe.PaymentMethods paymentMethods = stripeService.getPaymentMethods(contact.Id);
                cards = paymentMethods.cards;
            } catch (Stripe.RestException ex) {
                Stripe.ErrorResponse CardError;
                CardError = ex.errorResponse;
                stripeError = CardError.error.message;
            }
        }
    }

    public void charge() {
        error = null;
        stripeError = null;
        Stripe.UserPaymentRequest stripePaymentRequest = new Stripe.UserPaymentRequest();
        try {
            stripePaymentRequest = (Stripe.UserPaymentRequest) JSON.deserialize(stripePaymentRequestJson, Stripe.UserPaymentRequest.class);
            payments = stripeService.processPayments(paymentRequests, stripePaymentRequest);
        } catch (Stripe.RestException ex) {
            Stripe.ErrorResponse CardError;
            CardError = ex.errorResponse;
            stripeError = CardError.error.message;
        }catch (JSONException ex) {
            error = System.Label.error_message_bad_request;
        }
        error = null;
    }
}