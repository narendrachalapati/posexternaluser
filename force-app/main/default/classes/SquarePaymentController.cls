public without sharing class SquarePaymentController {
    
    public string memberrecordid {get; set; }
    public string AccountrecId {get; set; }
    public string uuid {get; set; }
    public string todorecordId {get; set; }
    public string cardToken {get; set; }
    public string payableOrderId {get; set; }
    public string payableAppointmentId {get; set; }
    public string paymentId {get; set; }
    public Boolean isCardcreated {get; set; }
    public card__c card {get; set; }
    public string cardId {get; set; }
    
    public Decimal Amount {
        get{ return ((Amount!= NULL) ? Amount : 0.0);}
        set;
    }
    
    public Decimal AmountTOpay {
        get{ return ((AmountTOpay!= NULL) ? AmountTOpay : 0.0);}
        set;
    }
    
    public string Lastfourdegits {get; set; }
    public string selectedcardId {get; set; }
    public list<card__c> cardslist {get; set; }
    public string paymentCollectioncardId {get; set; }
    public string activeTabPanel {
        get {
            return (String.isNotBlank(activeTabPanel)) ? activeTabPanel : 'add-card-tab';
        }
        set;
    }
    
    public class SquarePaymentControllerException extends Exception {}
    
    public void fetchCustomerCards() {
        try{
            AmountTOpay = SquarePaymentUtility.gettingAmountForPayment(payableOrderId, payableAppointmentId, Amount,memberrecordid);
            
            cardslist = new list<card__c>();
            system.debug('cardId' + cardId + card);
            Map<string,string> headersmap = new Map<string,string>();
            Contact con = [SELECT Square_Id__c from Contact wHERE Id =:memberrecordid];
            if(String.isNotBlank(con.Square_Id__c)) {
                string customerId = con.Square_Id__c;
                string callouturl = 'https://connect.squareupsandbox.com/v2/cards?customer_id='+customerId+'&include_disabled=false';
                HttpResponse response = SquarePaymentUtility.buildOutboundHttpRequest(AccountrecId,'Square','Square_cards','UPSERT','GET',callouturl,'',headersmap);
                string responseBody = response.getBody();
                if(String.isNotBlank(responseBody)) {
                    List<String> childRecList = new List<String>();
                    Object jsonObject = JSON.deserializeUntyped(responseBody);
                    if (jsonObject instanceof Map<String, Object>) {
                        for(String key : ((Map<String, Object>)jsonObject).keySet()) {
                            Object currentObj = ((Map<String, Object>)jsonObject).get(key);
                            if (currentObj instanceof List<Object> ) {
                                //result.clear();
                                if (((List<Object>)currentObj).size() > 0) {
                                    for(Object obj:(List<Object>)currentObj){
                                        if(obj instanceof Map<String, Object>) {
                                            String objString = JSON.serialize(obj);
                                            System.debug('objStringNDR' + objString );
                                            childRecList.add(objString);
                                            System.debug('childRecListNDR' + childRecList );
                                        }
                                    }
                                }
                                for( String childrec : childRecList ){
                                    Object cardJsonObject = System.JSON.deserializeUntyped(childrec);
                                    Object dataObj = new Map<String, Object>();
                                    Object objectChildObj = new Map<String, Object>();
                                    Object cardChildObj = new Map<String, Object>();
                                    
                                    ((Map<String, Object>)cardChildObj).put('card', cardJsonObject);
                                    ((Map<String, Object>)objectChildObj).put('object', cardChildObj);
                                    ((Map<String, Object>)dataObj).put('data', objectChildObj);
                                    childrec = JSON.serialize(dataObj);
                                    
                                    List<sObject>  sobjectList = SYS_Transformer.getSObjectsToUpsert(new List<String>{childrec},'card',true);
                                    System.debug('sobjectListNDR' + sobjectList);
                                    if(sobjectList.size()>0){
                                        if (sobjectList[0] instanceof card__c) {
                                            card__c card = (card__c)sobjectList[0];
                                            if(card != null){
                                                cardslist.add(card);
                                            }
                                            
                                            System.debug('card NDR' + card + cardslist);
                                        }
                                    }
                                    System.debug('sobjectListNDR' + sobjectList);
                                }
                                
                            }
                        }
                    }
                }
            } else {
                system.debug('########################## Square Id is not defined for customer##############');
                throw new SquarePaymentControllerException('Square Id is not defined for customer');
            }
            
            //Check if there are any Exsiting Payment methods
            if( cardslist.size() > 0 ) {
                activeTabPanel = 'saved-cards-tab';
            } else {
                activeTabPanel = 'add-card-tab';
                system.debug('########################## customer not have cards ##############');
                throw new SquarePaymentControllerException('fetchCustomerCards:: customer not have cards');
            }
        } catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            Apexpages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.FATAL, e.getMessage() + '\n' + e.getStackTraceString()));
        }
    }
    
    public void changeActiveTabPanel() {
        if(String.isBlank(activeTabPanel)) {
            activeTabPanel = 'add-card-tab';
        }
    }
    
    public void onClickCardinfo() {
        try{
            system.debug('cardId' + selectedcardId + card);
            card__c card = [select Square_Id__c,Id from card__c where Square_Id__c =:selectedcardId];
            if(card != null){
                paymentCollectioncardId = card.Square_Id__c;
            }else{
                Card__c newcard = new Card__c ();
                newcard.Customer__c = memberrecordid;
                newcard.Account__c =  AccountrecId;
                newcard.Square_Id__c = selectedcardId;
                newcard.Synchronous__c = true;
                insert card;
                card__c cardfetch = [select Square_Id__c,Id from card__c where Square_Id__c =:selectedcardId];
                paymentCollectioncardId = cardfetch.Square_Id__c;
            }
            
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
    public void Paymentcreation() {
        try{
            system.debug('selectedcardIdNDRcontroller' + paymentCollectioncardId);
            Payments__c payment = SquarePaymentUtility.paymentRecCreationUtility( memberrecordid, AccountrecId, AmountTOpay, paymentCollectioncardId);
            paymentId = payment.Id;
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
    public void PaymentsyncAPIcall() {
        try{
            SquarePaymentUtility.ApiCalloutSynchronousWithRecordId(AccountrecId,paymentId,'POST','INSERT','Square','Square_Payment');
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
}