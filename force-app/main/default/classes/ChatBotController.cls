public with sharing class ChatBotController {

    public class ChatBotControllerException extends Exception {}

    public class InboxMember{
        @AuraEnabled
        public Id recordId;
        @AuraEnabled
        public String objectApiName;
        @AuraEnabled
        public String contactName;
        @AuraEnabled
        public String contactPhoneNumber;
        @AuraEnabled
        public String externalPhoneNumber;
        @AuraEnabled
        public String shortNameCode;
        @AuraEnabled
        public Boolean hasPictureURL = false;
        @AuraEnabled
        public String pictureURL;

        @AuraEnabled
        public Inbox__c inboxrecord = new Inbox__c(); //MemberListview Inbox Record Data

        @AuraEnabled
        public Activity__c activity = new Activity__c();//Not Using
        @AuraEnabled
        public List<Activity__c> paginatedActivitiesList = new List<Activity__c>(); //Member Specific Specific Page Activities
        @AuraEnabled
        public List<Activity__c> latestActivities = new List<Activity__c>();

        @AuraEnabled 
        public Integer totalPages; //Member Specific Total Pages 
        @AuraEnabled
        public Integer totalActivityRecords; //Member Specific all Activities Count
        @AuraEnabled
        public String newMessage; //MemberListview Latest Message SMS MMS Call
        @AuraEnabled
        public Double unreadMessagesCount = 0;  //MemberListview New Unread Messages Count   
        @AuraEnabled
        public Double latestActivityNumber; //MemberListview Member Latest Activity Number    
    }

    //GET Reversed Activities List
    public static List<Activity__c> getReversedActivitiesList(List<Activity__c> activitiesList){
        List<Activity__c> reversedActivitiesList = new List<Activity__c>();
        for(Integer i = activitiesList.size() - 1; i >= 0; i--){
            reversedActivitiesList.add(activitiesList[i]);
        }
        return reversedActivitiesList;
    }

    //GET Contact Name from Inbox Record
    public static String getContactNameFromInboxRecord(Inbox__c inboxRecord){
        String memberName;
        if(inboxRecord.Contact__c != null){
            memberName = (String.isNotBlank(inboxRecord.Contact__r.FirstName) ? inboxRecord.Contact__r.FirstName : '') + '' + (String.isNotBlank(inboxRecord.Contact__r.LastName) ? ' ' + inboxRecord.Contact__r.LastName : '');
        }
        // if(inboxRecord.Account__c != null){
        //     memberName = inboxRecord.Account__r.Name;
        // }
        // if(inboxRecord.Lead__c != null){
        //     memberName = (String.isNotBlank(inboxRecord.Lead__r.FirstName) ? inboxRecord.Lead__r.FirstName : '') + '' + (String.isNotBlank(inboxRecord.Lead__r.LastName) ? ' ' + inboxRecord.Lead__r.LastName : '');
        // }
        memberName = String.isBlank(memberName) ? inboxRecord.External_Contact_Point__c : memberName;
        return memberName;
    }

    //Create InboxMember from List of Activity__c for single member
    public static InboxMember registerActivityRecordsList(List<Activity__c> ActivityRecordsList){
        List<Activity__c> selectedMemberActivityList = new List<Activity__c>();
        Activity__c getFirstActivity = ActivityRecordsList.get(ActivityRecordsList.size() -1);
        String IterRecordPictureURL = 'noimage';
        String IterContactName = ActivityTriggerHandler.getContactNameFromActivityRecord(getFirstActivity);
        InboxMember selectedActivityInboxMember = new InboxMember();
        selectedActivityInboxMember.recordId = getFirstActivity.WhatId__c;
        selectedActivityInboxMember.objectApiName = getFirstActivity.WhatId_ObjectApi_Name__c;
        selectedActivityInboxMember.contactName = IterContactName;
        selectedActivityInboxMember.contactPhoneNumber = getFirstActivity.Formatted_Phone__c;
        selectedActivityInboxMember.externalPhoneNumber = getFirstActivity.External_Number__c;
        selectedActivityInboxMember.shortNameCode = ImageController.getShortendImageName(IterContactName);
        selectedActivityInboxMember.hasPictureURL = (IterRecordPictureURL=='noimage') ? false : true;
        selectedActivityInboxMember.pictureURL = IterRecordPictureURL;
        selectedActivityInboxMember.paginatedActivitiesList = ActivityRecordsList;
        return selectedActivityInboxMember;
    }

    //Create List<InboxMember> from List of Inbox__c
    public static List<InboxMember> registerInboxRecordsList(List<Inbox__c> inboxRecordsList){
        List<InboxMember> inboxmemberList = new List<InboxMember>();
        for(Inbox__c inboxRecord :inboxRecordsList){
            String IterRecordPictureURL = 'noimage';
            String IterContactName = getContactNameFromInboxRecord(inboxRecord);
            InboxMember currentInboxMemberWrap = new InboxMember();
            currentInboxMemberWrap.recordId = inboxRecord.WhatId__c;
            currentInboxMemberWrap.objectApiName = inboxRecord.WhatId_ObjectApi_Name__c;
            currentInboxMemberWrap.contactName = IterContactName;
            currentInboxMemberWrap.contactPhoneNumber = inboxRecord.External_Contact_Point__c;
            currentInboxMemberWrap.externalPhoneNumber = inboxRecord.External_Phone__c;
            currentInboxMemberWrap.shortNameCode = ImageController.getShortendImageName(IterContactName);
            currentInboxMemberWrap.hasPictureURL = (IterRecordPictureURL=='noimage') ? false : true;
            currentInboxMemberWrap.pictureURL = IterRecordPictureURL;
            currentInboxMemberWrap.inboxrecord = inboxRecord;
            currentInboxMemberWrap.latestActivityNumber =  (inboxRecord.Latest_Activity_Number__c != null) ? inboxRecord.Latest_Activity_Number__c : 0; 
            currentInboxMemberWrap.newMessage = inboxRecord.Latest_Message__c;            
            currentInboxMemberWrap.unreadMessagesCount = inboxRecord.Unread_Activities__c;            
            inboxmemberList.add(currentInboxMemberWrap);
        }
        return inboxmemberList;
    }

    //Create List<InboxMember> from List of Contacts
    public static List<InboxMember> registerContactRecordsList(List<Contact> contacts){
        List<InboxMember> inboxmemberList = new List<InboxMember>();
        for(Contact contactRecord :contacts){
            String IterContactRecordPictureURL = 'noimage';
            String IterContactName = (String.isNotBlank(contactRecord.FirstName) ? contactRecord.FirstName : '') + '' + (String.isNotBlank(contactRecord.LastName) ? ' ' + contactRecord.LastName : '');
            InboxMember IterContactInboxMemberWrap = new InboxMember();
            IterContactInboxMemberWrap.recordId = contactRecord.Id;
            IterContactInboxMemberWrap.objectApiName = 'Contact';
            IterContactInboxMemberWrap.contactName = IterContactName;
            IterContactInboxMemberWrap.contactPhoneNumber = contactRecord.Formatted_Phone_Number__c;
            IterContactInboxMemberWrap.shortNameCode = ImageController.getShortendImageName(IterContactName);
            IterContactInboxMemberWrap.hasPictureURL = (IterContactRecordPictureURL=='noimage') ? false : true;
            IterContactInboxMemberWrap.pictureURL = IterContactRecordPictureURL;
            IterContactInboxMemberWrap.latestActivityNumber =  0;
            IterContactInboxMemberWrap.newMessage = 'Say Hello!';
            inboxmemberList.add(IterContactInboxMemberWrap);
        }
        return inboxmemberList;
    }

    //Create List<InboxMember> from List of Accounts
    public static List<InboxMember> registerAccountRecordsList(List<Account> accounts){
        List<InboxMember> inboxmemberList = new List<InboxMember>();
        for(Account accountRecord :accounts){
            String IterAccountRecordPictureURL = 'noimage';
            String IterAccountName = accountRecord.Name;
            InboxMember IterAccountInboxMemberWrap = new InboxMember();
            IterAccountInboxMemberWrap.recordId = accountRecord.Id;
            IterAccountInboxMemberWrap.objectApiName = 'Account';
            IterAccountInboxMemberWrap.contactName = IterAccountName;
            IterAccountInboxMemberWrap.contactPhoneNumber = accountRecord.Formatted_Phone_Number__c;
            IterAccountInboxMemberWrap.shortNameCode = ImageController.getShortendImageName(IterAccountName);
            IterAccountInboxMemberWrap.hasPictureURL = (IterAccountRecordPictureURL=='noimage') ? false : true;
            IterAccountInboxMemberWrap.pictureURL = IterAccountRecordPictureURL;
            IterAccountInboxMemberWrap.latestActivityNumber =  0;
            IterAccountInboxMemberWrap.newMessage = 'Say Hello!';
            inboxmemberList.add(IterAccountInboxMemberWrap);
        }
        return inboxmemberList;
    }

    //Create List<InboxMember> from List of Leads
    public static List<InboxMember> registerLeadRecordsList(List<Lead> leads){
        List<InboxMember> inboxmemberList = new List<InboxMember>();
        for(Lead leadRecord :leads){
            String IterLeadRecordPictureURL = 'noimage';
            String IterLeadName = (String.isNotBlank(leadRecord.FirstName) ? leadRecord.FirstName : '') + '' + (String.isNotBlank(leadRecord.LastName) ? ' ' + leadRecord.LastName : '');
            InboxMember IterLeadInboxMemberWrap = new InboxMember();
            IterLeadInboxMemberWrap.recordId = leadRecord.Id;
            IterLeadInboxMemberWrap.objectApiName = 'Lead';
            IterLeadInboxMemberWrap.contactName = IterLeadName;
            IterLeadInboxMemberWrap.contactPhoneNumber = leadRecord.Formatted_Phone_Number__c;
            IterLeadInboxMemberWrap.shortNameCode = ImageController.getShortendImageName(IterLeadName);
            IterLeadInboxMemberWrap.hasPictureURL = (IterLeadRecordPictureURL=='noimage') ? false : true;
            IterLeadInboxMemberWrap.pictureURL = IterLeadRecordPictureURL;
            IterLeadInboxMemberWrap.latestActivityNumber =  0;
            IterLeadInboxMemberWrap.newMessage = 'Say Hello!';
            inboxmemberList.add(IterLeadInboxMemberWrap);
        }
        return inboxmemberList;
    }

    //Create List<InboxMember> from List of Sobjects[] SOSL results
     public static List<InboxMember> registerMemberSearchResultsList(List<List<sObject>> InboxMemberSearchResults){
        List<InboxMember> inboxmemberList = new List<InboxMember>();
        List<Contact> contacts = (List<Contact>)InboxMemberSearchResults[0];
        List<Account> accounts = (List<Account>)InboxMemberSearchResults[1];
        List<Lead> leads = (List<Lead>)InboxMemberSearchResults[2];
        if(InboxMemberSearchResults.size()>0){
            if(contacts.size() > 0){
                inboxmemberList.addAll(registerContactRecordsList(contacts));                
            }
            // if(accounts.size() > 0){
            //     inboxmemberList.addAll(registerAccountRecordsList(accounts));                
            // }
            // if(leads.size() > 0){
            //     inboxmemberList.addAll(registerLeadRecordsList(leads));
            // }
        }       

        return inboxmemberList;
    }

    /*
    //Filter and get Unique Records based on field
    public static SObject[] getUniqueValues(SObject[] records, String sobjectFieldString) {
        Map<Object, SObject> uniqueValues = new Map<Object, SObject>();

        List<String> splitString = sobjectFieldString.split('\\.');
        String objectName = splitString[0];
        String fieldName = splitString[1];
            
        SObjectType objectType = ((SObject)Type.forName(objectName).newInstance()).getSObjectType();
        SObjectField objectField = objectType.getDescribe().fields.getMap().get(fieldName);

        for(SObject record: records) {
            if(!uniqueValues.containsKey(record.get(objectField))) {
                uniqueValues.put(record.get(objectField), record);
            }
        }
        return uniqueValues.values();
    }
    */

    //Mark messages as read for selected member
    @AuraEnabled
    public static Boolean markMessagesAsRead(String recordId, String phoneNumber) {
        List<Activity__c> activityListFiltered = new List<Activity__c>();
        Database.SaveResult[] results;
        Boolean success = true;

        String ObjectApiName = String.isNotBlank(recordId) ? Id.valueOf(recordId).getSObjectType().getDescribe().getName() : '';
        Boolean isSupportedObjectApiName = ( (ObjectApiName == 'Contact') || (ObjectApiName == 'Account') || (ObjectApiName == 'Lead') ) ? true : false;
        
        String activityFilterCriteria = ' WHERE ';
        if (String.isNotBlank(phoneNumber) ){
            activityFilterCriteria += 'Formatted_Phone__c =: phoneNumber';
        } else if(String.isNotBlank(recordId) && (isSupportedObjectApiName == true) ){
            activityFilterCriteria += 'WhatId__c =: recordId';
        }

        String totalUnreadActivitiesQuery = 'SELECT Id, Name, IsUnread__c, IsDeleted FROM Activity__c' + activityFilterCriteria + ' AND IsUnread__c = true AND IsDeleted = false';
        activityListFiltered = Database.query(totalUnreadActivitiesQuery);
        if(activityListFiltered.size() > 0){
            for(Activity__c iterActivity : activityListFiltered){
                iterActivity.IsUnread__c = false;
            }
            results = Database.update(activityListFiltered, false);
            if(!results[0].isSuccess()){
                success = false;
            }   
            if (String.isNotBlank(phoneNumber)) {
                String fetchInboxRecordQuery = 'SELECT Id, Name, Phone__c, External_Contact_Point__c, Unread_Activities__c, IsDeleted FROM Inbox__c WHERE (External_Contact_Point__c =: phoneNumber) AND IsDeleted = false ORDER BY Latest_Message_Received_At__c DESC LIMIT 1';
                List<Inbox__c> inboxList = Database.query(fetchInboxRecordQuery);
                if(inboxList.size() > 0) {
                    for(Inbox__c inboxRecord: inboxList){
                        inboxRecord.Unread_Activities__c = 0;
                    }
                    Schema.SObjectField externalIdField = Inbox__c.Fields.External_Contact_Point__c;
                    Database.UpsertResult[] srList = Database.upsert(inboxList, externalIdField, false);
                    if(!srList[0].isSuccess()){
                        success = false;
                    }  
                }
            }
        }
        return success;
    }

    //Fetch Contact List Wrapper with Latest Unread messages
    @AuraEnabled
    public static List<InboxMember> contactSearch(String searchkey, Double storedActivityNumber, String contactPhoneNumber, String currentContactId) {
        //storedActivityNumber - When 
        //currentContactId - when contact is selected
        String searchfilterKey = '\'%'+ String.escapeSingleQuotes(searchkey) + '%\'';
        String searchfilterKeyStartsWith = '*' + String.escapeSingleQuotes(searchkey) + '*';

        List<InboxMember> InboxMembersList = new List<InboxMember>();

        Integer remainingRows = Limits.getLimitQueryRows() - Limits.getQueryRows();
        System.debug('remainingRows ' + remainingRows);
        
        //Search Inbox Object
        //Search SOSL Using Keyword 
        if(String.isBlank(searchkey)){ // Without Search Pooling
            String inboxRecordsQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Inbox__c') +
                ', ' + SYS_Helper.getAllParentFields('Lead__r.', 'Lead') +
                ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
                ', ' + SYS_Helper.getAllParentFields('Contact__r.', 'Contact') +
                ' FROM Inbox__c ORDER BY Latest_Message_Received_At__c DESC LIMIT 10'; 
            List<Inbox__c> inboxRecordsList = Database.query(inboxRecordsQuery);  
            if(inboxRecordsList.size() > 0 ){
                //Create ActivityContactListWrapper from Inbox__c records
                InboxMembersList = registerInboxRecordsList(inboxRecordsList);
            }
            //TO-DO 10-15 Records Dynamic LIMITs 
        }else{ // Search Based Filter
            //Implement Pagination Prev - First - Next  Page Size 20
            String inboxSearchQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Inbox__c') +
                ', ' + SYS_Helper.getAllParentFields('Lead__r.', 'Lead') +
                ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
                ', ' + SYS_Helper.getAllParentFields('Contact__r.', 'Contact') +
                ' FROM Inbox__c WHERE ( Contact__r.FirstName LIKE ' + searchfilterKey + ' OR Contact__r.LastName LIKE ' + searchfilterKey  + ' OR Contact__r.Formatted_Phone_Number__c LIKE ' + searchfilterKey  + ' OR Account__r.Name LIKE ' + searchfilterKey  + ' OR Lead__r.FirstName LIKE ' + searchfilterKey  + ' OR Lead__r.LastName LIKE ' + searchfilterKey  + ' OR External_Contact_Point__c LIKE ' + searchfilterKey + ' ) ORDER BY Latest_Message_Received_At__c DESC LIMIT 10'; 
            List<Inbox__c> inboxSearchRecordsList = Database.query(inboxSearchQuery); 
            if(inboxSearchRecordsList.size() > 0 ){
                //Create InboxMember from Inbox__c records
                InboxMembersList = registerInboxRecordsList(inboxSearchRecordsList);
            }else{
                //SOSL on Contact Account Lead
                //IN All FIELDS
                List<List<sObject>> MemberSearchResults = [FIND :searchfilterKeyStartsWith RETURNING Contact(FirstName,LastName, Formatted_Phone_Number__c WHERE Formatted_Phone_Number__c != null  ORDER BY CreatedDate DESC), Account(Name, Formatted_Phone_Number__c WHERE Formatted_Phone_Number__c != null ORDER BY CreatedDate DESC), Lead(FirstName,LastName, Formatted_Phone_Number__c WHERE Formatted_Phone_Number__c != null AND isConverted = false ORDER BY CreatedDate DESC)];       
                System.debug('MemberSearchResults ' + MemberSearchResults);
                InboxMembersList = registerMemberSearchResultsList(MemberSearchResults);
            }  
        }       
        return InboxMembersList;
    } 

    //Fetch activity messages for contact
    @AuraEnabled
    public static InboxMember getMessagesByRecordId(String recordId, String phoneNumber, Integer messagesLimitPerPage , Integer currentPage) {
        List<Activity__c> activityListFiltered = new List<Activity__c>();
        InboxMember selectedMember = new InboxMember();
        //Pagination Variables
        Integer selectedMemberTotalActivities = 0;// Total Activities        
        Integer currentOffset = (currentPage - 1) * messagesLimitPerPage;//currentOffset
        String ObjectApiName = String.isNotBlank(recordId) ? Id.valueOf(recordId).getSObjectType().getDescribe().getName() : '';
        Boolean isSupportedObjectApiName = ( (ObjectApiName == 'Contact') || (ObjectApiName == 'Account') || (ObjectApiName == 'Lead') ) ? true : false;

        //If In Isolated Conversation Component Fetch Phone number to query old activities
        if( (String.isNotBlank(recordId)) && (String.isBlank(phoneNumber)) && (isSupportedObjectApiName == true) ){
            String fetchFormattedPhoneSpecificQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor(ObjectApiName) +
            ' FROM ' + ObjectApiName + ' WHERE Id =: recordId ORDER BY CreatedDate DESC LIMIT 1';
            List<SObject> SObjectList = Database.query(fetchFormattedPhoneSpecificQuery);
            if(SObjectList.size() > 0){
                phoneNumber = String.valueOf(SObjectList[0].get('Formatted_Phone_Number__c'));
            }
        } 
        
        String activityFilterCreteria = ' WHERE ';
        if (String.isNotBlank(phoneNumber) ){
            activityFilterCreteria += 'Formatted_Phone__c =: phoneNumber';
        } else if(String.isNotBlank(recordId) && (isSupportedObjectApiName == true) ){
            activityFilterCreteria += 'WhatId__c =: recordId';
        }
        //Mark Selected Member Activities as Read and Reset inbox unreadCount
        if (String.isNotBlank(phoneNumber) || String.isNotBlank(recordId) ){
            Boolean updateStatus = markMessagesAsRead(recordId, phoneNumber);
        }
        // Set Selected Member Total Messages for
        // Contact Change or Reload or No Messages or Messages less than Page size
        if(currentPage  == 1){
            String totalActivitiesQuery = 'SELECT Count() FROM Activity__c' + activityFilterCreteria + ' AND IsDeleted = false';
            selectedMemberTotalActivities = Database.countQuery(totalActivitiesQuery);
        }

        String selectedMemberFilterActivityQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Activity__c') +
                ', ' + SYS_Helper.getAllParentFields('Lead__r.', 'Lead') +
                ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
                ', ' + SYS_Helper.getAllParentFields('Contact__r.', 'Contact') +
                ', ( SELECT ' + SYS_Helper.getAllFieldsFor('Media_URL__c') + ' FROM Media_Urls__r)' +
                ' FROM Activity__c' + activityFilterCreteria + ' ORDER BY When__c DESC ' + 'LIMIT :messagesLimitPerPage OFFSET :currentOffset';
        //TO-DO Check if is getting new unread messages also effecting pagination         
        activityListFiltered = Database.query(selectedMemberFilterActivityQuery);
        if(activityListFiltered.size() > 0){     
            List<Activity__c> reversedActivityList = getReversedActivitiesList(activityListFiltered);   
            selectedMember = registerActivityRecordsList(reversedActivityList);            
            Double PageSize = Double.valueOf(messagesLimitPerPage);
            Double MemberTotalActivities = Double.valueOf(selectedMemberTotalActivities);
            selectedMember.totalPages = Integer.valueOf(Math.ceil( MemberTotalActivities/ PageSize ) );
            selectedMember.totalActivityRecords = selectedMemberTotalActivities;
        } else{ //Instantiate Wrapper with Specific Object Info
            List<InboxMember> inboxmemberList = new List<InboxMember>();
            //Filter Creteria for Secific Objects
            String objectSpecificFilterCriteria = ' WHERE ';
            if(String.isNotBlank(recordId) && (isSupportedObjectApiName == true) ){
                objectSpecificFilterCriteria += 'Id =: recordId';
            }else{
                objectSpecificFilterCriteria += 'Formatted_Phone__c =: phoneNumber';
            }
            // Add exclude filter for converted leads
            if(ObjectApiName == 'Lead'){
                objectSpecificFilterCriteria += ' AND isConverted = false';
            }
            //If Objects are in supported list then create a wrapper
            if(isSupportedObjectApiName == true){
                String selectedMemberobjectSpecificQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor(ObjectApiName) +
                ' FROM ' + ObjectApiName + '' + objectSpecificFilterCriteria + ' ORDER BY CreatedDate DESC ' + 'LIMIT 1';
                if(ObjectApiName == 'Contact'){
                    List<Contact> contacts = Database.query(selectedMemberobjectSpecificQuery);
                    inboxmemberList = registerContactRecordsList(contacts);
                }
                // if(ObjectApiName == 'Account'){
                //     List<Account> accounts = Database.query(selectedMemberobjectSpecificQuery);
                //     inboxmemberList = registerAccountRecordsList(accounts);
                // } else if(ObjectApiName == 'Lead'){
                //     List<Lead> leads = Database.query(selectedMemberobjectSpecificQuery);
                //     inboxmemberList = registerLeadRecordsList(leads);
                // } else if(ObjectApiName == 'Contact'){
                //     List<Contact> contacts = Database.query(selectedMemberobjectSpecificQuery);
                //     inboxmemberList = registerContactRecordsList(contacts);
                // }
            }        
            selectedMember = (inboxmemberList.size() > 0) ? inboxmemberList[0] : new InboxMember();
            //Reset Pages and Activity count for new Member
            selectedMember.totalPages = 0;
            selectedMember.totalActivityRecords = 0;
        } 
        return selectedMember;
    }

    @AuraEnabled
    public static Activity__c createActivity(String type, List<String> mediaUrls, String messagebody, String messageSubject,String fromPhone, String toPhone, Id recordId, String accountId) {
        Boolean invokeOutboundFlow = false;
        Activity__c createActivityRecord = CustomActivityService.createActivity(invokeOutboundFlow, type, mediaUrls, messagebody, messageSubject, fromPhone, toPhone, recordId, accountId);

        return createActivityRecord;
    }


    @AuraEnabled
    public static Activity__c ApiCalloutSynchronous(Id accountRecordId, Id recordId, String httpMethod, String operationType, String integrationSetting, String type) {
        accountRecordId = (accountRecordId != NULL) ? accountRecordId : NULL;
        if( (accountRecordId != NULL) && (recordId != accountRecordId) ) {
            SYS_DataCacheFactory initDataCache = new SYS_DataCacheFactory(new List<String>{accountRecordId}, integrationSetting, null, null);
        }
        String objectSetting = SYS_DataCacheFactory.metadata.containsKey(type) ? SYS_DataCacheFactory.metadata.get(type) : 'PlivoSMS';

        String query = 'SELECT '+SYS_Helper.getAllFieldsFor('Activity__c') +' FROM Activity__c';
        String whereClause = ' WHERE Id = \'' + String.escapeSingleQuotes(recordId) + '\'';
        List<Activity__c> smsActivityList = Database.query(String.escapeSingleQuotes(query)+whereClause);
        
        if(accountRecordId != NULL){
            SYS_DataCacheFactory init = new SYS_DataCacheFactory(
                accountRecordId,
                integrationSetting,
                integrationSetting,
                objectSetting
            );
        } else {
            SYS_DataCacheFactory init = new SYS_DataCacheFactory(
                new List<String>{''},
                NULL,
                integrationSetting,
                objectSetting
            );
        }
        
        List<SYS_IntegrationLog__c> outboundRequestSysLogs = new List<SYS_IntegrationLog__c>();
        List<sObject> outboundResponseLogs = new List<sObject>();
        String finalJsonForOutbound;   

        SYS_ApplicationService appService = (SYS_ApplicationService)System.Type.forName(SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).ApexHandler__c).newInstance();
       
        Map<Id, String> jsonListForOutbound = appService.transformSObjectToJson(smsActivityList);
        
        if(jsonListForOutbound.values().size() > 0){
            for(Id jsonRecordId:jsonListForOutbound.keyset()){ 
                /*
                Pre-processing each transformed JSON record. Default is to remove newlines.
                For Custom pre-processing override sanitizeJSONForOutbound() method in SYS_ApplicationService
                by creating an extension class. Configure the new extended class in ObjectSettings metadata
                */
                finalJsonForOutbound = appService.sanitizeJSONForOutbound(jsonListForOutbound.get(jsonRecordId));
                /*--*/SYS_debug.log('cleanJSON'+finalJsonForOutbound); 

                SYS_IntegrationLog__c  newSysLog = SYS_Helper.getLogsToInsert(finalJsonForOutbound);
                newSysLog.Callout_URL__c = SYS_Helper.urlFromPattern(httpMethod, jsonRecordId);
                newSysLog.Status__c = 'NEW';
                newSysLog.Type__c = SYS_Constants.OUTBOUND;
                newSysLog.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
                newSysLog.SYS_Operation_Type__c = operationType;
                newSysLog.How_to_process__c = 'ignore_log';
                newSysLog.whatid__c = jsonRecordId;
                newSysLog.HTTP_Method__c = httpMethod;
                newSysLog.ObjectSettingId__c = SYS_DataCacheFactory.OBJ_TYPE;
                newSysLog.Account_Id__c = SYS_DataCacheFactory.accountId;
                newSysLog.Integration_Type__c = SYS_DataCacheFactory.integrationType;
                outboundRequestSysLogs.add(newSysLog);
            }

            if(!outboundRequestSysLogs.isEmpty() && SYS_DataCacheFactory.enableCheck){ 
                SYS_IntegrationLog__c outboundRequestLog = outboundRequestSysLogs[0]; 
                System.debug('outboundRequestLog ' + outboundRequestLog);
                HttpResponse outboundResponse = appService.doOutbound(outboundRequestLog);
                outboundResponseLogs.addAll(appService.generatelogForOutboundResultNew(outboundResponse, outboundRequestLog));
            }

            if(outboundResponseLogs.size() > 0){
                SYS_Helper.upsertLog(outboundResponseLogs);  
                Map<String, String> uuidMap = new Map<String, String>();
                for(sObject log : outboundResponseLogs) {
                    if(((SYS_IntegrationLog__c)log).UUID__c != NULL) {
                        uuidMap.put(((SYS_IntegrationLog__c)log).UUID__c, ((SYS_IntegrationLog__c)log).Id);
                    }
                }
                for(sObject log : outboundResponseLogs) {
                    if(((SYS_IntegrationLog__c)log).Parent_UUID__c != NULL) {
                        ((SYS_IntegrationLog__c)log).SYS_RequestId__c = uuidMap.get(((SYS_IntegrationLog__c)log).Parent_UUID__c);
                    }
                }
                SYS_Helper.upsertLog(outboundResponseLogs);
            } 
        }

        Activity__c syncedActivity = CustomActivityService.getActivityById(recordId);
        return syncedActivity;
    }

    /* File Attachments Component */
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks   
        if ( String.isBlank(fileId) ) {
            fileId = saveTheFile(parentId, fileName, base64Data);
        } else {
            appendToFile(fileId, base64Data);
        }
        return Id.valueOf(fileId);
    }

    private static Id saveTheFile(Id recordId, String fileName, String base64Data )  {         
        ContentVersion contentToInsert =new ContentVersion(); 
        contentToInsert.Title =fileName; 
        contentToInsert.VersionData=EncodingUtil.base64Decode(base64Data);
        contentToInsert.PathOnClient='/' + fileName ;
        contentToInsert.IsMajorVersion = false;
        insert contentToInsert; 
        
        contentToInsert = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentToInsert.Id];
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.ContentDocumentId = contentToInsert.ContentDocumentId;
        cl.LinkedEntityId = recordId; 
        cl.ShareType = 'V';
        cl.Visibility = 'AllUsers';
        insert cl;
        
        return contentToInsert.id;
    }

    private static void appendToFile(Id contentDocumentId, String base64Data) {
        // base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion versionData = [
            SELECT Id, VersionData,ContentDocumentId
            FROM ContentVersion
            WHERE Id = :contentDocumentId
        ];
        String existingBody = EncodingUtil.base64Encode(versionData.VersionData);
        versionData.VersionData = EncodingUtil.base64Decode(existingBody + base64Data); 

        update versionData;
    }

    /* To Callout Media Upload Api and Create MMS Activity */
    @AuraEnabled
    public static UploadApiResponseWrapper submitAttachment(Id contentVersionId, String currentfileType, String messageSubject, String fromPhone, String toPhone, String recordId, String accountId) {
        List<String> mediaUrls = new List<String>();     
        List<String> mediaErrorMessages = new List<String>();     
        Activity__c createdMmsActivity = new Activity__c();
        UploadApiResponseWrapper uploadApiResponseWrapper = new UploadApiResponseWrapper();
        Id createdActivityId;

        // HTTPResponse resp = h.send(req);
        HTTPResponse resp = uploadFileToPlivo(contentVersionId, currentfileType, accountId);
        SYS_debug.log('#### resp status: '+resp.getStatus());
        SYS_debug.log('#### resp code: '+resp.getStatusCode());
        SYS_debug.log('#### resp: '+resp.getBody());
        String responsejson = resp.getBody();
        PlivoMediaUploadWrapper uploadResponseObject = PlivoMediaUploadWrapper.parse(responsejson);
        if( (uploadResponseObject != null) && (uploadResponseObject.objects != null) ){
            List<PlivoMediaUploadWrapper.cls_objects> objList = uploadResponseObject.objects;
            uploadApiResponseWrapper.UploadApiResponseList = objList;
        }            
        if(resp.getStatusCode() == 200 || resp.getStatusCode() == 201 || resp.getStatusCode() == 207) {
            mediaUrls = PlivoMediaUploadWrapper.parseMediaUrls(responsejson);
            if(mediaUrls.size() > 0){
                createdMmsActivity = createActivity('mms', mediaUrls, '', messageSubject, fromPhone, toPhone, recordId, accountId);
                createdActivityId = createdMmsActivity.Id;
                uploadApiResponseWrapper.activityRecord = createdMmsActivity;
                uploadApiResponseWrapper.status = 'success';
                uploadApiResponseWrapper.statusCode = 200;
            } else {
                mediaErrorMessages = PlivoMediaUploadWrapper.parseErrorMessages(responsejson);
                uploadApiResponseWrapper.errorMessages = mediaErrorMessages;
                uploadApiResponseWrapper.status = 'error';
                uploadApiResponseWrapper.statusCode = 400;
            } 
        } else {
            mediaErrorMessages = new List<String>{'API Error: Failed to Upload File'};
            uploadApiResponseWrapper.errorMessages = mediaErrorMessages;
            uploadApiResponseWrapper.status = 'error';
            uploadApiResponseWrapper.statusCode = 400;
        }
        Database.SaveResult result = generateLogForMediaUpload(resp , createdActivityId);            
        
        return uploadApiResponseWrapper;
    }

    public static HTTPResponse uploadFileToPlivo(Id contentVersionId, String currentfileType, String accountId) {
        UploadApiResponseWrapper uploadApiResponseWrapper = new UploadApiResponseWrapper();
        Id createdActivityId;
        HTTPResponse resp;

        String query = 'SELECT Id,FileType, ContentDocument.title, VersionData FROM ContentVersion WHERE Id = :contentVersionId AND IsLatest = true';
        SYS_debug.log('query==' + query);
        List<ContentVersion> contentList = Database.query(query);
        if (contentList.size() > 0) {
            ContentVersion contentRecord = contentList[0];
            Blob file_body = contentRecord.VersionData;
            String file_name = contentRecord.ContentDocument.title;
            String fileType = contentRecord.FileType.toLowercase();
            String boundary = '----------------------------064165664171278740915233';
            String header = '--' + boundary + '\n' +
                'Content-Disposition: form-data; name="file"; filename="' + file_name + '";\n' +
                'Content-Type: ' + currentfileType;
            String footer = '--' + boundary + '--';
            String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));

            while (headerEncoded.endsWith('=')) {
                header += ' ';
                headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));
            }

            String bodyEncoded = EncodingUtil.base64Encode(file_body);
            Blob bodyBlob = null;
            String last4Bytes = bodyEncoded.substring(bodyEncoded.length() - 4, bodyEncoded.length());
            if (last4Bytes.endsWith('==')) {
                last4Bytes = last4Bytes.substring(0, 2) + '0K';
                bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length() - 4) + last4Bytes;
                String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
            } else if (last4Bytes.endsWith('=')) {
                last4Bytes = last4Bytes.substring(0, 3) + 'N';
                bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length() - 4) + last4Bytes;
                footer = '\n' + footer;
                String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
            } else {
                footer = '\r\n' + footer;
                String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
            }

            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://api.plivo.com/v1/Account/MAZJM3ZDZLNWRKZWJJYW/Media/');
            //Init Appservice and DataCache
            String integrationSetting = 'Plivo';
            SYS_DataCacheFactory init = new SYS_DataCacheFactory(
                accountId,
                integrationSetting,
                integrationSetting,
                null
            );

            String oauthGrantType = SYS_DataCacheFactory.integrationSetting.AuthenticationType__c;
            if (oauthGrantType.toLowerCase() == 'oauth') {
                List < SYS_OAuthConfig__c > configs = SYS_DataCacheFactory.authRec;
                if (configs.size() > 0) {
                    if ((configs[0].Grant_Type__c == 'password') && (configs[0].Token_type__c == 'Basic')) {
                        String Username = configs[0].Username__c;
                        String Password = configs[0].Password__c;
                        Blob headerValue = Blob.valueOf(Username + ':' + Password);
                        String authorizationHeader = EncodingUtil.base64Encode(headerValue);
                        req.setHeader('Authorization', configs[0].Token_type__c + ' ' + authorizationHeader);
                    }
                    if ((configs[0].Grant_Type__c == 'authorization_code') && (configs[0].Token_type__c == 'Bearer')) {
                        req.setHeader('Authorization', configs[0].Token_type__c + ' ' + configs[0].Access_Token__c);
                    }
                }
            }

            req.setHeader('Connection', 'keep-alive');
            req.setHeader('accept-encoding', 'gzip, deflate, br');
            
            String contentLength = string.valueOf(bodyBlob.size());
            req.setHeader('Content-Length', contentLength);

            String contentType = 'multipart/form-data; boundary="' + boundary + '"';
            req.setHeader('Content-Type', contentType);

            req.setMethod('POST');
            req.setBodyAsBlob(bodyBlob);
            req.setTimeout(120000);

            Http h = new Http();
            resp = h.send(req);
        }
        return resp;
    }

    /*
    //Google Drive Media Upload -- Earlier saveChunk -SF Store
    public static GoogleDriveFile__c uploadFileToGoogleDrive(Id recordId, String accountMergeField, String fileName, String base64Data, String contentType) {
        GoogleDriveFile__c Googlefile = new GoogleDriveFile__c();
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        String integrationSettingtype = 'GoogleDrive';
        String fetchRecordQuery, accountId, googeldrivfolderId;
        List<Sobject> fetchRecord = new list<Sobject>();
        fetchRecordQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor(sObjName) +
            ' FROM ' + sObjName + '  WHERE Id =:recordId';
        fetchRecord = Database.query(fetchRecordQuery);
        if (fetchRecord.size() > 0) {
            accountId = (String) fetchRecord[0].get(accountMergeField);
        }
        String objectSetting = SYS_DataCacheFactory.metadata.containsKey(sObjName) ? SYS_DataCacheFactory.metadata.get(sObjName) : 'GoogleFile_Object_Setting';
        if (accountId != NULL) {
            SYS_DataCacheFactory init = new SYS_DataCacheFactory(
                accountId,
                integrationSettingtype,
                integrationSettingtype,
                objectSetting
            );
        } else {
            SYS_DataCacheFactory init = new SYS_DataCacheFactory(
                new List < String > {''},
                NULL,
                integrationSettingtype,
                objectSetting
            );
        }

        List<SYS_OAuthConfig__c> Oauth = SYS_DataCacheFactory.authRec;
        String accessToken = Oauth[0].Access_Token__c;
        List<HttpHeaders__mdt> headermeta = SYS_DataCacheFactory.headerSetting;
        String baseEndpoint = SYS_DataCacheFactory.integrationSetting.BaseAPIEndPoint__c;
        String resourceUrl = baseEndpoint + SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).ResourcePath__c;

        //TODO Make the folder arrangement correctly
        // Baed on what id we have to allocate the floders
        GoogleDriveFolder__c googlefolderparent = [SELECT GoogleDrive_ID__c, Id FROM GoogleDriveFolder__c WHERE Name = 'Municorn' LIMIT 1 ];
        String googlefolderparentId = googlefolderparent.GoogleDrive_ID__c;
        List<GoogleDriveFolder__c> googlefolder = [SELECT GoogleDrive_ID__c, Id FROM GoogleDriveFolder__c WHERE Contact__c =: recordId LIMIT 1];
        if (googlefolder.size() > 0) {
            googeldrivfolderId = googlefolder[0].GoogleDrive_ID__c;
        } else {
            googeldrivfolderId = CustomfileuploaderController.creategooglefolderReclog(accessToken, recordId, googlefolderparentId, recordId, baseEndpoint);
        }
        String folderid = '1s8S8fkoN_WXo2wXGshUAZj6yGrdNdPoK'; //googeldrivfolderId; //googeldrivfolderId;

        Integer httpstatuscode;
        Http h = new Http();
        HttpRequest req = new HttpRequest();

        String boundary = 'foo_bar_baz';
        String delimiter = '\r\n--' + boundary + '\r\n';
        String closeDelimiter = '\r\n--' + boundary + '--';

        //Converts a Blob to an unencoded String representing its normal form
        String encodedFile = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        // Construct the multipart request body
        String body = delimiter + 'Content-Type: application/json\r\n\r\n' +
            '{ "title":"' + fileName + '","type": "anyone","role": "reader",' +
            ' "mimeType":"' + contentType + '", "parents": [{"kind": "drive#fileLink", "id": "' + folderId + '"}]}' +
            delimiter + 'Content-Type: ' + contentType + '\r\nContent-Transfer-Encoding: base64\r\n\r\n' +
            encodedFile + closeDelimiter;
            
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-length', String.valueOf(body.length()));
        req.setHeader('Content-Type', 'multipart/related; boundary=' + boundary);
        req.setEndpoint(resourceUrl);
        
        req.setBody(body);
        req.setMethod('POST');

        HttpResponse res = h.send(req);
        httpstatuscode = res.getStatusCode();
        system.debug('resp' + res);
        system.debug(res.getBody());
        string jsonRecord = res.getBody();
        //Deserilize JSON and Map Keys 
        Map<String, Object> newflatKeyMap = new Map<String, Object>();

        String finalJSON = jsonRecord.replace('\n', ' ');
        Object convert = System.JSON.deserializeUntyped(finalJSON);

        String GooglecontentId, Thumbnaillink, Downloadlink, Previewlink;
        newflatKeyMap = (SYS_Helper.getFlatKeys(finalJSON, 'A.B'));
        GooglecontentId = (String) newflatKeyMap.get('id');
        Thumbnaillink = (String) newflatKeyMap.get('thumbnailLink');
        system.debug('Thumbnaillink' + Thumbnaillink);
        Downloadlink = (String) newflatKeyMap.get('webContentLink');
        Previewlink = (string.isNotBlank(Downloadlink) ? Downloadlink.remove('=download') : Downloadlink);
        system.debug('Downloadlink' + Downloadlink);
        system.debug('GooglecontentId' + GooglecontentId);
        if (GooglecontentId != null) {
            CustomfileuploaderController.googlefilePermission(GooglecontentId, accessToken);
        }

        if (googlefolder.size() == 0) {
            GoogleDriveFolder__c googlefolderrec = new GoogleDriveFolder__c();
            googlefolderrec.Name = fileName;
            googlefolderrec.Contact__c = recordId;
            googlefolderrec.GoogleDrive_ID__c = googeldrivfolderId;
            googlefolderrec.Synchronous__c = true;
            system.debug('googlefolderrec' + googlefolderrec);
            upsert googlefolderrec;
        }
        if (GooglecontentId != null) {
            Googlefile = new GoogleDriveFile__c();
            Googlefile.Contact__c = recordId;
            // Googlefile.ContentVersionId__c = contetid;
            Googlefile.GoogleDrive_ID__c = GooglecontentId;
            Googlefile.Name = fileName;
            //  Googlefile.BrandName__c =con.BrandName__c ;
            Googlefile.Preview_Link__c = Previewlink;
            Googlefile.ThumbnailLink__c = Thumbnaillink;
            Googlefile.Google_Drivefolder_id__c = googeldrivfolderId;
            Googlefile.DownloadLink__c = Downloadlink;
            Googlefile.ContentType__c = contentType;
            upsert Googlefile;
        }
        return Googlefile;
    }
    */

    public class UploadApiResponseWrapper {
        @AuraEnabled
        public String status;
        @AuraEnabled
        public Integer statusCode;
        @AuraEnabled
        public List<String> errorMessages = new List<String>();
        @AuraEnabled
        public String errorMessage {
            set {
                errorMessage = (errorMessages.size() > 0) ? errorMessages[0] : errorMessage;
            }
            get {
                return (errorMessages.size() > 0) ? errorMessages[0] : errorMessage;
            }
        }
        @AuraEnabled
        public List<PlivoMediaUploadWrapper.cls_objects> UploadApiResponseList = new List<PlivoMediaUploadWrapper.cls_objects>(); 
        @AuraEnabled
        public Activity__c activityRecord = new Activity__c();        
    }

    public static Database.SaveResult generateLogForMediaUpload(HttpResponse resp, Id createdActivityId) {
        SYS_IntegrationLog__c logResp = SYS_Helper.getLogsToInsert(resp.getBody());
        if (resp.getStatusCode() != 201 && resp.getStatusCode() != 200 && resp.getStatusCode() != 207) {
            logResp.Status__c = 'ERROR';
        }

        logResp.WhatId__c = (createdActivityId != null) ? createdActivityId : null;
        logResp.Status__c = 'DONE';
        logResp.How_To_Process__c = 'ignore_log';
        logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
        logResp.Type__c = 'RESPONSE';
        logResp.Integration_Setting__c = 'Plivo';
        Database.SaveResult result = SYS_Helper.insertLog(logResp);
        return result;
    }

    //Call Account Based Force Sync Outbound
    @AuraEnabled
    public static String calloutSynchronousOutbound(Id recId, String objSetting, String apexHandler, String direction, String accountMergeField) {
        String status;
        status = SYS_ForceSync_Controller.invokeAccountFlow(recId, objSetting, apexHandler, direction, accountMergeField);
        return status;
    }  

    //Fetch Current User with Contact and Account Data
    @AuraEnabled
    public static CurrentUserWrap fetchCurrentUserWrapper() {
        Id currentUserId = UserInfo.getUserId();
        List<Contact> contactList = new List<Contact>();
        Contact contRec = new Contact();
        // Fetch current user information  
        String fetchCurrentUserQuery = 'SELECT ' + getAllFieldsFor('User') +
                ', ' + SYS_Helper.getAllParentFields('Profile.UserLicense.', 'UserLicense') +
                ', ' + SYS_Helper.getAllParentFields('Contact.', 'Contact') +
                ', ' + SYS_Helper.getAllParentFields('Contact.Account.', 'Account') +
                ', ' + SYS_Helper.getAllParentFields('Contact.RecordType.', 'RecordType') +
                ' FROM User WHERE Id =: currentUserId';
        User userRec = Database.query(fetchCurrentUserQuery);

        // User userRec = [SELECT ContactId, ContactId__c, Contact.Name, Contact.AccountId, Contact.Account.Name, Email,
        //     FirstName, Id, IsActive, LastName, MobilePhone, Name, Phone, ProfileId, Profile.UserLicense.Name, Contact.RecordType.Name,
        //     Username, UserRoleId, UserType FROM User WHERE Id =: currentUserId
        // ];
        String contactId = String.isNotBlank(userRec.ContactId) ? (userRec.ContactId) : ( String.isNotBlank(userRec.ContactId__c) ? userRec.ContactId__c : null ) ;
        if( String.isNotBlank(contactId) ){
            // contactList = [SELECT Id,
            // Name,FirstName,LastName,Email,AccountId,Phone_Number__c,Formatted_Phone_Number__c,Gender__c,Active__c,StripeCustomerId__c,UUID__c,OwnerId,RecordTypeId,RecordType.Name,Account.Name,
            // Account.OwnerId ,Account.Plivo_PHLO_Id__c,
            // Account.Phone,Account.Fax FROM Contact WHERE Id =: contactId];

            // Fetch current user contact information  
            String fetchContactQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Contact') +
                    ', ' + SYS_Helper.getAllParentFields('RecordType.', 'RecordType') +
                    ', ' + SYS_Helper.getAllParentFields('Account.', 'Account') +
                    ' FROM Contact WHERE Id =: contactId';
            contactList = Database.query(fetchContactQuery);
        }
        if( contactList.size() > 0 ){
            contRec = contactList[0];
        }
        CurrentUserWrap cuserWrap = new CurrentUserWrap( userRec, contRec );
        return cuserWrap;
    }

    //User Contact Wrapper
    public class CurrentUserWrap{
        @AuraEnabled
        public User userRecord {get;set;}
        @AuraEnabled
        public Contact contactRecord {get;set;}
        
        public CurrentUserWrap(User userRec, Contact contRec){
            this.userRecord = userRec;
            this.contactRecord = contRec;
        }
    }

    public static String getAllFieldsFor(String objName) {
        objName = SYS_DataCache.namespacePrefix + objName;

        List<String> fields = new List<String>();
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objName).getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            Schema.DescribefieldResult field = sfield.getDescribe();
            if(field.isAccessible())
                fields.add(field.getname()?.toLowerCase());
        }
        return (String.join(fields,', '));
    }


    //AOA Specifict POS Quick Action
    @AuraEnabled
    public static Order__c createDraftOrderRecord( Id memberId , Id activityRecordId){
        Order__c getOrderDetails =  PMA_SearchController.createDraftOrderRecord(memberId);
        
        if (String.isNotBlank(activityRecordId) && getOrderDetails != null) {
            String newOrderId = getOrderDetails.Id;
            Activity__c updateActivity = new Activity__c();
            updateActivity.Id = activityRecordId;
            updateActivity.ActionId__c = newOrderId;
            update updateActivity;
        }

        return getOrderDetails;
    }

    //AOA Specifict POS Quick Action
    @AuraEnabled
    public static Contact getContactDetails(String recordIdOrUUID) {
        String fetchContactFilterCriteria = ' WHERE ';
        if( (recordIdOrUUID.length()==15) || (recordIdOrUUID.length()==18) ){
            fetchContactFilterCriteria += 'Id =: recordIdOrUUID';
        } else {
            fetchContactFilterCriteria += 'UUID__c =: recordIdOrUUID';
        }

        String fetchContactQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Contact') +
                ', ' + SYS_Helper.getAllParentFields('RecordType.', 'RecordType') +
                ', ' + SYS_Helper.getAllParentFields('Account.', 'Account') +
                ' FROM Contact' + fetchContactFilterCriteria + ' ORDER BY CreatedDate DESC LIMIT 1';
        List<Contact> fetchContactList = Database.query(fetchContactQuery);

        Contact contactRecord = new Contact();
        if(fetchContactList.size() > 0){
            contactRecord = fetchContactList[0];
        }
        
        return contactRecord;
    }

    //Check if Contact Point - Consent Status
    @AuraEnabled(cacheable=true)
    public static String checkContactPointConsentStatus(String memberPhoneNumber, String virtualPhoneNumber ) {
        String contactPointConsentStatus = '';
        try {
            String query = 'SELECT ' + SYS_Helper.getAllFieldsFor('Contact_Point_Consent__c') + ' FROM Contact_Point_Consent__c WHERE Member_Phone__c =: memberPhoneNumber AND Contact_Point__r.Formatted_Phone_Number__c =: virtualPhoneNumber ORDER BY Capture_Date__c DESC LIMIT 5';
            List<Contact_Point_Consent__c> latestContactPointConsents = Database.query(query);
            if (latestContactPointConsents != NULL && latestContactPointConsents.size() > 0) {
                contactPointConsentStatus = latestContactPointConsents[0].Consent_Status__c;
            } else {
                contactPointConsentStatus = 'Opt In Pending';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return contactPointConsentStatus;
    }

    //Get All From Numbers
    @AuraEnabled(cacheable=true)
    public static List<FromNumber> getAllFromNumbers() {
        List<FromNumber> fromNumbers = new List<FromNumber>();
        try {
            // SYS_DataCacheFactory.INT_TYPE = integrationSetting;
            // SYS_DataCacheFactory.OBJ_TYPE = objectSetting;

            // Map<String, String> metadataMap = new Map<String, String>();
            // for(Integration_Metadata__mdt item : Integration_Metadata__mdt.getAll()?.values()) {
            //     if(item.Integration_Setting__r.DeveloperName == SYS_DataCacheFactory.INT_TYPE) {
            //         metadataMap.put(item.Key__c, item.Value__c);
            //     }
            // }
            // FromNumber fromNumber = new FromNumber();
            // fromNumber.label = 'Default Number '+metadataMap.get('defaultPhone');
            // fromNumber.phoneNumber = metadataMap.get('defaultPhone');
            // fromNumber.selected = true;
            // fromNumbers.add(fromNumber);

            // for(User_Contact_Point__c point: [SELECT Id, Name, User__c, Contact_Point__c, Contact_Point__r.Label__c, 
            // Contact_Point__r.Formatted_Phone_Number__c FROM User_Contact_Point__c
            // WHERE User__c =:UserInfo.getUserId() ]) {
            //     FromNumber otherFromNumber = new FromNumber();
            //     otherFromNumber.label = point.Contact_Point__r.Label__c;
            //     otherFromNumber.phoneNumber = point.Contact_Point__r.Formatted_Phone_Number__c;
            //     fromNumbers.add(otherFromNumber);
            // }

            for(Contact_Point__c contactPoint: getContactPoints()) {
                FromNumber otherFromNumber = new FromNumber();
                otherFromNumber.label = contactPoint.Label__c;
                otherFromNumber.phoneNumber = contactPoint.Formatted_Phone_Number__c;
                otherFromNumber.contactpointrecord = contactPoint;
                fromNumbers.add(otherFromNumber);
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return fromNumbers;
    }

    //TO DO Depricated Method
    public static List<FromNumber> getAllFromNumbers(String integrationSetting, String objectSetting) {
        List<FromNumber> fromNumbers = getAllFromNumbers();
        return fromNumbers;
    }

    public static List<Contact_Point__c> getContactPoints() {
        String query = 'SELECT ' + SYS_Helper.getAllFieldsFor('Contact_Point__c') + ' FROM Contact_Point__c ORDER BY createdDate DESC LIMIT 1000';
        List<Contact_Point__c> allContactPoints = Database.query(query);
        return allContactPoints;
    }

    @AuraEnabled(cacheable=true)
    public static String getDefaultPhoneNumber() {
        String fromNumber = '';
        try {
            List<Contact_Point__c> contactPoints = getContactPoints();
            for(Contact_Point__c contactPoint: contactPoints) {
                if(contactPoint.Default__c) {
                    fromNumber = contactPoint.Formatted_Phone_Number__c;
                    break;
                }
            }
            if(String.isBlank(fromNumber) && contactPoints != NULL && contactPoints.size() > 0) {
                fromNumber = contactPoints[0].Formatted_Phone_Number__c;
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return fromNumber;
    }

    //TO DO Depricated Method
    public static String getDefaultPhoneNumber(String integrationSetting ) {
        String fromNumber = getDefaultPhoneNumber();
        return fromNumber;
    }

    //Parse the template
    @AuraEnabled
    public static String getParsedResponse(String recordId, String smsbody) {
        try {
            if(!String.isBlank(recordId))
                smsbody = MergeFields.parseBody(recordId, smsbody);
            smsbody = MergeFields.parseBody(UserInfo.getUserId(), smsbody);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return smsBody;
    }

    //Get All templates
    public static List<Template> getAllSMSTemplatesFormName(String sObjectLabel) {
        List<Template> allTemplates = new List<Template>();
        try {
            
            String query = 'SELECT ' + SYS_Helper.getAllFieldsFor('Converse_Template__c') + ' FROM Converse_Template__c WHERE Object_Name__c =:sObjectLabel AND IsActive__c = true LIMIT 100';
            List<Converse_Template__c> customTemplates = Database.query(query);
        
            Map<String, EmailTemplate> templateBodyMap = new Map<String, EmailTemplate>();
            String folderName = sObjectLabel + ' SMS';
            for(EmailTemplate template : [SELECT Name, Id, Body, DeveloperName FROM EmailTemplate 
            WHERE Folder.Name = :folderName ]) { 
                templateBodyMap.put(template.DeveloperName, template);
            }
            for(Converse_Template__c customTemplate : customTemplates) {
                Template template = new Template();
                template.label = (String)customTemplate.get('Name');
                if(customTemplate.get('Template__c') != NULL) {
                    template.body = (String)customTemplate.get('Template__c');
                } 
                allTemplates.add(template);
            }
            if(!templateBodyMap.isEmpty()) {
                for(String templateApiName : templateBodyMap.keySet()) {
                    Template template = new Template();
                    template.label = templateBodyMap.get(templateApiName)?.Name;
                    template.body = templateBodyMap.get(templateApiName)?.Body;
                    allTemplates.add(template);
                }
            }
            System.debug(JSON.serializePretty(allTemplates)); 
        } catch (Exception e) {
            System.debug(e.getMessage() + e.getStackTraceString());
            throw new ChatBotControllerException(e.getMessage());
        }
           
        return allTemplates;
    }

    @AuraEnabled(cacheable=true)
    public static List<Template> getAllSMSTemplates(String recordId) {
        List<Template> allTemplates = new List<Template>();
        try {
            
            String sObjectLabel = ((Id)recordId)?.getSObjectType()?.getDescribe()?.getLabel();
            allTemplates = getAllSMSTemplatesFormName(sObjectLabel);

        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return allTemplates;
    }

    @AuraEnabled(cacheable=true)
    public static List<Template> getAllSMSTemplatesFromDeveloperName(String sObjectApiName) {
        List<Template> allTemplates = new List<Template>();
        try {
            
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectApiName);
            Schema.DescribeSObjectResult describe = sObjectType.getDescribe();
            String sObjectLabel = describe.getLabel();

            allTemplates = getAllSMSTemplatesFormName(sObjectLabel);
            
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return allTemplates;
    }

    public class Template {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String body;
    }

    public class FromNumber {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String phoneNumber;
        @AuraEnabled
        public Contact_Point__c contactpointrecord;
        @AuraEnabled
        public Boolean selected;
    }

}