public without sharing class PaymentMethodsController {
    private static StripeService stripeService = new StripeService();
    private static StripeRestService stripeRest = new StripeRestService();
    private static CustomLabelsService customLabelsService = new CustomLabelsService();
	private static TransactionService txnService = new TransactionService();
    
    public List<Stripe.Card> cards { get; set; }
    public Stripe.Card newCard { get; set; }

    public String contactUUID { get; set; }
    public String stripeCustomerId { get; set; }
    public String defaultPaymentMethodId { get; set; }
    public String newPaymentMethodId { get; set; }
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

    public Contact contact { get; set; }

    public PaymentMethodsController() {
        contactUUID = ApexPages.currentPage().getParameters().get('reqid');
        contact = [SELECT Id, Name, LastName, FirstName, Member_Type__c, Phone_Number__c, Formatted_Phone_Number__c,
            Membership_Type__c, Gender__c, StripeCustomerId__c, Default_Payment_Method__c, UUID__c,
            AccountId, Account.Name, Account.OwnerId, Account.Plivo_Country_Code__c,
            Account.Plivo_Sender_Id__c, Account.Plivo_PHLO_Id__c FROM Contact WHERE UUID__c =: contactUUID
        ];
        assert(!(contact == null), 'No Payment Methods found');

        initStripeProps();

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

    public void initStripeProps() {
        stripeError = null;
        try {
            if ((contact != null) && (contact.AccountId != null)) {
                apiKeyWrap = PMA_SearchController.fetchStripeApiToken(contact.AccountId);
                organization = apiKeyWrap.Name;
                stripePublishableKey = apiKeyWrap.PublicKey;
                stripeAccessToken = apiKeyWrap.accessToken;
                appMode = apiKeyWrap.testMode;
                defaultPaymentMethodId = contact.Default_Payment_Method__c;
                if (String.isBlank(stripeAccessToken)) {
                    assert(false, System.Label.error_message_stripe_setup_error);
                }
                assert(organization != null, System.Label.error_message_invalid_organization);
                assert(stripePublishableKey != null, System.Label.error_message_stripe_setup_error);

                cards = stripeRest.getCards(contact.StripeCustomerId__c);

            }
        } catch (Stripe.RestException ex) {
            Stripe.ErrorResponse CardError;
            CardError = ex.errorResponse;
            stripeError = CardError.error.message;
            System.debug('stripeError ex ' + ex);
            System.debug('stripeError ' + stripeError);
        } catch (JSONException ex) {
            error = System.Label.error_message_bad_request;
        }
        error = null;
    }

    public void saveNewCard() {
        error = null;
        stripeError = null;        
        try {
            initStripeProps();
            Stripe.UserPaymentRequest stripePaymentRequest = new Stripe.UserPaymentRequest();
            stripePaymentRequest = (Stripe.UserPaymentRequest) JSON.deserialize(stripePaymentRequestJson, Stripe.UserPaymentRequest.class);
            stripeCustomerId = contact.StripeCustomerId__c;
            String stripeToken = stripePaymentRequest.stripeToken == null ? stripePaymentRequest.bankToken : stripePaymentRequest.stripeToken;

            Map < String, Object > metadata = new Map < String, Object > ();
            metadata.put('contactId', contact.Id);
            metadata.put('accountId', contact.AccountId);
            System.debug('stripeAccessToken=' + stripeAccessToken);
            newCard = stripeRest.createCard(stripeCustomerId, stripeToken, metadata, stripeAccessToken);
            System.debug('Created new card for customer=' + stripeCustomerId + ' with stripe card id=' +
            newCard.id);
            newPaymentMethodId = newCard.id;
            stripeRest.setDefaultPaymentSource(stripeCustomerId, newPaymentMethodId, stripeAccessToken);

        } catch (Stripe.RestException ex) {
            Stripe.ErrorResponse CardError;
            CardError = ex.errorResponse;
            stripeError = CardError.error.message;
            System.debug('stripeError ex ' + ex);
            System.debug('stripeError ' + stripeError);
        } catch (JSONException ex) {
            error = System.Label.error_message_bad_request;
        }
        error = null;
    }

}