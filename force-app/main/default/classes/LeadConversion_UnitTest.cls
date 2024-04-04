@isTest
public class LeadConversion_UnitTest {
    
    public static List<Lead> createLeads(Integer numLeads, Boolean doInsert) {
		List<Lead> leadList = new List<Lead>();
		for(Integer i = 1; i <= numLeads; i++) {
            //Ramdom Number Generator
            Integer nineDigitRandomNumber = Integer.valueof((Math.random() * 1000000000));
            String randomPhoneNumber;
            if (String.valueOf(nineDigitRandomNumber).length() != 10) {
                randomPhoneNumber = String.valueOf(String.valueOf(nineDigitRandomNumber) + '0');
            }

            //Create Lead
			Lead iterLead = new Lead();
			iterLead.LastName = 'TestLead ' + i;
            iterLead.Phone = randomPhoneNumber;
			iterLead.Status = 'Open - Not Contacted';
            iterLead.Company = 'TestCompany' + i;
			leadList.add(iterLead);
		}
        
        if(doInsert && leadList.size()>0) {
			insert leadList;
		}
		return leadList;
	}
    
    public static List<Activity__c> createActivitiesforEachLead(List<Lead> leadsList, String externalPhone, String messageSubject, String messagebody, Integer numActivities, Boolean doInsert) {
        List<String> mediaUrls = new List<String>();
        String type = 'sms';
        List<Activity__c> ActivityListToCreate = new List<Activity__c>();
        for(Lead iterRec : leadsList){
            Id iterRecordId = iterRec.Id;
            String iterToPhone = iterRec.Formatted_Phone_Number__c;            

            Id contactId, accountId, leadId = null;
            String objectApiName = '';
            String mediaurlString = '';
            List<Media_URL__c> mediaUrlList = new List<Media_URL__c>();

            if(iterRecordId != null){    
                objectApiName = iterRecordId.getSObjectType().getDescribe().getName();
                if(objectApiName == 'Contact'){
                    contactId = iterRecordId;
                }
                if(objectApiName == 'Account'){
                    accountId = iterRecordId;
                }
                if(objectApiName == 'Lead'){
                    leadId = iterRecordId;
                }
            }else {
                iterRecordId = null;
            }

            if(mediaUrls.size() > 0){
                mediaurlString = String.join(mediaurls,',');
            }

            Activity__c activityRecord = new Activity__c();
            activityRecord.Type__c = type;
            activityRecord.Direction__c ='OUTBOUND';
            activityRecord.Status__c = 'Queued'; //Sending  Delivered
            activityRecord.Contact__c = contactId;
            activityRecord.Account__c = accountId;
            activityRecord.Lead__c = leadId;
            activityRecord.WhatId__c = iterRecordId;
            activityRecord.WhatId_ObjectApi_Name__c = objectApiName;
            activityRecord.Subject__c = messageSubject;
            activityRecord.Message__c = messagebody;
            activityRecord.media_url__c = mediaurlString;
            activityRecord.Phone__c = iterToPhone;
            activityRecord.External_Number__c = externalPhone;
            // activityRecord.Email__c = email;
            activityRecord.IsInboxMessage__c = true;
            activityRecord.Log__c = true;
            activityRecord.Trackable__c = true;
            activityRecord.IsUnread__c = false;
            activityRecord.When__c = System.now();
            ActivityListToCreate.add(activityRecord); 
        }      
        if(doInsert) {
			insert ActivityListToCreate;
		}
        return ActivityListToCreate;
    }
    
	@isTest
    static void bulkLeadsPhoneNumberFormatTest() {
        Test.startTest();
        List<Lead> leadsList = createLeads(200, true);
        Test.stopTest();
        List<Lead> verifyLeadsList = new List<Lead>();
        List<Lead> fetchLeadsList = [SELECT Id,FirstName,LastName,Phone,Formatted_Phone_Number__c,Status,Company FROM Lead];        
        System.assertEquals(200, fetchLeadsList.size(),'Leads Bulk Created SuccessFully');
        for(Lead iterRecord : fetchLeadsList){
            system.debug('iterRecord.Formatted_Phone_Number__c ' + iterRecord.Formatted_Phone_Number__c);
            if(String.isNotBlank(iterRecord.Formatted_Phone_Number__c)){
                verifyLeadsList.add(iterRecord);
            }            
        }        
        System.assertEquals(200, verifyLeadsList.size(), 'Formatted Phone Generated Successfully for Leads'); 
    }
    
    @isTest
    static void bulkLeadsConversionInboxUpdateTest() {
        List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        
        Test.startTest();
        List<Lead> leadsList = createLeads(200, true);
        List<Lead> fetchLeadsList = [SELECT Id,FirstName,LastName,Phone,Formatted_Phone_Number__c,Status,Company FROM Lead];     

        String externalPhone = '9999999999';
        String messageSubject = 'Test SMS Activity';
        String messagebody = 'Hello User This is Test SMS';
        Integer numActivities = 20;
        Boolean doInsert = true;

        List<Activity__c> createdActivities = createActivitiesforEachLead(fetchLeadsList, externalPhone, messageSubject, messagebody, numActivities, doInsert);

        String inboxCreatedRecordsQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Inbox__c') +
            ', ' + SYS_Helper.getAllParentFields('Lead__r.', 'Lead') +
            ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
            ', ' + SYS_Helper.getAllParentFields('Contact__r.', 'Contact') +
            ' FROM Inbox__c ORDER BY Latest_Message_Received_At__c DESC'; 
        List<Inbox__c> inboxCreatedRecordsList = Database.query(inboxCreatedRecordsQuery);       
        System.assertEquals(200, inboxCreatedRecordsList.size(),'Inbox records Created For Each Lead SuccessFully');

        for (Lead leadrec: [Select Id,FirstName,LastName,Phone,Formatted_Phone_Number__c,Status,Company,IsConverted, OwnerId From Lead]) {
            if (!leadrec.isConverted) {
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(leadrec.Id);
                lc.setConvertedStatus(convertStatus.MasterLabel);                
                leadConverts.add(lc);
            }
        }
        
        if (!leadConverts.isEmpty()) {
            List<Database.LeadConvertResult> lcr = Database.convertLead(leadConverts);
            if(lcr.size() > 0){
                System.assert(lcr[0].isSuccess());
            }            
        }
        
        Test.stopTest();
        
        List<Lead> verifyLeadsList = new List<Lead>();
        List<Lead> fetchConvertedLeadsList = [SELECT Id,FirstName,LastName,Phone,Formatted_Phone_Number__c,Status,Company,IsConverted FROM Lead WHERE IsConverted = true];        
        System.assertEquals(200, fetchConvertedLeadsList.size(),'Leads Bulk Converted SuccessFully');
        String convertedObjectAPiName = 'Account';
        String inboxFieldUpdateCheckQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Inbox__c') +
            ', ' + SYS_Helper.getAllParentFields('Lead__r.', 'Lead') +
            ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
            ', ' + SYS_Helper.getAllParentFields('Contact__r.', 'Contact') +
            ' FROM Inbox__c WHERE Account__c != NULL AND Contact__c != NULL AND Lead__c != NULL AND WhatId_ObjectApi_Name__c =:convertedObjectAPiName ORDER BY Latest_Message_Received_At__c DESC'; 
        List<Inbox__c> inboxFieldUpdatedList = Database.query(inboxFieldUpdateCheckQuery);       
        System.assertEquals(0, inboxFieldUpdatedList.size(),'Inbox records Updated For Each Lead Conversion Successfully');
        
    }
    
    // @isTest
    // static void bulkLeadsConversionRollupCalculateAsyncTest() { 
    //     Integer noOfLeadsToCreate = 1;      
    //     List<Lead> leadsList = createLeads(noOfLeadsToCreate, true);

    //     String fetchLeadsListQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Lead') +
    //         ' FROM Lead ORDER BY CreatedDate DESC LIMIT :noOfLeadsToCreate'; 
    //     List<Lead> fetchLeadsList = Database.query(fetchLeadsListQuery);   

    //     String externalPhone = '9999999999';
    //     String messageSubject = 'Test SMS Activity';
    //     String messagebody = 'Hello User This is Test SMS';
    //     Integer numActivities = 1;
    //     Boolean doInsert = true;
    //     Integer totalActivities = noOfLeadsToCreate * numActivities;
    //     Test.startTest();
    //     // Configure rollup
    //     dlrs__LookupRollupSummary__c rollupSummary = new dlrs__LookupRollupSummary__c();
    //     //rollupSummary.dlrs__Name = 'Rollup Municorn SMS on Lead';
    //     rollupSummary.dlrs__UniqueName__c = 'Rollup_Municorn_SMS_on_Lead';
    //     rollupSummary.dlrs__ParentObject__c = 'Lead';
    //     rollupSummary.dlrs__ChildObject__c = 'Activity__c';
    //     rollupSummary.dlrs__RelationShipField__c = 'Lead__c';
    //     rollupSummary.dlrs__RelationShipCriteria__c = 'Type__c = \'sms\' AND Direction__c = \'OUTBOUND\' AND Status__c = \'Delivered\' AND Lead__r.Status != \'Qualified\' AND isDeleted = false';
    //     rollupSummary.dlrs__RelationshipCriteriaFields__c = 'Type__c\nDirection__c\nStatus__c\nLead__c\nisDeleted';
    //     rollupSummary.dlrs__FieldToAggregate__c = 'Id';
    //     rollupSummary.dlrs__AggregateOperation__c = 'Count';
    //     rollupSummary.dlrs__AggregateResultField__c = 'No_of_Municorn_SMS_Sent__c';
    //     rollupSummary.dlrs__FieldToOrderBy__c = 'Id DESC NULLS LAST';
    //     rollupSummary.dlrs__AggregateAllRows__c = true;
    //     rollupSummary.dlrs__Active__c = true;
    //     rollupSummary.dlrs__CalculationMode__c = 'Process Builder';
    //     rollupSummary.dlrs__CalculationSharingMode__c = 'System';
    //     insert new List<dlrs__LookupRollupSummary__c>{ rollupSummary };


    //     Map<Id,Integer> recordIdActivityCountMap = new Map<Id,Integer>();
    //     for(Lead iterLeadRec : fetchLeadsList){
    //         recordIdActivityCountMap.put(iterLeadRec.Id, numActivities);
    //     }

    //     Communication_TestDataFactory.LeadActivitywrapper leadActivityWrap = new Communication_TestDataFactory.LeadActivitywrapper();
    //     leadActivityWrap.leadsList = fetchLeadsList;
    //     leadActivityWrap.externalPhone = externalPhone;
    //     leadActivityWrap.messageSubject = messageSubject;
    //     leadActivityWrap.messagebody = messagebody;
    //     leadActivityWrap.ActivityType = 'sms';
    //     leadActivityWrap.ActivityDirection = 'OUTBOUND';
    //     leadActivityWrap.ActivityStatus = 'Delivered';
    //     leadActivityWrap.recordIdActivityCountMap = recordIdActivityCountMap;
    //     leadActivityWrap.numActivities = numActivities;
    //     leadActivityWrap.bypassFlow = false;
    //     leadActivityWrap.doInsert = doInsert;
    //     leadActivityWrap.isunread = false;
    //     List<Activity__c> createdActivities = Communication_TestDataFactory.createActivitiesforEachLead(leadActivityWrap);  

    //     System.assertEquals(1, createdActivities.size(),'Activity record Created For Each Lead SuccessFully');
    //     Test.stopTest();        
    //     String selectedMemberFilterActivityQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Activity__c') +
    //             ', ' + SYS_Helper.getAllParentFields('Lead__r.', 'Lead') +
    //             ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
    //             ', ' + SYS_Helper.getAllParentFields('Contact__r.', 'Contact') +
    //             ', ( SELECT ' + SYS_Helper.getAllFieldsFor('Media_URL__c') + ' FROM Media_Urls__r)' +
    //             ' FROM Activity__c ORDER BY When__c DESC LIMIT :totalActivities';
    //     //TO-DO Check if is getting new unread messages also effecting pagination         
    //     List<Activity__c> activityListFiltered = Database.query(selectedMemberFilterActivityQuery);

    //     String verifyLeadsListQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Lead') +
    //         ' FROM Lead ORDER BY CreatedDate DESC LIMIT :noOfLeadsToCreate'; 
    //     List<Lead> verifyLeadsList = Database.query(verifyLeadsListQuery);
    //     for(Lead iterLead: verifyLeadsList){
    //         system.debug('verifyLeadsList ' + verifyLeadsList);
    //         system.debug('verifyLeadsList ' + iterLead.No_of_Municorn_SMS_Sent__c);
    //         System.assertEquals(1, iterLead.No_of_Municorn_SMS_Sent__c,'Rollup Calculated SuccessFully');
    //     }
    // }
}