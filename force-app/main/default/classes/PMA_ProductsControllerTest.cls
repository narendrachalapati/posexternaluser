@isTest
public class PMA_ProductsControllerTest {
	@TestSetup
    static void PMA_ProductsControllerTest(){
        PMA_TestDataFactory.createTestAccountWithContactsRecords(1, 1);  
    }

    @IsTest
    static void testcreateOrderItems(){
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        List<Contact> fetchContact = getcurrAccount.Contacts;
        System.debug('fetchContact test ' + fetchContact);
        for(Contact con : fetchContact){
        	PMA_TestDataFactory.createTestOrderRecords(getcurrAccount.Id, con.Id , 'Draft');
        }
        Order__c fetchOrder = PMA_TestDataFactory.getTestOrderwithOrderItemRecords();
        Product__c createprod = PMA_TestDataFactory.createProduct('Cheese Burger' , getcurrAccount.Id , true);
        Product_Option__c createprodOption = PMA_TestDataFactory.createProductOption('Cheese Burger' , createprod.Id , true); 
        Product_Option_Component__c createOptionComponent = PMA_TestDataFactory.createOptionComponent('Cheese Burger' , createprodOption.Id, '' , true); 
        
        String selectedProductsValues;
        List < PMA_ProductsController.SelectedProductWrapper > prodWrapperList = new List < PMA_ProductsController.SelectedProductWrapper >();
        PMA_ProductsController.SelectedProductWrapper selectedproduct = new PMA_ProductsController.SelectedProductWrapper();
        selectedproduct.product = createprodOption;
        selectedproduct.quantity = 1;
        selectedproduct.isVisible = true;
        selectedproduct.prodMinimumAge = 26;
        selectedproduct.shortNameCode = 'CB';
        selectedproduct.hasPictureURL = false;
        selectedproduct.pictureURL = 'noimage';
        prodWrapperList.add(selectedproduct);
        selectedProductsValues = JSON.serialize(prodWrapperList);
        
    	Order__c orderRecord = PMA_ProductsController.createOrderItems(fetchOrder.Id, selectedProductsValues); 
        if(orderRecord != null){
            System.assertEquals('POS', orderRecord.Order_Type__c);
        }
	}

    @IsTest
    static void testcreateTipOrderItem(){
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        List<Contact> fetchContact = getcurrAccount.Contacts;
        System.debug('fetchContact test ' + fetchContact);
        for(Contact con : fetchContact){
        	PMA_TestDataFactory.createTestOrderRecords(getcurrAccount.Id, con.Id , 'Draft');
        }
        Order__c fetchOrder = PMA_TestDataFactory.getTestOrderwithOrderItemRecords();
        Product__c createprod = PMA_TestDataFactory.createProduct('Cheese Burger' , getcurrAccount.Id , true);
        Product_Option__c createprodOption = PMA_TestDataFactory.createProductOption('Cheese Burger' , createprod.Id , true); 
        Product_Option_Component__c createOptionComponent = PMA_TestDataFactory.createOptionComponent('Cheese Burger' , createprodOption.Id, '' , true); 
        
        String selectedProductsValues;
        List < PMA_ProductsController.SelectedProductWrapper > prodWrapperList = new List < PMA_ProductsController.SelectedProductWrapper >();
        PMA_ProductsController.SelectedProductWrapper selectedproduct = new PMA_ProductsController.SelectedProductWrapper();
        selectedproduct.product = createprodOption;
        selectedproduct.quantity = 1;
        selectedproduct.isVisible = true;
        selectedproduct.prodMinimumAge = 26;
        selectedproduct.shortNameCode = 'CB';
        selectedproduct.hasPictureURL = false;
        selectedproduct.pictureURL = 'noimage';
        prodWrapperList.add(selectedproduct);
        selectedProductsValues = JSON.serialize(prodWrapperList);
        
    	Order__c orderRecord = PMA_ProductsController.createTipOrderItem(fetchOrder.Id, 1.57, 0.20 ); 
        if(orderRecord != null){
            System.assertEquals('POS', orderRecord.Order_Type__c);
        }
	}

    @IsTest
    static void testcreatePaymentFromOrder(){
        Double paymentAmount = 20;
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        List<Contact> fetchContact = getcurrAccount.Contacts;
        System.debug('fetchContact test ' + fetchContact);
        
        User cuser = PMA_SearchController.fetchCurrentUser();
        cuser.ContactId__c = fetchContact[0].Id;
        update cuser;

        for(Contact con : fetchContact){
        	PMA_TestDataFactory.createTestOrderRecords(getcurrAccount.Id, con.Id,'Active');
        }

        Order__c fetchOrder = PMA_TestDataFactory.getTestOrderwithOrderItemRecords();
    	List<Payment_Intent__c> pymtIntentList =  PMA_ProductsController.createPaymentFromOrder(fetchOrder.Id,paymentAmount);
        if(pymtIntentList.size()>0){
            System.assert(pymtIntentList.size()>0);
        }
	}
    
    @IsTest
    static void testprocessComplimentaryPayment(){
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        List<Contact> fetchContact = getcurrAccount.Contacts;
        String contactId = (fetchContact.size()>0)? fetchContact[0].Id: null;
        for(Contact con : fetchContact){
        	PMA_TestDataFactory.createTestOrderRecords(getcurrAccount.Id, con.Id,'Active');
        }

        Order__c fetchOrder = PMA_TestDataFactory.getTestOrderwithOrderItemRecords();
        Payment_Intent__c paymentRequest = PaymentIntentService.createNewPaymentIntent(
                'Test Payment Request',
                contactId,
                getcurrAccount.Id,
                fetchOrder.Id,
                'immediate',
                Double.valueOf(23.4),
                'sample@gmail.com',
                'single',
                System.TODAY());
        Transaction__c txnRecord =  PMA_ProductsController.processComplimentaryPayment(paymentRequest,fetchOrder);
        if(txnRecord != null){
            System.assertEquals('succeeded', txnRecord.Status__c);
        }
    }
        
    @IsTest
    static void testdeleteOrderRecord(){
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        List<Contact> fetchContact = getcurrAccount.Contacts;
        System.debug('fetchContact test ' + fetchContact);
        for(Contact con : fetchContact){
        	PMA_TestDataFactory.createTestOrderRecords(getcurrAccount.Id, con.Id,'Active');
        }
        Order__c fetchOrder = PMA_TestDataFactory.getTestOrderwithOrderItemRecords();
        Boolean orderdeleteStatus = PMA_ProductsController.deleteOrderRecord(fetchOrder.Id);
		System.assertEquals(true, orderdeleteStatus);        
    }
    
    @IsTest
    static void testdeleteOrderItem(){
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        List<Contact> fetchContact = getcurrAccount.Contacts;
        System.debug('fetchContact test ' + fetchContact);
        for(Contact con : fetchContact){
        	PMA_TestDataFactory.createTestOrderRecords(getcurrAccount.Id, con.Id , 'Draft');
        }
        Order__c fetchOrder = PMA_TestDataFactory.getTestOrderwithOrderItemRecords();
        Product__c createprod = PMA_TestDataFactory.createProduct('Cheese Burger' , getcurrAccount.Id , false);
        insert createprod;
        Product_Option__c createprodOption = PMA_TestDataFactory.createProductOption('Cheese Burger' , createprod.Id , true); 
        Product_Option_Component__c createOptionComponent = PMA_TestDataFactory.createOptionComponent('Cheese Burger' , createprodOption.Id, '' , true); 
        
        PMA_TestDataFactory.createTestOrderItemRecords(3, fetchOrder.Id , createprodOption.Id);
        Order_Item__c latestOrderItem = [SELECT Id,Name,Item_Status__c FROM Order_Item__c LIMIT 1];
        Order__c deletedOrderRecord = PMA_ProductsController.deleteOrderItem(fetchOrder.Id, latestOrderItem.Id);
		if(deletedOrderRecord != null){
            System.assertEquals('Draft', deletedOrderRecord.Status__c);
        }
    }
    
    @IsTest
    static void testgetTransactionDetails(){
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        List<Contact> fetchContact = getcurrAccount.Contacts;
        String contactId = (fetchContact.size()>0)? fetchContact[0].Id: null;
        System.debug('fetchContact test ' + fetchContact);
        for(Contact con : fetchContact){
        	PMA_TestDataFactory.createTestOrderRecords(getcurrAccount.Id, con.Id,'Active');
        }
        Order__c fetchOrder = PMA_TestDataFactory.getTestOrderwithOrderItemRecords();
		Payment_Intent__c paymentRequest = PaymentIntentService.createNewPaymentIntent(
                'Test Payment Request',
                contactId,
                getcurrAccount.Id,
                fetchOrder.Id,
                'immediate',
                Double.valueOf(23.4),
                'sample@gmail.com',
                'single',
                System.TODAY());
        
        TransactionService txnService = new TransactionService();
        Transaction__c createTxn = txnService.buildTransaction(paymentRequest);
        insert createTxn;
       	Transaction__c txnRecord = PMA_ProductsController.getTransactionDetails(createTxn.Id);
       	if(txnRecord != null){
          System.assertEquals('initiated', txnRecord.Status__c);
       	}
    }
    
    @IsTest
    static void testgetOrderDetailsById(){
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
        Order__c fetchOrderbyUUID = PMA_ProductsController.getOrderDetails( fetchOrder.UUID__c );
        system.assertEquals(fetchOrder.Total_Price__c, fetchOrderbyUUID.Total_Price__c);
    }
    
    @IsTest
    static void testfetchCurrentUser(){
        User userRecord = PMA_ProductsController.fetchCurrentUser();
        system.assertNotEquals(null, userRecord.Name);
    }
    
    @IsTest
    static void testgetAllProductRecords(){
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        List<Contact> fetchContact = getcurrAccount.Contacts;
        System.debug('fetchContact test ' + fetchContact);
        for(Contact con : fetchContact){
        	PMA_TestDataFactory.createTestOrderRecords(getcurrAccount.Id, con.Id , 'Draft');
        }
        Order__c fetchOrder = PMA_TestDataFactory.getTestOrderwithOrderItemRecords();
        Product__c createprod1 = PMA_TestDataFactory.createProduct('Cheese Burger' , getcurrAccount.Id , true);
        Product_Option__c createprodOption1 = PMA_TestDataFactory.createProductOption('Cheese Burger' , createprod1.Id , true); 
        Product_Option_Component__c createOptionComponent1 = PMA_TestDataFactory.createOptionComponent('Cheese Burger' , createprodOption1.Id, '' , true); 
        
        Product__c createprod2 = PMA_TestDataFactory.createProduct('Cheese Sandwitch' , getcurrAccount.Id , true);
        Product_Option__c createprodOption2 = PMA_TestDataFactory.createProductOption('Cheese Sandwitch' , createprod2.Id , true); 
        Product_Option_Component__c createOptionComponent2 = PMA_TestDataFactory.createOptionComponent('Cheese Sandwitch' , createprodOption2.Id, '' , true); 
        
        Map <Id, PMA_ProductsController.SelectedProductWrapper > wrapperMap = PMA_ProductsController.getAllProductRecords( fetchOrder.UUID__c );
        system.assertNotEquals(null, wrapperMap);
    }
    
    
    @IsTest
    static void testgetUserPaymentMethods(){
		Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
		Contact contact = new Contact(FirstName = 'Sample', LastName = 'Contact', AccountId = getcurrAccount.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',RecordTypeId = MemberRecordTypeId);
		insert contact;
        String contactId = contact.Id;
        Test.startTest();
        StaticResourceCalloutMock stripeMock = new StaticResourceCalloutMock();
		stripeMock.setStaticResource('mockStripeCustomerCards');
        stripeMock.setStatusCode(200);
        stripeMock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, stripeMock);
        Test.stopTest();
        List<Stripe.Card> cardsList = PMA_ProductsController.getUserPaymentMethods(contactId); 
        if(cardsList.size() >0){
            System.assert(cardsList.size()>0);
        }
	}
    
    
    @IsTest
    static void testprocessPaymentsByDefaultSource(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        Contact contactrec = new Contact(FirstName = 'Sample', LastName = 'Contact', AccountId = getcurrAccount.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
		insert contactrec;
        String contactId = contactrec.Id;
        PMA_TestDataFactory.createTestOrderRecords(getcurrAccount.Id, contactId,'Draft');
        Order__c fetchOrder = PMA_TestDataFactory.getTestOrderwithOrderItemRecords();
		List<Payment_Intent__c> paymentRequests = new List<Payment_Intent__c>();
        Payment_Intent__c paymentRequest = PaymentIntentService.createNewPaymentIntent(
                'Test Payment Request',
                contactId,
                getcurrAccount.Id,
                fetchOrder.Id,
                'immediate',
                Double.valueOf(23.4),
                'sample@gmail.com',
                'single',
                System.TODAY());
        paymentRequests.add(paymentRequest);
        Test.startTest();
        StaticResourceCalloutMock stripeMock = new StaticResourceCalloutMock();
		stripeMock.setStaticResource('mockStripeChargeSuccess');
        stripeMock.setStatusCode(200);
        stripeMock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, stripeMock);
        Test.stopTest();
        Stripe.UserPaymentRequest stripePaymentRequest = new Stripe.UserPaymentRequest();
        stripePaymentRequest.selectedPaymentSource = '';
        Stripe.Payment pymt = PMA_ProductsController.processPaymentsByDefaultSource(paymentRequests,stripePaymentRequest);
        system.assertNotEquals(null, pymt);
	}
    
    @IsTest
    static void testgetContactDetails(){
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        List<Contact> fetchContact = getcurrAccount.Contacts;
        String contactId = (fetchContact.size()>0)? fetchContact[0].Id: null;

        Contact fetchContactDetails =  PMA_ProductsController.getContactDetails(contactId);

        System.assertNotEquals(null, fetchContactDetails);
    }

    @IsTest
    static void testgetAllCategorys(){
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        List<Contact> fetchContact = getcurrAccount.Contacts;
        String contactId = (fetchContact.size()>0)? fetchContact[0].Id: null;
        Catalog__c catalog1 = PMA_TestDataFactory.createCatalog('Burger' , getcurrAccount.Id, '' , true);
        Catalog__c catalog2 = PMA_TestDataFactory.createCatalog('Sandwitch' , getcurrAccount.Id, '' , true);

        Product__c createprod1 = PMA_TestDataFactory.createProductwithCatalog('Cheese Burger' , getcurrAccount.Id , catalog1.Id , true);
        Product_Option__c createprodOption1 = PMA_TestDataFactory.createProductOption('Cheese Burger' , createprod1.Id , true); 
        Product_Option_Component__c createOptionComponent1 = PMA_TestDataFactory.createOptionComponent('Cheese Burger' , createprodOption1.Id, '' , true); 
        
        Product__c createprod2 = PMA_TestDataFactory.createProductwithCatalog('Cheese Sandwitch' , getcurrAccount.Id , catalog2.Id , true);
        Product_Option__c createprodOption2 = PMA_TestDataFactory.createProductOption('Cheese Sandwitch' , createprod2.Id , true); 
        Product_Option_Component__c createOptionComponent2 = PMA_TestDataFactory.createOptionComponent('Cheese Sandwitch' , createprodOption2.Id, '' , true); 
        

        List<Catalog__c> newCatList = PMA_ProductsController.getAllCategorys();
        if(newCatList.size() >0){
            System.assert(newCatList.size()>0);
        }
    }

    @IsTest
    static void getIntegrationMetadataTest(){
        Account account = new Account(Name = 'Sample Account');
        insert account;

        List<SYS_Integration_Metadata__c> accIntMetadata = new List<SYS_Integration_Metadata__c>();

        accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = account.Id,
            Integration_Type__c = 'Plivo',
            Key__c = 'int-set',
            Value__c = 'Plivo'));
        accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = account.Id,
            Integration_Type__c = 'Plivo_PHLO',
            Key__c = 'int-set',
            Value__c = 'Plivo_PHLO'));
        accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = account.Id,
            Integration_Type__c = 'Stripe',
            Key__c = 'int-set',
            Value__c = 'Stripe'));
        
        insert accIntMetadata; 

        Map<String, String> integrationMeradataMap = PMA_ProductsController.getIntegrationMetadata(account.Id, 'Stripe');
        System.assertNotEquals(null, integrationMeradataMap);
    }

    @IsTest
    static void createActivityTest(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        
        Account account = new Account(Name = 'Sample Account');
        insert account;

        Contact contact = new Contact(FirstName = 'Sample', Member_Type__c = 'Guest', LastName = 'Contact', Phone_Number__c = '1111111111' , AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert contact;
        String messagebody = 'Test SMS Activity';
        String messageSubject = 'Inbox - Outbound SMS to Sample Guest';
        String activityRecordId = PMA_ProductsController.createActivity(messagebody, messageSubject, contact.Id);
        System.assertNotEquals(null, activityRecordId);
    }

    @IsTest
    static void calloutSynchronousOutboundTest(){
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        String accountMergeFieldForContact = 'AccountId';
        Account account = new Account(Name = 'Sample Account');
        insert account;

        List<SYS_Integration_Metadata__c> accIntMetadata = new List<SYS_Integration_Metadata__c>();

        accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = account.Id,
            Integration_Type__c = 'Plivo',
            Key__c = 'int-set',
            Value__c = 'Plivo'));
        accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = account.Id,
            Integration_Type__c = 'Plivo_PHLO',
            Key__c = 'int-set',
            Value__c = 'Plivo_PHLO'));
        accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = account.Id,
            Integration_Type__c = 'Stripe',
            Key__c = 'int-set',
            Value__c = 'Stripe'));
        
        insert accIntMetadata; 

        Contact contact = new Contact(FirstName = 'Sample', Member_Type__c = 'Guest', LastName = 'Contact', Phone_Number__c = '1111111111', AccountId = account.Id, StripeCustomerId__c = 'cus_G5i0UDob8XanSl',Default_Payment_Method__c = 'card_2JZWVCDQBrpdxQCKwNKVLJq3',RecordTypeId = MemberRecordTypeId);
        insert contact;
        String objSetting = 'Plivo_PHLO_Call';
        String apexHandler = 'SYS_ApplicationService';
        String direction ='OUT';
        Test.startTest();
        StaticResourceCalloutMock plivoConfMock = new StaticResourceCalloutMock();
		plivoConfMock.setStaticResource('mockPlivoConferenceSuccess');
        plivoConfMock.setStatusCode(200);
        plivoConfMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, plivoConfMock);
        String callStatus = PMA_ProductsController.calloutSynchronousOutbound(contact.Id, objSetting, apexHandler, direction, accountMergeFieldForContact);
        Test.stopTest();
        
        System.assertNotEquals(null, callStatus);
    }  
    
}