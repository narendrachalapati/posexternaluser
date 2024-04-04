@IsTest
public class PMA_ExternalSiteFormsUtilityTest {
    @TestSetup
    static void PortalUserServiceTest() {
            PMA_TestDataFactory.createTestAccountWithContactsRecords(1, 1);
    }
    
	@IsTest
    static void formatUSAPhoneWithoutCodeTest(){
        String phone = '5555555555';
        String formattedphone = PMA_ExternalSiteFormsUtility.formatPhone(Phone);
        System.assertEquals('15555555555', formattedphone);
    }
    
    @IsTest
    static void formatINDPhoneWithoutCodeTest(){
        String phone = '919555555555';
        String formattedphone = PMA_ExternalSiteFormsUtility.formatPhone(Phone);
        System.assertEquals('919555555555', formattedphone);
    }
    
    @IsTest
    static void formatUSAPhoneWithCodeTest(){
        String phone = '15555555555';
        String formattedphone = PMA_ExternalSiteFormsUtility.formatPhone(Phone);
        System.assertEquals('15555555555', formattedphone);
    }
    
    @IsTest
    static void formatBlanckPhoneTest(){
        String phone = '';
        String formattedphone = PMA_ExternalSiteFormsUtility.formatPhone(Phone);
        System.assertEquals('', formattedphone);
    }
    
    @IsTest
    static void getOrgUrlTest(){
        String getOrgUrl = PMA_ExternalSiteFormsUtility.getOrgUrl();
        System.assertNotEquals(null, getOrgUrl);
    }
        
    @IsTest
    static void getRecordTest(){
        Account getcurrAccount = PMA_TestDataFactory.getTestAccountWithContactsRecords();
        List<Contact> fetchContact = getcurrAccount.Contacts;
        String contactId = (fetchContact.size()>0)? fetchContact[0].Id: null;
        List < Sobject > contactRecords = PMA_ExternalSiteFormsUtility.getRecord(contactId);
        Contact contactRecord = (contactRecords.size() > 0) ? (Contact)contactRecords[0] : new Contact();
        String paymentName = 'Payment For ' + contactRecord.Name;
        System.assertNotEquals(null, contactRecord.Name);
    }
}