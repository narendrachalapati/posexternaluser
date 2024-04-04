public without sharing class PortalUserService {
    private System.TriggerOperation triggerEvent;
    public static void handle() {
        handleByOperation(Trigger.New, Trigger.operationType);
    }
    
    public static void handleByOperation(List < Contact > contactList, System.TriggerOperation triggerEvent) {
        
        switch on triggerEvent {
            when AFTER_INSERT { //AFTER_INSERT, AFTER_UPDATE
                Id ManagerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Manager').getRecordTypeId();
                Id VendorRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
                User currentUserRecord = [SELECT ContactId, Contact.Name, Contact.AccountId, Contact.Account.Name, Email,
                                            FirstName, Id, IsActive, LastName, MobilePhone, Name, Phone, ProfileId, Profile.UserLicense.Name, Contact.RecordType.Name,
                                            Username, UserRoleId, UserType FROM User WHERE Id =: UserInfo.getUserId()
                                        ];
                String currentUserLicense =  currentUserRecord.Profile.UserLicense.Name;
                for (Contact currentContact: contactList) {
                    if( (String.isNotBlank(currentContact.Email)) && ( (currentContact.RecordTypeId == ManagerRecordTypeId ) || (currentContact.RecordTypeId == VendorRecordTypeId ) ) ){
                       if ((String.isNotBlank(currentUserLicense)) && (currentUserLicense == 'Salesforce')) {
                           System.debug('currentUserLicense ' + currentUserLicense);
                           createSalesforceUser(currentContact.Id);
                       }else{
                           createPartnerUser(currentContact.Id);
                       }
    
                    }

                }
                 
            }
        }
    }

    @future
    public static void createPartnerUser(Id contactId)
    {
        UserCreationResponse response = new UserCreationResponse();
        Contact currentContact = new Contact();
        String currentRecordProfile;
        currentContact = [Select Id,Name,FirstName,LastName, Phone_Number__c, Email, Account.Name,RecordType.Name FROM Contact where Id =: contactId LIMIT 1];
        if (currentContact.RecordType.Name == 'Manager'){
            currentRecordProfile = 'PMA Manager External App';
        } 
        else if (currentContact.RecordType.Name == 'Vendor') {
            currentRecordProfile = 'PMA Vendor External App';
        } else {
            response.ErrorMessage = 'Profile with Name PMA Manager | Vendor External App not exist';
            return;
        }
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name =: currentRecordProfile LIMIT 1];
        if(partnerProfile == null)
        {
            response.ErrorMessage = 'Profile with Name PMA Manager | Vendor External App not exist';
            return;
        }
        
        List<User> users = [SELECT Id,Name FROM USER WHERE ContactId=:contactId];
        if(!users.isEmpty())
        {
            response.ErrorMessage='User already exist for Contact ('+users[0].Name+')';
            return;
        }
        String userNameSuffix;
        String userName;
        String alias;

        List<Contact> contactsList = [SELECT Id, Name, Email FROM Contact WHERE Email =: currentContact.Email];
        if(contactsList.size() > 1){
            System.debug('Email already exist for Contact ('+contactsList[0].Email+')');
            //Change username to Make unique
            userNameSuffix='pma' +  + Integer.valueof(Math.random() * 1000);
        } else{
            userNameSuffix='pma';
        }
        
        userName = currentContact.Email + '.' + userNameSuffix;
        alias = String.valueof( String.isNotBlank(currentContact.FirstName) ? (currentContact.FirstName.substring(0,1)) : ''  + currentContact.LastName.substring(0,1) + Integer.valueof(Math.random() * 1000) );

        User theUser = new User(
            Username = userName,
            ContactId = currentContact.Id,	
            ProfileId = partnerProfile.Id,
            Alias = alias,
            Email = currentContact.Email,
            Phone = PMA_ExternalSiteFormsUtility.formatPhone(currentContact.Phone_Number__c),
            EmailEncodingKey = 'UTF-8',
            FirstName = currentContact.FirstName,
            LastName = currentContact.LastName,
            CommunityNickname = alias,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
       
        System.debug('theUser ' + theUser);
        insert theUser;
        
       
        response.UserId=theUser.id;
        response.UserName=theUser.Username;
        // return response;
    }

    @future
    public static void createSalesforceUser(Id contactId)
    {
        UserCreationResponse response = new UserCreationResponse();
        Contact currentContact = new Contact();
        String currentRecordProfile;
        currentContact = [Select Id,Name,FirstName,LastName, Phone_Number__c, Email, Account.Name,RecordType.Name FROM Contact where Id =: contactId LIMIT 1];
        currentRecordProfile = 'PMA App';
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name =: currentRecordProfile LIMIT 1];
        if(partnerProfile == null)
        {
            response.ErrorMessage = 'Profile with Name PMA App not exist';
            return;
        }
        
        List<User> users = [SELECT Id,Name FROM USER WHERE ContactId__c=:contactId];
        if(!users.isEmpty())
        {
            response.ErrorMessage='User already exist for Contact ('+users[0].Name+')';
            return;
        }
        String userNameSuffix;
        String userName;
        String alias;

        List<Contact> contactsList = [SELECT Id, Name, Email FROM Contact WHERE Email =: currentContact.Email];
        if(contactsList.size() > 1){
            System.debug('Email already exist for Contact ('+contactsList[0].Email+')');
            //Change username to Make unique
            userNameSuffix='pma' +  + Integer.valueof(Math.random() * 1000);
        } else{
            userNameSuffix='pma';
        }
        
        userName = currentContact.Email + '.' + userNameSuffix;
        alias = String.valueof( String.isNotBlank(currentContact.FirstName) ? (currentContact.FirstName.substring(0,1)) : ''  + currentContact.LastName.substring(0,1) + Integer.valueof(Math.random() * 1000) );

        User theUser = new User(
            Username = userName,
            ContactId__c = currentContact.Id,	
            ProfileId = partnerProfile.Id,
            Alias = alias,
            Email = currentContact.Email,
            Phone = PMA_ExternalSiteFormsUtility.formatPhone(currentContact.Phone_Number__c),
            EmailEncodingKey = 'UTF-8',
            FirstName = currentContact.FirstName,
            LastName = currentContact.LastName,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
       
        System.debug('theUser ' + theUser);
        insert theUser;
        
       
        response.UserId=theUser.id;
        response.UserName=theUser.Username;
        // return response;
    }
}