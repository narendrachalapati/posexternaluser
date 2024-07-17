public without sharing class SquareCardController {
      
    public string memberrecordid {get; set; }
    public string AccountrecId {get; set; }
    public string cardToken {get; set; }
    public string paymentRecordId {get; set; }
    public Boolean isCardcreated {get; set; }
    public card__c card {get; set; }
    public string cardId {get; set; } 
    public decimal Amount {get; set; }
    
    public void initCardCmp() {
       System.debug('memberrecordid ' + memberrecordid);
    }
    
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
 //used for creating payment record when clicking on pay button
  public void cardPaymentcreation() {
    try{
      system.debug('selectedcardIdNDRcontroller' + cardToken);
      card__c card = [SELECT Square_Id__c from card__c where Id =:cardId];
      string  cardExId = card.Square_Id__c;
      if(string.isNotBlank(cardExId)){
       Payments__c payment = SquarePaymentUtility.paymentRecCreationUtility( memberrecordid, AccountrecId, Amount, cardExId);
      paymentRecordId = payment.Id;
      }else{
        system.debug('########################### cardExtId is coming as null############');
      }
     
    } catch(DmlException e) {
          System.debug('The following exception has occurred: ' + e.getMessage());
      }
  }
  //used for Api call om  payment  when clicking on pay button
  public void cardPaymentsyncAPIcall() {
    try{
     SquarePaymentUtility.ApiCalloutSynchronousWithRecordId(AccountrecId,paymentRecordId,'POST','INSERT','Square','Square_Payment');
    } catch(DmlException e) {
          System.debug('The following exception has occurred: ' + e.getMessage());
      }
  }
}