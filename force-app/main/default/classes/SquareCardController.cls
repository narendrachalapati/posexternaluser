public without sharing class SquareCardController {
      
    public transient string memberrecordid {get; set; }
    public transient  string  AccountrecId {get; set; }
    public transient string  cardToken {get; set; }
    public transient Boolean  isCardcreated {get; set; }
    public transient card__c   card {get; set; }
    public transient  string  cardId {get; set; }
  
       
    public void cardRecCreation() {
        card  = SquarePaymentUtility.cardRecCreationUtility(memberrecordid,AccountrecId,cardToken);
        if(card != null){
         isCardcreated = true;
        }
        
        system.debug('cardNDR' + card);
        cardId = card.Id;
    }
   public void cardApicallout() {
     try{
           system.debug('cardId' + cardId + card);
         SquarePaymentUtility.ApiCalloutSynchronousWithRecordId(AccountrecId,card.Id,'POST','INSERT','Square','Square_cards');
     } catch(DmlException e) {
           System.debug('The following exception has occurred: ' + e.getMessage());
    }
  }
 
   
}