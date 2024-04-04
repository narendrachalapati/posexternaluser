public without sharing class MemberService {
    public MemberService() {

    }

    public class Member {
        public String Name { get; set; }
        public String Id { get; set; }
        public String FirstName { get; set; }
        public String LastName { get; set; }
        public String PhoneNumber { get; set; }
        public String PhoneNumberFormatted { get; set; }
        public String Stage { get; set; }
        public Date dob { get; set; }
        public String uuid { get; set; }
        public String lastVarificationPin { get; set; }
        public DateTime lastVarificationPinTime { get; set; }
        public Boolean isphoneverified { get; set; }
        public sObject memberRecord { get; set; }
    }

    public static Member getMemberInformation(String salesforceRecordUUID, String phonenumber, String firstname, String lastname, String dateofbirthString) {
        Member memberinfo = new Member();
        try {
            List<sObject> records = findMember( salesforceRecordUUID,  phonenumber,  firstname,  lastname,  dateofbirthString);
            if (records.size() > 0) {
                memberinfo = fillMemberInfo(records[0]);
            }
        } catch (Exception e) {
            throw new MemberServiceException(e.getMessage()+'\n'+e.getStackTraceString());
        }
        return memberinfo;

    }

    public static Member fillMemberInfo(sObject record) {
        String firstname = '', lastname = '';
        Member memberinfo = new Member();
        memberinfo.memberRecord = record;
        try {
            if (record instanceOf Account) {
                firstname = (String)record.get('First_Name__c');
                lastname = (String)record.get('Last_Name__c');
                memberinfo.Id = (String)record.get('Id');
                memberinfo.uuid = (String)record.get('UUID__c');
                memberinfo.FirstName = (String.isNotBlank(firstname)) ? firstname : '';
                memberinfo.LastName = (String.isNotBlank(lastname)) ? lastname : '';
                memberinfo.Name = (String)record.get('Name');
                memberinfo.PhoneNumberFormatted = (String)record.get('Formatted_Phone_Number__c');
                memberinfo.Stage = (String)record.get('Stage__c');
                
                memberinfo.lastVarificationPin = (String)record.get('Last_Created_Verification_Pin__c');
                memberinfo.lastVarificationPinTime = (DateTime)record.get('Last_Created_Verification_Pin_Time__c');
                memberinfo.isphoneverified = (Boolean)record.get('Phone_Verified__c');
            } 
            else if (record instanceOf Contact) {
                firstname = (String)record.get('FirstName');
                lastname = (String)record.get('LastName');
                memberinfo.Id = (String)record.get('Id');
                memberinfo.uuid = (String)record.get('UUID__c');
                memberinfo.FirstName = (String.isNotBlank(firstname)) ? firstname : '';
                memberinfo.LastName = (String.isNotBlank(lastname)) ? lastname : '';
                memberinfo.Name = (String.isNotBlank(firstname) ? firstname : '') + '' + (String.isNotBlank(firstname) ? ' ' : '') + '' + (String.isNotBlank(lastname) ? lastname : '');
                memberinfo.PhoneNumberFormatted = (String)record.get('Formatted_Phone_Number__c');
                memberinfo.Stage = (String)record.get('Stage__c');
                
                memberinfo.lastVarificationPin = (String)record.get('Last_Created_Verification_Pin__c');
                memberinfo.lastVarificationPinTime = (DateTime)record.get('Last_Created_Verification_Pin_Time__c');
                memberinfo.isphoneverified = (Boolean)record.get('Phone_Verified__c');
            }
            else {
                throw new MemberServiceException('Invalid sObject retrived.');
            }
        } catch (Exception e) {
            throw new MemberServiceException(e.getMessage()+'\n'+e.getStackTraceString());
        }
        return memberinfo;
    }

    /**
     * @brief replaces the find account method in DialogFlow_Helper to dynamically search based on Account Share Model.
     * TODO - Impletent Agent based member search, 
     */
    public static List<sObject> findMember(String salesforceRecordUUID, String phonenumber, String firstname, String lastname, String dateofbirthString) {
        String accountId = SYS_DataCacheFactory.accountId;
        List<sObject> results = new List<sObject>();

        if (accountId != NULL) {
            List<Contact> findContact  = new List<Contact>();
            String objectapiname = 'Contact';
            
            if( String.isNotBlank(salesforceRecordUUID) ) {
                if ((salesforceRecordUUID.length() == 15) || (salesforceRecordUUID.length() == 18)) {
                    objectapiname = Id.valueOf(salesforceRecordUUID).getSObjectType().getDescribe().getName();
                }
            }
    
            String accountFilterCriteria = ' WHERE isDeleted = false';
            if( String.isNotBlank(salesforceRecordUUID) ) {
                if ((salesforceRecordUUID.length() == 15) || (salesforceRecordUUID.length() == 18)) {
                    accountFilterCriteria += ' AND Id =: salesforceRecordUUID';
                } else {
                    accountFilterCriteria += ' AND UUID__c =: salesforceRecordUUID';
                }
            } else {
                if( String.isNotBlank(phonenumber) ) {
                    phonenumber = phonenumber.replaceAll('[^\\+\\d]','');
                    accountFilterCriteria += ' AND Formatted_Phone_Number__c =: phonenumber';
                }
                if( String.isNotBlank(firstname) ) {
                    accountFilterCriteria += ' AND firstname =: firstname';
                }
                if( String.isNotBlank(lastname) ) {
                    accountFilterCriteria += ' AND lastname =: lastname';
                }
                if( String.isNotBlank(dateofbirthString) ) {
                    Date DateOfBirth = Date.valueOf(dateofbirthString);
                    accountFilterCriteria += ' AND Birthdate =: DateOfBirth';
                }
            }
            
            String findContactQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor(objectapiname) +
            ' FROM '+objectapiname + accountFilterCriteria + ' ORDER BY CreatedDate DESC';
            System.debug('accountFilterCriteria '+ accountFilterCriteria);
            findContact = Database.query(findContactQuery);

            results = findContact;
        }
        else {
            List<Account> findAccount  = new List<Account>();
            String objectapiname = 'Account';
            
            if( String.isNotBlank(salesforceRecordUUID) ) {
                if ((salesforceRecordUUID.length() == 15) || (salesforceRecordUUID.length() == 18)) {
                    objectapiname = Id.valueOf(salesforceRecordUUID).getSObjectType().getDescribe().getName();
                }
            }
    
            String accountFilterCriteria = ' WHERE isDeleted = false';
            if( String.isNotBlank(salesforceRecordUUID) ) {
                if ((salesforceRecordUUID.length() == 15) || (salesforceRecordUUID.length() == 18)) {
                    accountFilterCriteria += ' AND Id =: salesforceRecordUUID';
                } else {
                    accountFilterCriteria += ' AND UUID__c =: salesforceRecordUUID';
                }
            } else {
                if( String.isNotBlank(phonenumber) ) {
                    phonenumber = phonenumber.replaceAll('[^\\+\\d]','');
                    accountFilterCriteria += ' AND Formatted_Phone_Number__c =: phonenumber';
                }
                if( String.isNotBlank(firstname) ) {
                    accountFilterCriteria += ' AND First_Name__c =: firstname';
                }
                if( String.isNotBlank(lastname) ) {
                    accountFilterCriteria += ' AND Last_Name__c =: lastname';
                }
                if( String.isNotBlank(dateofbirthString) ) {
                    Date DateOfBirth = Date.valueOf(dateofbirthString);
                    accountFilterCriteria += ' AND Date_of_Birth__c =: DateOfBirth';
                }
            }
            
            String findAccountQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Account') +
            ' FROM Account' + accountFilterCriteria + ' ORDER BY CreatedDate DESC';
            findAccount = Database.query(findAccountQuery);

            results = findAccount;

        }
        return results;
    }

    public class MemberServiceException extends Exception { }
}