@IsTest
public class Scheduling_TestDataFactory {
    // Account Contact Product google calender 2  
    public static void createTestAccountWithContactsRecords(Integer numAccts, Integer numContactsPerAcct){
        List<Account> accountsList = new List<Account>();
        Id MemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Member').getRecordTypeId();
        List<SYS_Integration_Metadata__c> accIntMetadata = new List<SYS_Integration_Metadata__c>();
        
        for(Integer i=0;i<numAccts;i++) {
            Account tempAcc = new Account();
            tempAcc.Name = 'Test Account' + i;
            tempAcc.UUID__c = SYS_Helper.getUUID();
            tempAcc.Email__c = 'testemail' + i+'@adisols.com';
            tempAcc.Plivo_PHLO_Id__c = 'Test123';
            accountsList.add(tempAcc);
        }
        insert accountsList;
        
        List<Contact> contactsList = new List<Contact>();

        for (Integer j=0;j<numAccts;j++) {
            Account acct = accountsList[j];  
            
            if( j==0 ){
                SYS_OAuthConfig__c oauthRecord = new SYS_OAuthConfig__c();
                oauthRecord.Name = 'TestAccount';
                oauthRecord.Account__c = acct.Id;
                oauthRecord.Client_Id__c = 'testPublicKey';
                oauthRecord.Access_Token__c = 'testAccessToken';
                oauthRecord.Test_Mode__c = true;
                oauthRecord.Grant_Type__c = 'authorization_code';
                oauthRecord.Integration_Type__c = 'Calendar';
                oauthRecord.Token_type__c = 'Bearer';
                oauthRecord.Config_ID__c = 'SYSOAUTH-' + Integer.valueof((Math.random() * 1000));
                insert oauthRecord;
            }

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
                Contact tempCont = new Contact();
                tempCont.FirstName='Test'+k;
                tempCont.LastName='Contact'+k;
                tempCont.Email= 'testemail' + k +'@adisols.com';
                tempCont.AccountId=acct.Id;

                tempCont.Member_Type__c = 'Subscriber';
                tempCont.Membership_Type__c = 'Individual';
                tempCont.Phone_Number__c = '999999999' +k;
                tempCont.StripeCustomerId__c = 'test_customer'+k;
                tempCont.Active__c = true;
                tempCont.Payment_SMS_Sent__c = true;
                tempCont.Payment_Date_Time__c = System.now();
                tempCont.Registration_Order_Created__c = true;
                tempCont.RecordTypeId = MemberRecordTypeId;
                contactsList.add(tempCont);
            }
        }
        // Insert all Integration Metadata for all accounts
        insert accIntMetadata;
        // Insert all contacts for all accounts
        insert contactsList;
    }

    //Create Shift Calendar Record 
    public static Google_Calendar__c createTestShiftCalendarRecord(Id accountRecordId, String shiftCalendarExId, Boolean insertExternalId, Boolean doInsert){
        Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));	//generates a random number from 0 to 1000
        //Shift Calendar
        Google_Calendar__c shiftGoogleCalTemp = new Google_Calendar__c();
        shiftGoogleCalTemp.Calendar_Name__c = 'S-Dr Smith ' + IntrandomNumber;
        shiftGoogleCalTemp.Calendar_Type__c = 'Shift Calendar';
        shiftGoogleCalTemp.TimeZone__c = 'America/Los_Angeles';
        if(insertExternalId){
            shiftGoogleCalTemp.Google_Calendar_Id__c = String.isNotBlank(shiftCalendarExId) ? shiftCalendarExId : ('exCalenderKeyShift' + IntrandomNumber);
        }
        
        shiftGoogleCalTemp.Account__c = accountRecordId;
        shiftGoogleCalTemp.Active__c = true;
        if(doInsert){
            insert shiftGoogleCalTemp;
        }
        return shiftGoogleCalTemp;
    }

    //Create Booking Calendar Record
    public static Google_Calendar__c createTestBookingCalendarRecord(Id accountRecordId, Id BookingProductId, String bookingCalendarExId, Boolean insertExternalId, Boolean doInsert){
        Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));	//generates a random number from 0 to 1000
        //Booking Calendar
        Google_Calendar__c bookGoogleCalTemp = new Google_Calendar__c();
        bookGoogleCalTemp.Calendar_Name__c = 'B- ' + IntrandomNumber;
        bookGoogleCalTemp.Calendar_Type__c = 'Booking Calendar';
        bookGoogleCalTemp.TimeZone__c = 'America/Los_Angeles';
        if(insertExternalId){
            bookGoogleCalTemp.Google_Calendar_Id__c = String.isNotBlank(bookingCalendarExId) ? bookingCalendarExId : ('exCalenderKeyBooking' + IntrandomNumber);
        }
        bookGoogleCalTemp.Google_Calendar_Id__c = 'exCalenderKeyBooking' + IntrandomNumber;
        bookGoogleCalTemp.PMA_Product__c = BookingProductId;
        bookGoogleCalTemp.Account__c = accountRecordId;
        bookGoogleCalTemp.Active__c = true;
        if(doInsert){
            insert bookGoogleCalTemp;
        }
        return bookGoogleCalTemp;
    }

    public static Product__c createTestProductRecord(Id accountRecordId, String shiftCalendarExId, String bookingCalendarExId, Boolean insertExternalId, Boolean doInsert){
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        Integer IntrandomNumber = Integer.valueof((Math.random() * 1000));	//generates a random number from 0 to 1000

        //Create one Scheduling Product
        Product__c BookingProduct = new Product__c();
        BookingProduct.Account__c = accountRecordId;
        BookingProduct.Name = 'Consultation';
        BookingProduct.Unit_Price__c = 12.5;
        BookingProduct.Active__c = true;
        BookingProduct.UUID__c = guid;
        BookingProduct.Allow_scheduling__c = true;
        BookingProduct.TimeZone__c = 'America/Los_Angeles';
        BookingProduct.Meet_Duration__c = '60';
        BookingProduct.Minimum_Lead_Time__c = '15';
        BookingProduct.Product_Family__c = 'Scheduling';
        if(insertExternalId){
            BookingProduct.Google_Shift_Calendar_Id__c = String.isNotBlank(shiftCalendarExId) ? shiftCalendarExId : ('exCalenderKeyBooking' + IntrandomNumber);
            BookingProduct.Google_Booking_Calendar_Id__c = String.isNotBlank(bookingCalendarExId) ? bookingCalendarExId : ('exCalenderKeyBooking' + IntrandomNumber);
        }
        if(doInsert){
            insert BookingProduct;
        }
        return BookingProduct;
    }

    public static Account getAccountDetails(){
        String AccountListQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Account') +
                ' FROM Account LIMIT 1';
        List<Account> AccountList = Database.query(AccountListQuery);
        return (AccountList.size() > 0) ? AccountList[0] : new Account();
    }

    public static Contact getContactDetails(){
        String ContactListQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Contact') +
                ' FROM Contact LIMIT 1';
        List<Contact> ContactList = Database.query(ContactListQuery);
        return (ContactList.size() > 0) ? ContactList[0] : new Contact();
    }

    public static Product__c getProductDetails(){
        String ProductListQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Product__c') +
                ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
                ' FROM Product__c LIMIT 1';
        List<Product__c> ProductList = Database.query(ProductListQuery);
        return (ProductList.size() > 0) ? ProductList[0] : new Product__c();
    }

    public static Google_Calendar__c getGoogleCalendarDetails(){
        String GoogleCalendarListQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Google_Calendar__c') +
                ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
                ', ' + SYS_Helper.getAllParentFields('PMA_Product__r.', 'Product__c') +
                ' FROM Google_Calendar__c LIMIT 1';
        List<Google_Calendar__c> GoogleCalendarList = Database.query(GoogleCalendarListQuery);
        return (GoogleCalendarList.size() > 0) ? GoogleCalendarList[0] : new Google_Calendar__c();
    }

    public static User getUser() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        insert u;
        String namespaceprefix = SYS_datacache.namespacePrefix;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SYS_Municorn_Permission_Set' AND namespaceprefix =:namespaceprefix ];
        System.debug('user id '+u.id);
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);

        return u;
    }
}