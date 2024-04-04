public without sharing class ChargeController {
    private static StripeService stripeService = new StripeService();
    private static CustomLabelsService customLabelsService = new CustomLabelsService();
    
    @AuraEnabled
    public static Contact fetchVirtualTerminalcontact(){
        Id memberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        String PMAAccountName = '';
        String VirtualTerminalContactName = '';
        String VirtualTerminalContactFirstName = '';
        String VirtualTerminalContactLastName = '';
        // query current user information  
        User currentUserRecord = PMA_SearchController.fetchCurrentUser();
        if ( String.isNotBlank(currentUserRecord.ContactId) ){
            PMAAccountName = currentUserRecord.Contact.Account.Name;
        }
        
        if ( String.isNotBlank(currentUserRecord.ContactId__c) ){
            Contact fetchSFUserContact = ChatBotController.getContactDetails(currentUserRecord.ContactId__c);
            PMAAccountName = fetchSFUserContact.Account.Name;
        }

        if (String.isBlank(PMAAccountName)) {
            VirtualTerminalContactName = 'Virtual Terminal';
            VirtualTerminalContactFirstName = 'Virtual';
            VirtualTerminalContactLastName = 'Terminal';
        }else{
            VirtualTerminalContactName = PMAAccountName + ' Virtual Terminal';
            VirtualTerminalContactFirstName = PMAAccountName;
            VirtualTerminalContactLastName = 'Virtual Terminal';
        }
        System.debug('VirtualTerminalContactName ' + VirtualTerminalContactName);

        List < Contact > searchContact = new List < Contact > ();
        searchContact = [SELECT Id, Name, Account.Name, Account.Id FROM Contact WHERE Name =: VirtualTerminalContactName ];
        if (searchContact.size() == 0) { //Create New Contact
            Contact newContact = new Contact();
            newContact.FirstName = VirtualTerminalContactFirstName;
            newContact.LastName = VirtualTerminalContactLastName;
            newContact.RecordTypeId = memberRecordTypeId;
            newContact.Member_Type__c = 'Anonymous';
            insert newContact;
        }
        return [SELECT Id, Name, Email, Default_Payment_Method__c , AccountId , Account.Name, Account.Id, RecordType.Name, Member_Type__c FROM Contact WHERE Name =: VirtualTerminalContactName  LIMIT 1];
    }

    @AuraEnabled
    public static List<Payment_Intent__c> createPaymentRequests(List<ChargeRequest> chargeRequests) {
        System.debug('Charge controller , chargeRequests=' + chargeRequests);
        Id currentContactId = chargeRequests[0].contactId;
        Id currentAccountId = chargeRequests[0].accountId;
        PMA_SearchController.StripeApiTokensWrap apiKeyWrap = PosUtility.fetchStripeApiToken(currentAccountId);

        Contact searchContact = new Contact();
        if( String.isBlank(currentContactId) ){
            searchContact = fetchVirtualTerminalcontact();
        }

        List<Payment_Intent__c> paymentRequests = new List<Payment_Intent__c>();
        for (ChargeRequest chargeRequest : chargeRequests) {
            Id contactId = String.isNotBlank(chargeRequest.contactId) ? chargeRequest.contactId : searchContact.Id;
            Id accountId = String.isNotBlank(chargeRequest.contactId) ? chargeRequest.accountId : searchContact.accountId;
            Id orderId = chargeRequest.orderId;
            String email = String.isNotBlank(chargeRequest.contactId) ? chargeRequest.email : searchContact.email;
            Double amount = chargeRequest.amount;
            String frequency = chargeRequest.frequency;
            Date firstChargeDate = chargeRequest.firstChargeDate;
            String paymentType = chargeRequest.paymentType;
            String paymentName =  chargeRequest.paymentName;

            paymentRequests.add(PaymentIntentService.createNewPaymentIntent(paymentName , contactId, accountId, orderId, paymentType, amount, email, frequency, firstChargeDate));

        }
        return paymentRequests;
    }


    @AuraEnabled
    public static Stripe.Payment processPayments(List<Payment_Intent__c> paymentRequests, Stripe.UserPaymentRequest stripePaymentRequest) {
        String stripeError;
        Stripe.Payments paymentResponses = new Stripe.Payments();
        System.debug('Payment request =' + paymentRequests +
                ', stripe payment request=' + stripePaymentRequest);
        try{
            paymentResponses =  stripeService.processPayments(paymentRequests, stripePaymentRequest);
        } catch (Stripe.RestException ex) {
            Stripe.ErrorResponse CardError;
            CardError = ex.errorResponse;
            stripeError = CardError.error.message;
            throw new AuraHandledException( stripeError );
        }         
        return ( paymentResponses.payments.size() > 0 ) ? paymentResponses.payments[0] : paymentResponses.payments[0];
    }
    
    public class ChargeRequest {
        @AuraEnabled public String paymentName { get; set; }
        @AuraEnabled public Id contactId { get; set; }
        @AuraEnabled public Id accountId { get; set; }
        @AuraEnabled public Id opportunityId { get; set; }
        @AuraEnabled public Id orderId { get; set; }
        @AuraEnabled public String paymentType { get; set; }
        @AuraEnabled public Double amount { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String frequency { get; set; }
        @AuraEnabled public Date firstChargeDate { get; set; }
    }

    @AuraEnabled
    public static List<Stripe.Card> getUserCards(Id contactId) {
        return stripeService.getPaymentMethods(contactId).cards;
    }

    @AuraEnabled
    public static Stripe.PaymentMethods getPaymentMethods(Id contactId) {
        return stripeService.getPaymentMethods(contactId);
    }

    @AuraEnabled
    public static String getCurrency() {
        return UserInfo.getDefaultCurrency();
    }

    @AuraEnabled
    public static String getOrgUrl() {
        return PMA_ExternalSiteFormsUtility.getOrgUrl();
    }

    @AuraEnabled
    public static PMA_SearchController.StripeApiTokensWrap getProperties() {
        try{
            PMA_SearchController.CurrentUserWrap cuserWrap = PMA_SearchController.fetchCurrentUserWrapper();
            PMA_SearchController.StripeApiTokensWrap apiKeyWrap =
                PMA_SearchController.fetchStripeApiToken(cuserWrap.contactRecord.AccountId);
            return apiKeyWrap;
        }catch(Exception ex){
            throw new PMA_SearchController.SYS_AuthException(
                'Failed to Find SYS_OAuthConfig Record for Current Loggeedin User', ex);
        }
    }
    @AuraEnabled
    public static PMA_SearchController.StripeApiTokensWrap getProperties(String recordId) {
        try{
            PMA_SearchController.StripeApiTokensWrap apiKeyWrap = new PMA_SearchController.StripeApiTokensWrap();
            String objectapiname = String.isNotBlank(recordId) ? Id.valueOf(recordId).getSObjectType().getDescribe().getName() : '';

            if(objectapiname == 'Account') {
                apiKeyWrap = PosUtility.fetchStripeApiToken(recordId);
            } else {
                PMA_SearchController.CurrentUserWrap cuserWrap = PMA_SearchController.fetchCurrentUserWrapper();
                apiKeyWrap = PMA_SearchController.fetchStripeApiToken(cuserWrap.contactRecord.AccountId);
            }
            return apiKeyWrap;
        }catch(Exception ex){
            throw new PMA_SearchController.SYS_AuthException(
                'Failed to Find SYS_OAuthConfig Record for Current Loggeedin User', ex);
        }
    }

    @AuraEnabled
    public static Map<String, Object> getObjectAndLabels() {
        Map<String, Object> labels = new Map<String, Object>();
        labels.putAll(customLabelsService.getCustomLabels());

        return labels;
    }
    
    @AuraEnabled
    public static contact Contactrecordfetch(Id recordId) {
        contact contactdata= PosUtility.ContactrecordfetchUtility(recordId);
        return contactdata;
    }
}