@IsTest
public class PMA_ContactInvocableHandlerTest {
	@TestSetup
    static void PMA_ContactInvocableHandlerTest(){
        PMA_TestDataFactory.createTestAccountWithContactsRecords(1, 3);  
    }
    
	@IsTest
    static void captureContactChangeRequestTest(){
		Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        List<Contact> fetchContact = getcurrAccount.Contacts;
        User cuser = PMA_SearchController.fetchCurrentUser();
        cuser.ContactId__c = fetchContact[0].Id;
        update cuser;
        System.debug('fetchContact test ' + fetchContact);
        Integer i = 0;
        for(Contact con : fetchContact){
            if(i == 0){
                Order__c orderRecord = new Order__c(Order_Type__c = 'Registration',
                                      Status__c = 'Active', Account__c = getcurrAccount.Id, Member__c = con.Id, UUID__c = '5688b376-e2c5-e576-f54d-a98eba9404c5'+ Integer.valueof((Math.random() * 1000)));
        		insert orderRecord;
            }
            i++;
        }
        Order__c fetchOrder = [SELECT Id,Name,Order_Type__c,Member__c,Member__r.Name,Member__r.Active__c, Member__r.Default_Payment_Method__c, Member__r.AllowComplimentaryOrders__c, Member__r.Age__c, Member__r.Birthdate,Vendor__c,Vendor__r.Name,Account__c,Account__r.Name,Status__c,Total_Price__c,UUID__c,CreatedDate,LastModifiedDate,OwnerId,
            (SELECT Id,Name,Order__c,Product__c,Product_Name__c,Quantity__c,List_Price__c,Line_Total_Price__c,Total_Price__c,Notes__c,CreatedDate,LastModifiedDate FROM Order_Items__r) FROM Order__c WHERE ( Order_Type__c = 'Registration' )  LIMIT 1];
        
        List<Contact> contactList = [SELECT Id, Name,FirstName,LastName,Email,Registration_Order_Created__c,Contact.AccountId,Contact.Phone_Number__c,Formatted_Phone_Number__c FROM Contact];

        List<PMA_ContactInvocableHandler.MyInvocableVariable> ivs = new List<PMA_ContactInvocableHandler.MyInvocableVariable>();
        for(Contact cont:contactList){
            PMA_ContactInvocableHandler.MyInvocableVariable iv = new PMA_ContactInvocableHandler.MyInvocableVariable();
            iv.newVal = cont;
            iv.oldVal = cont;
            iv.operationType = 'CREATE';
            iv.recId = cont.Id;
            iv.orderId = fetchOrder.Id; 
            ivs.add(iv);
        }
        PMA_ContactInvocableHandler.captureContactChangeRequest(ivs);
    }
}