public class StripeRestService {
    public static String STRIPE_KEY { get; set; }
    
    public Stripe.Customer getCustomer(String customerId, String stripeAccessToken) {
        STRIPE_KEY = stripeAccessToken;
        return (Stripe.Customer) get('customers/' + customerId, Stripe.Customer.class);
    }
    public Stripe.Customer createCustomer(String description , String email ,String lastName , String Phonenumber) {
        String emailParam = String.isNotBlank(email) ? '&email=' + email : '';
        return (Stripe.Customer) post('customers', 'description=' + description + emailParam + '&name=' + lastName + '&phone=' + Phonenumber, Stripe.Customer.class);
    }

    public Stripe.Card createCard(String customerId, String stripeToken, Map<String, Object> metadata, String stripeAccessToken) {
        String metadataParams = '';
        List<String> keys = new List<String>(metadata.keySet());
        keys.sort();
        for (String key : keys) {
            metadataParams += '&metadata[' + key + ']=' + metadata.get(key);
        }
        STRIPE_KEY = stripeAccessToken;
        return (Stripe.Card) post('customers/' + customerId + '/sources', 'source=' + stripeToken + metadataParams, Stripe.Card.class);
    }

    public List<Stripe.Card> getCards(String customerId) {
        Stripe.CardsResponse cardsResp = (Stripe.CardsResponse) get('customers/' + customerId + '/sources?object=card', Stripe.CardsResponse.class);
        return cardsResp.data;
    }
	/*
    public Stripe.BankAccount createBankAccount(String customerId, String stripeToken) {
        return (Stripe.BankAccount) post('customers/' + customerId + '/sources', 'source=' + stripeToken, Stripe.BankAccount.class);
    }
	*/
    public List<Stripe.BankAccount> getBankAccounts(String customerId) {
        Stripe.BankAccountsResponse banksResp = (Stripe.BankAccountsResponse) get('customers/' + customerId + '/sources?object=bank_account', Stripe.BankAccountsResponse.class);
        return banksResp.data;
    }
	/*
    public Stripe.BankAccount verifyBankAccount(String customerId, String bankSourceId, Integer amount1, Integer amount2) {
        Stripe.BankAccount bankAccount = (Stripe.BankAccount)
                post('customers/' + customerId + '/sources/' + bankSourceId + '/verify',
                        'amounts[]=' + amount1 + '&amounts[]=' + amount2,
                        Stripe.BankAccount.class);
        return bankAccount;
    }
	*/
    public void setDefaultPaymentSource(String customerId, String paymentSourceId, String stripeAccessToken) {
        STRIPE_KEY = stripeAccessToken;
        post('customers/' + customerId, 'default_source=' + paymentSourceId, Stripe.Customer.class);
    }

    public Stripe.Charge charge(Long amount, String currencyType, String description, String source, Map<String, Object> metadata) {
        String metadataParams = '';
        List<String> keys = new List<String>(metadata.keySet());
        keys.sort();
        for (String key : keys) {
            metadataParams += '&metadata[' + key + ']=' + metadata.get(key);
        }
        return (Stripe.Charge) post(
                'charges',
                'amount=' + amount + '&currency=' + currencyType + '&description=' + description + source + metadataParams,
                Stripe.Charge.class);
    }
/*
    public Stripe.Plan createPlan(Long amount, String currencyType, String interval, String productName) {
        return (Stripe.Plan) post(
                'plans',
                'amount=' + amount + '&currency=' + currencyType + '&interval=' + interval + '&product[name]=' + productName,
                Stripe.Plan.class);
    }

    public Stripe.Product createProduct(String productName) {
        return (Stripe.Product) post(
                'products',
                'name=' + productName + '&type=service',
                Stripe.Product.class);
    }
    */
/*
    public Stripe.Subscription createSubscription(String plan, String customerId, Payment_Intent__c paymentRequest) {
        DateTime startDate = paymentRequest.First_Charge_Date__c;
        DateTime startDateTime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day());
        return (Stripe.Subscription) post(
                'subscriptions',
                'items[0][plan]=' + plan + '&customer=' + customerId + '&metadata[paymentRequestId]=' + paymentRequest.Id,
//                '&start_date=' + startDateTime.getTime()/1000,
                Stripe.Subscription.class);
    }
    */
/*
    public Stripe.WebHook createWebhook(String url, boolean live) {
        String params = 'url=' + url + '&enabled_events[]=*&connect=true';
        return (Stripe.WebHook) sendStripeRequestUsingUserAccountKey('webhook_endpoints', 'POST', params, Stripe.Webhook.class,
                live ? applicationPropertiesService.getAccessKeyLive() : applicationPropertiesService.getAccessKeyTest());
    }

    public List<Stripe.WebHook> getWebHooks(boolean live) {
        return ((Stripe.WebHooks) sendStripeRequestUsingUserAccountKey('webhook_endpoints', 'GET', null, Stripe.WebHooks.class,
                live ? applicationPropertiesService.getAccessKeyLive() : applicationPropertiesService.getAccessKeyTest())).data;
    }

    public Stripe.Invoice getInvoice(String id) {
        return (Stripe.Invoice) get('invoices/' + id, Stripe.Invoice.class);
    }

    public Stripe.Subscription getSubscription(String id) {
        return (Stripe.Subscription) get('subscriptions/' + id, Stripe.Subscription.class);
    }
*/
    private Object get(String endPoint, Type responseType) {
        return sendStripeRequestUsingUserAccountKey(endPoint, 'GET', null, responseType);
    }

    private Object post(String endPoint, String body, Type responseType) {
        return sendStripeRequestUsingUserAccountKey(endPoint, 'POST', body, responseType);
    }

    private Object userGet(String endPoint, Type responseType) {
        return sendStripeRequestUsingUserAccountKey(endPoint, 'GET', null, responseType);
    }

    private Object userPost(String endPoint, String body, Type responseType) {
        return sendStripeRequestUsingUserAccountKey(endPoint, 'POST', body, responseType);
    }
/*
    private Object adminGet(String endPoint, Type responseType) {
        return sendStripeRequestUsingAdminAccountKey(endPoint, 'GET', null, responseType);
    }

    private Object adminPost(String endPoint, String body, Type responseType) {
        return sendStripeRequestUsingAdminAccountKey(endPoint, 'POST', body, responseType);
    }

    private Object sendStripeRequest(String endPoint, String method, String body, Type responseType) {
        return performStripeRequest(
                'https://api.stripe.com/v1/' + endPoint,
                applicationPropertiesService.getAdminStripeAccountKey(),
                applicationPropertiesService.getClientStripeAccountId(),
                method,
                body,
                responseType
        );
       
    }
	*/

    private Object sendStripeRequestUsingUserAccountKey(String endPoint, String method, String body, Type responseType) {
        if( String.isBlank(STRIPE_KEY) && String.isNotBlank(TransactionController.stripeAccessToken) ){
            STRIPE_KEY = TransactionController.stripeAccessToken;
        }else if( String.isBlank(STRIPE_KEY) && String.isNotBlank(PaymentMethodsController.stripeAccessToken) ){
            STRIPE_KEY = PaymentMethodsController.stripeAccessToken;
        }else{
            //TODO Get Default Stripe Setting
        }        
        return sendStripeRequestUsingUserAccountKey(endPoint, method, body, responseType, STRIPE_KEY);
    }

    private Object sendStripeRequestUsingUserAccountKey(String endPoint, String method, String body, Type responseType, String userAccountAccessKey) {
        return performStripeRequest(
                'https://api.stripe.com/v1/' + endPoint,
                userAccountAccessKey,
                null,
                method,
                body,
                responseType
        );
    }
	/*
    private Object sendStripeRequestUsingAdminAccountKey(String endPoint, String method, String body, Type responseType) {
        if( String.isNotBlank(TransactionController.stripeAccessToken) ){
            STRIPE_KEY = TransactionController.stripeAccessToken;
        }else{
            //TODO Get Default Stripe Setting
        }    
        return performStripeRequest(
                'https://api.stripe.com/v1/' + endPoint,
                STRIPE_KEY,
                null,
                method,
                body,
                responseType
        );
    }

    public Stripe.AuthToken getStripeConnectAuthDetails(String code) {
        String body = 'code=' + code + '&grant_type=authorization_code';
        if( String.isNotBlank(TransactionController.stripeAccessToken) ){
            STRIPE_KEY = TransactionController.stripeAccessToken;
        }else{
            //TODO Get Default Stripe Setting
        }    
        return (Stripe.AuthToken) performStripeRequest(
                'https://connect.stripe.com/oauth/token',
                STRIPE_KEY,
                null,
                'POST',
                body,
                Stripe.AuthToken.class
        );
    }
    */

    private Object performStripeRequest(
            String qualifiedEndPoint,
            String apiKey,
            String stripeAccountId,
            String method,
            String body,
            Type responseType) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String stripeUrl = qualifiedEndPoint;
        request.setEndpoint(stripeUrl);
        request.setMethod(method);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Authorization', 'Bearer ' + apiKey);
        if (stripeAccountId != null) {
            request.setHeader('Stripe-Account', stripeAccountId);
        }

        System.debug('Stripe account id=' + stripeAccountId + ', api key=' + apiKey);

        if (body != null) {
            request.setBody(body);
        }

        System.debug('[Stripe api request] endpoint=' + stripeUrl + ', method=' + method + ', body=' + body);
        HttpResponse response = http.send(request);

        System.debug('[Stripe api response] endpoint=' + stripeUrl + ', status=' + response.getStatusCode() + ', ' +
                'response=' + response.getBody());

        if (response.getStatusCode() != 200) {
            Stripe.ErrorResponse errorResp = (Stripe.ErrorResponse) JSON.deserialize(response.getBody(), Stripe.ErrorResponse.class);
            throw new Stripe.RestException(errorResp);
        }
		return JSON.deserialize(StripeService.escape(response.getBody()), responseType);
    }
}