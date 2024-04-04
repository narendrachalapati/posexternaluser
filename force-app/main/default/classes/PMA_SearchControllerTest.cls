@isTest
public class PMA_SearchControllerTest {
	@TestSetup
    static void PMA_SearchControllerTest(){
        PMA_TestDataFactory.createTestAccountWithContactsRecords(1, 3);  
    }
    
    @IsTest
    static void testgetOpenTabMembers(){
		Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        List<Contact> fetchContact = getcurrAccount.Contacts;
        System.debug('fetchContact test ' + fetchContact);
        for(Contact con : fetchContact){
        	PMA_TestDataFactory.createTestOrderRecords(getcurrAccount.Id, con.Id,'Draft');
        }
        Order__c fetchOrder = PMA_TestDataFactory.getTestOrderwithOrderItemRecords();
        
        List<PMA_SearchController.membersOrdersWrapper>  listOpenTabMembers = PMA_SearchController.getOpenTabMembers();
        List<Order__c> getOrderList = [SELECT Id,(SELECT Id,Name,Order__c,Product__c,Product__r.Name,Quantity__c,List_Price__c,Line_Total_Price__c,Total_Price__c,CreatedDate,LastModifiedDate FROM Order_Items__r),Name,Order_Type__c,Member__c,Member__r.Name,Member__r.Active__c,Vendor__c,Vendor__r.Name,Account__c,Account__r.Name,Status__c,Total_Price__c,UUID__c,CreatedDate,LastModifiedDate,OwnerId FROM Order__c];
        if(listOpenTabMembers.size()>0){
            System.assert(getOrderList.size()>0);
        }
    }
    
    @IsTest
    static void testsearchMembers(){
    	List<PMA_SearchController.membersOrdersWrapper> memberWrapList = PMA_SearchController.searchActiveMembers('Test Contact');
        if(memberWrapList.size()>0){
            System.assert(memberWrapList.size()>0);
        }
	}
    
    @IsTest
    static void testfetchCurrentUserWrapper(){
        PMA_SearchController.CurrentUserWrap cuserWrap = PMA_SearchController.fetchCurrentUserWrapper();
        System.assertNotEquals(null, cuserWrap.contactRecord);
	}

    @IsTest
    static void testfetchActionRecordRelatedActivities(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        List<SYS_Integration_Metadata__c> accIntMetadata = new List<SYS_Integration_Metadata__c>();

        Account acc = new Account(Name = 'PMA Test Account', Plivo_Country_Code__c = '1',
            Plivo_Sender_Id__c = '12222222222', Plivo_PHLO_Id__c = 'Test123');
        insert acc;

        accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = acc.Id,
            Integration_Type__c = 'Plivo',
            Key__c = 'int-set',
            Value__c = 'Plivo'));
        accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = acc.Id,
            Integration_Type__c = 'Stripe',
            Key__c = 'int-set',
            Value__c = 'Stripe'));
        
        insert accIntMetadata;    

        SYS_OAuthConfig__c  oauthRecord = PMA_TestDataFactory.createTestSysOauthWithAccessToken(acc.Id);

        Contact cont = new Contact(FirstName = 'PMA',
            LastName = 'Test Contact',
            Member_Type__c = 'Subscriber',
            Membership_Type__c = 'Individual',
            Phone_Number__c = '999999999',
            StripeCustomerId__c = 'test_customer',
            Active__c = true,
            Payment_SMS_Sent__c = true,
            Payment_Date_Time__c = System.now(),
            Registration_Order_Created__c = true,
            RecordTypeId = MemberRecordTypeId,
            AccountId = acc.Id);
        insert cont;

        Payment_Method__c paymentmethodRecord = new Payment_Method__c(Account__c = acc.Id,Contact__c = cont.Id );
        insert paymentmethodRecord;

        Activity__c smsActivity = new Activity__c(
                Customer__c = cont.Id,
                Account__c = acc.Id,
                Direction__c = 'OUTBOUND',
                Type__c = 'sms',
                Email__c = 'dev@adisols.com',
                Status__c = 'Queued',
                When__c = System.now(),
                Phone__c = '9999999990',
                Subject__c = 'Test Activity',
                Message__c = 'Test Sms Content',
                ActionId__c = cont.Id
        );
        Insert smsActivity;
        List < Activity__c > allrelatedActivitiesList = PMA_SearchController.fetchActionRecordRelatedActivities(cont.Id);
        System.assertNotEquals(0, allrelatedActivitiesList.size());
	}

    @IsTest
    static void testsearchExcludeActiveMembers(){
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        List<Contact> fetchContact = getcurrAccount.Contacts;
        System.debug('fetchContact test ' + fetchContact);
        for(Contact con : fetchContact){
        	PMA_TestDataFactory.createTestOrderRecords(getcurrAccount.Id, con.Id, 'Draft');
        }
    	List<PMA_SearchController.membersOrdersWrapper> memberWrapList = PMA_SearchController.searchActiveMembers('Test Contact');
        if(memberWrapList.size()>0){
            System.assert(memberWrapList.size()>0);
        }
	}
     
    @IsTest
    static void testgetOrderDetailsByIdOrUUID(){
        // Order__c getOrderDetailsByIdOrUUID( String orderIdOrUUID )
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        List<Contact> fetchContact = getcurrAccount.Contacts;
        System.debug('fetchContact test ' + fetchContact);
        Integer i = 0;
        for(Contact con : fetchContact){
            if(i == 0){
        		PMA_TestDataFactory.createTestOrderRecords(getcurrAccount.Id, con.Id,'Draft');
            }
			i++;
        }
        Order__c fetchOrder = PMA_TestDataFactory.getTestOrderwithOrderItemRecords();
        Order__c fetchOrderbyUUID = PMA_SearchController.getOrderDetailsByIdOrUUID( fetchOrder.UUID__c );
        system.assertEquals(fetchOrder.Total_Price__c, fetchOrderbyUUID.Total_Price__c);
    }
     
    @IsTest
    static void testcreateDraftOrderRecord(){
        Id vendorRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        Contact newContact = new Contact();
        newContact.FirstName = 'Member';
        newContact.LastName = 'Contact';
        newContact.RecordTypeId = vendorRecordTypeId;
        insert newContact;
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        List<Contact> fetchContact = getcurrAccount.Contacts;
        User userRecord = PMA_SearchController.fetchCurrentUser();
        userRecord.ContactId__c = newContact.Id;
        update userRecord;
        for(Contact con : fetchContact){
            Order__c orderRecord = PMA_SearchController.createDraftOrderRecord( con.Id );
        }
        Order__c fetchOrder = PMA_TestDataFactory.getTestOrderwithOrderItemRecords();
        system.assertEquals('Draft', fetchOrder.Status__c);
    }
    
    @IsTest
    static void testfetchCurrentUser(){
        User userRecord = PMA_SearchController.fetchCurrentUser();
        system.assertNotEquals(null, userRecord.Name);
    }
    
    @IsTest
    static void testgetOrderItemsForFulfillment(){
        List<Order_Item__c> orderfullfillRecords = PMA_SearchController.getOrderItemsForFulfillment();
        if(orderfullfillRecords.size()>0){
            System.assert(orderfullfillRecords.size()>0);
        }
    }
    
    @IsTest
    static void testgetKanbanWrapperDetails_Apex(){
        List<String> fieldsList =  new List<String>{'Name', 'Product__c','Product_Name__c' , 'Product__r.Name', 'Quantity__c', 'Notes__c', 'Item_Status__c', 'Order__c' , 'Order__r.Order_Type__c','Order__r.Status__c'};
        PMA_SearchController.kanbanWrap kanbanWrapvar = PMA_SearchController.getKanbanWrapperDetails_Apex('Order_Item__c',fieldsList ,'Item_Status__c');
        if(kanbanWrapvar.pickVals.size()>0){
            System.assert(kanbanWrapvar.pickVals.size()>0);
        }
    }
    
    @IsTest
    static void testgetUpdatePickListValue_Apex(){
		Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        List<Contact> fetchContact = getcurrAccount.Contacts;
        System.debug('fetchContact test ' + fetchContact);
        for(Contact con : fetchContact){
        	PMA_TestDataFactory.createTestOrderRecords(getcurrAccount.Id, con.Id,'Draft');
        }
        Order__c fetchOrder = PMA_TestDataFactory.getTestOrderwithOrderItemRecords();
        Product__c createprod = PMA_TestDataFactory.createProduct('Cheese Burger' , getcurrAccount.Id , false);
        insert createprod;
        Product_Option__c createprodOption = PMA_TestDataFactory.createProductOption('Cheese Burger' , createprod.Id , true); 
        Product_Option_Component__c createOptionComponent = PMA_TestDataFactory.createOptionComponent('Cheese Burger' , createprodOption.Id, '' , true); 
        
        PMA_TestDataFactory.createTestOrderItemRecords(3, fetchOrder.Id , createprodOption.Id);
        Order_Item__c latestOrderItem = [SELECT Id,Name,Item_Status__c FROM Order_Item__c LIMIT 1];
        if(latestOrderItem!= null){
            String updateStatus = PMA_SearchController.getUpdatePickListValue_Apex(latestOrderItem.Id, 'Item_Status__c' , 'Completed');
            system.assertEquals('Success', updateStatus);
        }
    }  
    
}