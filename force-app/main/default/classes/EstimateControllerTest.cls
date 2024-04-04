@IsTest
public with sharing class EstimateControllerTest {
    @TestSetup
    static void EstimateControllerTest(){
        PMA_TestDataFactory.createTestAccountWithContactsRecords(1, 3);  
    }
    @IsTest
    static void EstimateOrderdataTest() {
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        List<Contact> fetchContact = getcurrAccount.Contacts;
        System.debug('fetchContact test ' + fetchContact);
        for(Contact con : fetchContact){
        	PMA_TestDataFactory.createTestOrderRecords(getcurrAccount.Id, con.Id,'Estimate');
        }
        Order__c fetchOrder = PMA_TestDataFactory.getTestOrderwithOrderItemRecords();

        EstimateController estmate = new EstimateController();
        estmate.memberrecordid = fetchContact[0].Id;
        estmate.EstimateOrderdata();
       System.assertEquals('Estimate', fetchOrder.Status__c);
    }
    @IsTest
    static void EstimateOrderdataCancelTest() {
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        List<Contact> fetchContact = getcurrAccount.Contacts;
        System.debug('fetchContact test ' + fetchContact);
        for(Contact con : fetchContact){
        	PMA_TestDataFactory.createTestOrderRecords(getcurrAccount.Id, con.Id,'Estimate');
        }
        Order__c fetchOrder = PMA_TestDataFactory.getTestOrderwithOrderItemRecords();
       
        EstimateController estmate = new EstimateController();
        estmate.orderdata = fetchOrder;
        estmate.cancelOrderdata();
        Order__C order = [SELECT Status__c from Order__c where Id =:fetchOrder.Id];
        System.assertEquals('Cancelled', order.Status__c);
        
    }
}