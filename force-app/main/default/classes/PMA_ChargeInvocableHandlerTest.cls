@IsTest
public class PMA_ChargeInvocableHandlerTest {
	@TestSetup
    static void PMA_ChargeInvocableHandlerTest(){
        PMA_TestDataFactory.createTestAccountWithContactsRecords(1, 3);  
    }
    @IsTest
    static void chargeActiveOrdersTest(){
		Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        List<Contact> fetchContact = getcurrAccount.Contacts;
        System.debug('fetchContact test ' + fetchContact);
        Integer i = 0;
        for(Contact con : fetchContact){
            if(i == 0){
                Order__c orderRecord = new Order__c(Order_Type__c = 'POS',
                                      Status__c = 'Active', Account__c = getcurrAccount.Id, Member__c = con.Id, UUID__c = '5688b376-e2c5-e576-f54d-a98eba9404c5'+ Integer.valueof((Math.random() * 1000)));
        		insert orderRecord;
                Product__c createprod = PMA_TestDataFactory.createProduct('Cheese Burger' , getcurrAccount.Id , false);
                insert createprod;
                Product_Option__c createprodOption = PMA_TestDataFactory.createProductOption('Cheese Burger' , createprod.Id , true); 
                Product_Option_Component__c createOptionComponent = PMA_TestDataFactory.createOptionComponent('Cheese Burger' , createprodOption.Id, '' , true); 
        
                PMA_TestDataFactory.createTestOrderItemRecords(3, orderRecord.Id , createprodOption.Id);
            }
            i++;
        }
        List<Order__c> orderList = [SELECT Id,Name,Account__c,Account__r.Name,Member__c,Member__r.Name,Member__r.Email,Order_Type__c,Status__c,Vendor__c,Total_Price__c,UUID__c,CreatedDate,LastModifiedDate,OwnerId,
                (SELECT Id,Name,Line_Total_Price__c,List_Price__c,Order__c,Product__c,Quantity__c,Total_Price__c,CreatedDate,LastModifiedDate FROM Order_Items__r)
                FROM Order__c];

        List<PMA_ChargeInvocableHandler.MyInvocableVariable> ivs = new List<PMA_ChargeInvocableHandler.MyInvocableVariable>();
        PMA_ChargeInvocableHandler.MyInvocableVariable iv = new PMA_ChargeInvocableHandler.MyInvocableVariable();
        iv.newVal = orderList;
        ivs.add(iv);
        PMA_ChargeInvocableHandler.chargeActiveOrders(ivs);
    }
    
}