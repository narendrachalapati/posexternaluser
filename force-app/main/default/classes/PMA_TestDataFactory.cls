@isTest
public class PMA_TestDataFactory {
    private static Id ManagerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Manager').getRecordTypeId();
    private static Id VendorRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
    private static Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
    
    public static Account getTestAccountWithContactsRecords(){
        Account acc = [SELECT Id, Name,
            OwnerId,
            (SELECT Id, Name, Active__c, AccountId, LastName, Gender__c,
                Birthdate, Phone_Number__c, Member_Type__c, AllowComplimentaryOrders__c, Sponsor__c, Default_Payment_Method__c,
                UUID__c, hasUnreadMessages__c, UnreadActivitiesCount__c, Latest_Activity_Number__c, IsUserDeactivated__c,
                Guest_Member_Valid_Till__c, OwnerId FROM Contacts WHERE RecordTypeId =: MemberRecordTypeId) FROM Account LIMIT
            1
        ];
        SYS_OAuthConfig__c oauthRecord = PMA_TestDataFactory.createTestSysOauthWithAccessToken(acc.Id);
        return acc;
    }
    
    public static Order__c getTestOrderwithOrderItemRecords(){
        Order__c currentOrder = [SELECT Id,Name,Order_Type__c,Member__c,Member__r.Name,Member__r.Active__c, Member__r.Default_Payment_Method__c, Member__r.AllowComplimentaryOrders__c, Member__r.Age__c, Member__r.Birthdate,Vendor__c,Vendor__r.Name,Account__c,Account__r.Name,Status__c,Total_Price__c,UUID__c,CreatedDate,LastModifiedDate,OwnerId,
            (SELECT Id,Name,Order__c,Product__c,Product_Name__c,Quantity__c,List_Price__c,Line_Total_Price__c,Total_Price__c,Notes__c,CreatedDate,LastModifiedDate FROM Order_Items__r) FROM Order__c WHERE ( Order_Type__c = 'POS' )  LIMIT 1];
        return currentOrder;
    }

	public static void createTestAccountWithContactsRecords(Integer numAccts, Integer numContactsPerAcct){
        List<Account> accts = new List<Account>();
        List<SYS_Integration_Metadata__c> accIntMetadata = new List<SYS_Integration_Metadata__c>();
        
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(Name='PMA Test Account' + i, Plivo_Country_Code__c = '1',
            Plivo_Sender_Id__c = '12222222222', Plivo_PHLO_Id__c = 'Test123');
            accts.add(a);
        }
        insert accts;
        
        List<Contact> cons = new List<Contact>();
        for (Integer j=0;j<numAccts;j++) {
            Account acct = accts[j];            
            // For each account just inserted, add contacts
            for (Integer k=numContactsPerAcct*j;k<numContactsPerAcct*(j+1);k++) {
                accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = acct.Id,
                                    Integration_Type__c = 'Plivo', 
                                    Key__c = 'int-set',
                                    Value__c = 'Plivo'));
                accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = acct.Id,
                                    Integration_Type__c = 'Stripe', 
                                    Key__c = 'int-set',
                                    Value__c = 'Stripe'));     
                accIntMetadata.add(new SYS_Integration_Metadata__c(Account__c = acct.Id,
                                    Integration_Type__c = 'Calendar', 
                                    Key__c = 'int-set',
                                    Value__c = 'Calendar'));                                                
                cons.add(new Contact(FirstName='PMA'+k,
                                     LastName='Test Contact'+k,
                                     Member_Type__c = 'Subscriber',
                                     Membership_Type__c = 'Individual',
                                     Phone_Number__c = '999999999' +k,
                                     StripeCustomerId__c = 'test_customer'+k,
                                     Active__c = true,
                                     Payment_SMS_Sent__c = true,
                                     Payment_Date_Time__c = System.now(),
                                     Registration_Order_Created__c = true,
                                     RecordTypeId = MemberRecordTypeId,
                                     AccountId=acct.Id));
            }
        }
        // Insert all Integration Metadata for all accounts
        insert accIntMetadata;
        // Insert all contacts for all accounts
        insert cons;

    }

    public static void createTestOrderRecords(String accId, String contId, String status){
        Order__c orderRecord = new Order__c(Order_Type__c = 'POS',
                                      Status__c = status, Account__c = accId, Member__c = contId, UUID__c = SYS_Helper.getUUID() );
        insert orderRecord;
        
    }
    
    public static void createTestOrderItemRecords(Integer numOrderItems, String orderId , String productoptionId){
        List<Order_Item__c> ordersItemList = new List<Order_Item__c>();
        for(Integer i=0;i<numOrderItems;i++) {
       		Order_Item__c orderItemNew = new Order_Item__c();
            orderItemNew.Order__c = orderId;
            orderItemNew.Item_Status__c = 'New';
            orderItemNew.Product_Option__c = productoptionId;
            orderItemNew.Quantity__c = 1;
            orderItemNew.Notes__c = 'Test Notes ';
            ordersItemList.add(orderItemNew);
        }
        insert ordersItemList;
    }

    public static void createTestPaymentGatewayRecord(){
        Payment_Gateway__c pg = new Payment_Gateway__c();
        pg.Access_Token__c = 'testAccessToken';
        pg.Gateway_Public_Key__c = 'testPublicKey';
        pg.Test_Mode__c = true;
        insert pg;
    }

    public static SYS_OAuthConfig__c getTestSysOauthWithAccessTokenRecord(Id recordId){
        SYS_OAuthConfig__c oauthRecord = [SELECT
            Access_Token__c, Account__c, Additional_URL_Parameters__c, Algo__c, aud__c, Authorize_Endpoint__c, Client_Id__c, Client_Secret__c, Config_ID__c, CreatedById, CreatedDate, exp__c, Grant_Type__c, iat__c, Id, Integration_Type__c, IsDeleted, iss__c, LastActivityDate, LastModifiedById, LastModifiedDate, LastReferencedDate, LastViewedDate, Name, Object_Setting__c, OwnerId, Password__c, Private_Key__c, Redirect_URL__c, Refresh_Token__c, Schedule_Refresh_Token__c, Scope__c, Start_token_flow_on_save__c, sub__c, SystemModstamp, target_audience__c, Test_Formula__c, Test_Mode__c, Token_Endpoint__c, Token_Expiry_Date__c, Token_Expiry_Time__c, Token_Last_Refresh_Date__c, Token_type__c, Username__c
            FROM SYS_OAuthConfig__c WHERE Id =: recordId
        ];
        return oauthRecord;
    }

    public static SYS_OAuthConfig__c createTestSysOauthWithAccessToken(Id accId){
        SYS_OAuthConfig__c oauthRecord = new SYS_OAuthConfig__c();
        oauthRecord.Name = 'TestAccount';
        oauthRecord.Account__c = accId;
        oauthRecord.Client_Id__c = 'testPublicKey';
        oauthRecord.Access_Token__c = 'testAccessToken';
        oauthRecord.Test_Mode__c = true;
        oauthRecord.Grant_Type__c = 'authorization_code';
        oauthRecord.Integration_Type__c = 'Stripe';
        oauthRecord.Token_type__c = 'Bearer';
        oauthRecord.Config_ID__c = 'SYSOAUTH-' + Integer.valueof((Math.random() * 1000));
        insert oauthRecord;
        SYS_OAuthConfig__c fetchOauthRecord = getTestSysOauthWithAccessTokenRecord(oauthRecord.Id);
        return fetchOauthRecord;
    }
        
    public static Catalog__c createCatalog(String name , String accid, String catalogId , Boolean doInsert) {
        Catalog__c catalogrecord = new Catalog__c();
        catalogrecord.Name = name;
        catalogrecord.Account__c = accid;
        if(String.isNotBlank(catalogId)){
            catalogrecord.Catalog__c = catalogId;
        }
        if (doInsert) {
            insert catalogrecord;
        }
        return catalogrecord;
    }

    public static Product__c createProductwithCatalog(String name , String accid, String catalogId , Boolean doInsert) {
        Product__c product = new Product__c();
        product.Name = name;
        product.Unit_Price__c = 12.5;
        product.Catalog__c = catalogId;
        product.Product_Code__c = 'POS';
        product.Product_Family__c = 'POS';
        product.Quantity_Unit_Of_Measure__c = 'Each';
        product.Active__c = true;
        product.Account__c = accid;
        if (doInsert) {
            insert product;
        }
        return product;
    }

    public static Product__c createProduct(String name , String accid , Boolean doInsert) {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);

        Product__c product = new Product__c();
        product.Name = name;
        product.Unit_Price__c = 12.5;
        product.Product_Code__c = 'POS';
        product.Product_Family__c = 'POS';
        product.Quantity_Unit_Of_Measure__c = 'Each';
        product.Active__c = true;
        product.Account__c = accid;
        DateTime dt = System.today();
        Time myTime = Time.newInstance(dt.hour(), dt.minute(), dt.second(), dt.millisecond());
        product.Available_From_Time__c = myTime;
        product.Avialable_End_Time__c = myTime.addminutes(30);
        product.UUID__c = guid;
        product.Allow_scheduling__c = true;
        product.TimeZone__c = 'Asia/Kolkata';
        product.Meet_Duration__c = '30';
        if (doInsert) {
            insert product;
        }
        return product;
    }

    public static Product_Option__c createProductOption(String name, String prodId, Boolean doInsert) {
        Product_Option__c productoption = new Product_Option__c();
        productoption.Name = name;
        productoption.Product__c = prodId;
        if (doInsert) {
            insert productoption;
        }
        return productoption;
    }

    public static Product_Option_Component__c createOptionComponent(String name, String prodOptionId, String inventoryId, Boolean doInsert) {
        Product_Option_Component__c productoptioncomponent = new Product_Option_Component__c();
        productoptioncomponent.Name = name;
        productoptioncomponent.Product_Option__c = prodOptionId;
        productoptioncomponent.Required_Quantity__c = 1.0000;
        productoptioncomponent.Unit_Price__c = 12.5;
        if (String.isNotBlank(inventoryId)) {
            productoptioncomponent.Product_Inventory__c = inventoryId;
        }
        if (doInsert) {
            insert productoptioncomponent;
        }
        return productoptioncomponent;
    }

    // /* Scheduling Data Factory*/
    // public static CustomCalendar__c createcustomcalendardata(String accountId) {
    //     Product__c createprod = PMA_TestDataFactory.createProduct('testproduct' , accountId , false);
    //     insert createprod;
    //     Product_Option__c prodoption = PMA_TestDataFactory.createProductoptions(createprod.Id);

    //     CustomCalendar__c cc = new CustomCalendar__c();
    //     cc.summary__c = 'Customcalendartest';
    //     cc.TimeZone__c = 'Asia/Kolkata';
    //     cc.PMA_Product__c = createprod.Id;
    //     cc.Product_Option__c = prodoption.Id;
    //     cc.Account__c = accountId;
    //     insert cc;
    //     return cc;
    // }

    // //list of calendars creations
    // public static List < CustomCalendar__c > createcustomcalendarlist(Integer numCustomcal, String accountId) {
    //     Product__c createprod = PMA_TestDataFactory.createProduct('Cheese Burger' , accountId , false);
    //     insert createprod;
    //     Product_Option__c prodoption = PMA_TestDataFactory.createProductoptions(createprod.Id);

    //     List < CustomCalendar__c > cclist = new List < CustomCalendar__c > ();
    //     for (Integer i = 0; i < numCustomcal; i++) {
    //         CustomCalendar__c cc = new CustomCalendar__c();
    //         cc.summary__c = 'Customcalendartest' + i;
    //         cc.TimeZone__c = 'Asia/Kolkata';
    //         cc.SYS_Key__c = 'exCalenderKey' + i;
    //         cc.PMA_Product__c = createprod.Id;
    //         cc.Product_Option__c = prodoption.Id;
    //         cc.Account__c = accountId;
    //         cc.Active__c = true;
    //         cclist.add(cc);
    //     }
    //     insert cclist;
    //     return cclist;
    // }

    //create single record 
    public static Appointment_Scheduling__c createAppointmentscheduling(String prodoption, String accountId) {
        Datetime currentDatetime = Datetime.now();
        Appointment_Scheduling__c Apointment = new Appointment_Scheduling__c();
        Apointment.Account__c = accountId;
        Apointment.Name = 'TestEvent';
        Apointment.GustEmail__c = 'Test@gmail.com';
        Apointment.TimeZone__c = 'Asia/Kolkata';
        Apointment.CalendarSYS_Key__c = 'dev@adisols.com';
        Apointment.StartDate__c = currentDatetime.addMinutes(60);
        Apointment.EndDate__c = currentDatetime.addMinutes(60);
        Apointment.Product_Option__c = prodoption;
        Apointment.AppointmentDate__c = System.today();
        insert Apointment;
        return Apointment;
    }

    public static Product__c createProductwithoutacc(String name, Boolean doInsert) {
        Product__c product = new Product__c();
        product.Name = name;
        product.Unit_Price__c = 12.5;
        product.Product_Code__c = 'POS';
        product.Product_Family__c = 'POS';
        product.Quantity_Unit_Of_Measure__c = 'Each';
        product.Active__c = true;
        product.TimeZone__c = 'Asia/Kolkata';
        if (doInsert) {
            insert product;
        }
        return product;
    }

    public static Product_Option__c createProductoptions(string prodid) {
        Product_Option__c prodoption = new Product_Option__c();
        prodoption.Product__c = prodid;
        prodoption.Allow_scheduling__c = true;
        prodoption.Name = 'SchedulingOption';
        insert prodoption;
        return prodoption;
    }

    public static List < Appointment_Scheduling__c > createAppointmentschedulinglist(String prodoption, String accountId) {
        Datetime currentDatetime = Datetime.now();
        List < Appointment_Scheduling__c > app = new List < Appointment_Scheduling__c > ();
        for (Integer i = 0; i < 3; i++) {
            Appointment_Scheduling__c Apointment = new Appointment_Scheduling__c();
            Apointment.Account__c = accountId;
            Apointment.Name = 'TestEvent' + i;
            Apointment.GustEmail__c = 'Test@gmail.com';
            Apointment.TimeZone__c = 'Asia/Kolkata';
            Apointment.CalendarSYS_Key__c = 'dev@adisols.com'+i;
            Apointment.StartDate__c = currentDatetime.addMinutes(60);
            Apointment.EndDate__c = currentDatetime.addMinutes(60);
            Apointment.AppointmentDate__c = System.today();
            Apointment.Product_Option__c = prodoption;
            app.add(Apointment);
        }
        //insert app;

        return app;
    }

}