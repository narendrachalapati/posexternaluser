public without sharing class SquarePaymentController {
  
    public string memberrecordid {get; set; }
    public string  AccountrecId {get; set; }
    public string  cardToken {get; set; }
    public Boolean  isCardcreated {get; set; }
    public card__c   card {get; set; }
    public  string  cardId {get; set; }
    public  Decimal  Amount {get; set; }
    public  string  Lastfourdegits {get; set; }
    public  string  selectedcardId {get; set; }
    public transient  list<card__c>  cardslist {get; set; }


 
 public void PaymentsyncAPIcall() {
  try{
    SquarePaymentUtility.paymentRecCreationUtility( memberrecordid, AccountrecId, Amount, selectedcardId);
      SquarePaymentUtility.ApiCalloutSynchronousWithRecordId(AccountrecId,card.Id,'POST','INSERT','Square','Square_Payment');
  } catch(DmlException e) {
        System.debug('The following exception has occurred: ' + e.getMessage());
    }
}
 public void fetchCustomerCards() {
  try{

        cardslist = new list<card__c>();
        system.debug('cardId' + cardId + card);
        Map<string,string> headersmap = new Map<string,string>();
       
        string callouturl = 'https://connect.squareupsandbox.com/v2/cards?customer_id=SVCC1607AWR9KGXG2C8GCVBXY8&include_disabled=false';
        HttpResponse response =  SquarePaymentUtility.buildOutboundHttpRequest(AccountrecId,'Square','Square_cards','UPSERT','GET',callouturl,'',headersmap);
        string responseBody =  response.getBody();
        List<String> childRecList = new List<String>();
       // CardsWrapper obj = CardsWrapper.parse(responseBody);

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
  } catch(DmlException e) {
        System.debug('The following exception has occurred: ' + e.getMessage());
    }
  }
  public void setorderID() {
    try{
          system.debug('cardId' + selectedcardId + card);
       } catch(DmlException e) {
          System.debug('The following exception has occurred: ' + e.getMessage());
   }
 }
 public void Paymentcreation() {
  try{
    system.debug('selectedcardIdNDRcontroller' + selectedcardId);
    SquarePaymentUtility.paymentRecCreationUtility( memberrecordid, AccountrecId, Amount, selectedcardId);
     // SquarePaymentUtility.ApiCalloutSynchronousWithRecordId(AccountrecId,card.Id,'POST','INSERT','Square','Square_cards');
  } catch(DmlException e) {
        System.debug('The following exception has occurred: ' + e.getMessage());
    }
}
}