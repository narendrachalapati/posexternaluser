public with sharing class PlivoChatBoxController {
    // wrapper class membersOrdersWrapper
    public class ActivityContactWrapper {
        @AuraEnabled
        public Activity__c activity = new Activity__c();
        @AuraEnabled
        public Contact cont = new Contact();
        @AuraEnabled
        public Integer Count;
        @AuraEnabled
        public Id contactid;
        @AuraEnabled
        public list < Activity__C > LatestActivities;
        @AuraEnabled
        public Double latestActivityNumber;
        @AuraEnabled
        public list < Activity__C > allActivities;
        @AuraEnabled
        public String shortNameCode;
        @AuraEnabled
        public Boolean hasPictureURL = false;
        @AuraEnabled
        public String pictureURL;
    }

    public class ActivityContactListWrapper {
        @AuraEnabled
        public Id contactid;
        @AuraEnabled
        public Contact cont = new Contact();
        @AuraEnabled
        public Integer totalActivitysCount;
        @AuraEnabled
        public Activity__c activity = new Activity__c();
        @AuraEnabled
        public list < Activity__C > LatestActivities = new list <Activity__c>();
        @AuraEnabled
        public String newMessage;
        @AuraEnabled
        public Double newMessagesCount = 0;
        @AuraEnabled
        public String shortNameCode;
        @AuraEnabled
        public Boolean hasPictureURL = false;
        @AuraEnabled
        public String pictureURL;
    }

    @AuraEnabled
    public static List < Contact > contactlist() {
        List < Contact > con = [SELECT Id, Name, Phone_Number__c, ActivityCount__c, Appointment_Link__c, Latest_Activity_Number__c,AccountId, Account.Name, RecordType.Name, UnreadActivitiesCount__c, Email , UUID__c FROM Contact WHERE Member_Type__c != 'Anonymous' ORDER BY LastModifiedDate DESC];
        System.debug('contatactlist' + con);
        return con;
    }
    @AuraEnabled
    public static Contact getContactDetails(string recordId) {
        Contact cont = new Contact();
        //TO-DO Find Sobject Dynamically Contact or Account or Lead
        List<Contact> contactList = [SELECT Id, Name, Phone_Number__c, ActivityCount__c, Appointment_Link__c,Link_Expired__c, Latest_Activity_Number__c,AccountId, Account.Name , RecordType.Name, UnreadActivitiesCount__c, Email , UUID__c FROM Contact WHERE Id =: recordId ];
        if(contactList.size() > 0){
            cont = contactList[0];
        }else{
            cont = new Contact();
        }
        System.debug('contact' + cont);
        return cont;
    }

    //Fetch Contact List Wrapper with Latest Unread messages
    @AuraEnabled
    public static List<ActivityContactListWrapper> contactserch(String searchkey, Double storedActivityNumber,String currentContactId) {
        //storedActivityNumber - When 
        //currentContactId - when contact is selected
        String name = '%'+ searchkey + '%';
        List<Contact> conlist = new List<Contact>();
        Map< Id, List<Activity__c> > contactActivityMap = new  Map< Id, List<Activity__c> >();  
        List < ActivityContactListWrapper > ContactActivitywrapList = new list < ActivityContactListWrapper > ();
        List<Id> WhattIdsList = new List<Id>();

        //TO-DO Search Sobject Dynamically Contact or Account or Lead
        if(String.isBlank(searchkey)){ // Without Search Pooling
            //Query on Activity Last 20 Unique phonenumber based act get 100 LAtest
            conlist = [SELECT Id, Name, Phone_Number__c, ActivityCount__c, Appointment_Link__c, Latest_Activity_Number__c,AccountId, Account.Name, RecordType.Name, UnreadActivitiesCount__c, Email , UUID__c, CreatedDate, LastModifiedDate FROM Contact WHERE Phone_Number__c != NULL AND RecordTypeId != NULL AND AccountId	!= NULL AND ActivityCount__c > 0 AND Member_Type__c != 'Anonymous' ORDER BY Latest_Activity_Number__c DESC LIMIT 100];//TO-DO 10-15 Records Dynamic LIMITs 
        }else{ // Search Based Filter
            conlist = [SELECT Id, Name, Phone_Number__c, ActivityCount__c, Appointment_Link__c, Latest_Activity_Number__c,AccountId, Account.Name, RecordType.Name, UnreadActivitiesCount__c, Email , UUID__c, CreatedDate, LastModifiedDate FROM Contact WHERE Phone_Number__c != NULL AND RecordTypeId != NULL AND AccountId	!= NULL AND Member_Type__c != 'Anonymous' AND ( Name LIKE : name OR Phone_Number__c LIKE : name ) ORDER BY CreatedDate DESC LIMIT 100 ];//Implement Pagination Prev - First - Next  Page Size 20
        }
    
        // Search Fields Api Names Account.Phone_Number__c, Account.Name or Complete Creteia run it on activity
        // Activity Inbox Wrapper Query on Account Contact and Lead
        //TO-DO Iteration and Find Sobject Dynamically Contact or Account or Lead
        for (Contact contiterate: conlist) {
            WhattIdsList.add(contiterate.Id);
        }

        //Init Record based image Map
        Map<Id, String> WhattIdRecordImagesMap = ImageController.loadWhattIdRecordImagesMap(WhattIdsList);
        //Init All Activities For All Contacts
        List<Activity__c> allContactActivitiesList = new List<Activity__c>(); 
        //TO-DO Find Sobject Dynamically Contact or Account or Lead realted fields and filter based on record Id
        String activityFilterQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Activity__c') +
                ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
                ', ' + SYS_Helper.getAllParentFields('Customer__r.', 'Contact') +
                ', ( SELECT ' + SYS_Helper.getAllFieldsFor('Media_URL__c') + ' FROM Media_Urls__r)' +
                ' FROM Activity__c WHERE Customer__c IN: WhattIdsList ORDER BY CreatedDate DESC LIMIT 100';
        allContactActivitiesList = Database.query(activityFilterQuery);

        //TO-DO Iteration and Find Sobject Dynamically Contact or Account or Lead  -- and filer realted Activities    
        //Iterate To Create Map of Contact Activites
        for (Contact contiterate: conlist) {
            List<Activity__c> tempActivityList = new List<Activity__c> ();
            contactActivityMap.put(contiterate.Id , tempActivityList );
            for(Activity__c IterActivityRecord :allContactActivitiesList){
                if(IterActivityRecord.Customer__c == contiterate.Id){
                    if(contactActivityMap.containsKey(IterActivityRecord.Customer__c)){
                        List<Activity__c> fetchStoredActivityList = contactActivityMap.get(IterActivityRecord.Customer__c);
                        fetchStoredActivityList.add(IterActivityRecord);
                        contactActivityMap.put(contiterate.Id , fetchStoredActivityList );
                    }
                }
            } 
        }      

        //TO-DO Iteration and Find Sobject Dynamically Contact or Account or Lead
        //Iterate To Create Wrapper for Pooling Activites
        for (Contact contiterate: conlist) {
            list < Activity__c > allActivitiesList = new list < Activity__c >(); 
            List<Activity__c> newUnreadActivitiesList = new List<Activity__c>();
            List<Activity__c> allnewActivitiesList = new List<Activity__c>();
            Activity__c currentActivity = new Activity__c();
            String recordPictureURL = WhattIdRecordImagesMap.get(contiterate.Id);
            recordPictureURL = (String.IsNotBlank(recordPictureURL)) ? recordPictureURL : 'noimage';
            System.debug('Contact Name ' + contiterate.Name + ' recordPictureURL '+ recordPictureURL);

            ActivityContactListWrapper currentContactActivitywrap = new ActivityContactListWrapper();
            currentContactActivitywrap.contactid = contiterate.Id;
            //TO-DO Modify Wrapper to Find Sobject Dynamically Contact or Account or Lead
            //TO-DO Pass Activity to Create Wrapper Record 
            currentContactActivitywrap.cont = contiterate;
            currentContactActivitywrap.shortNameCode = ImageController.getShortendImageName(contiterate.Name);
            currentContactActivitywrap.hasPictureURL = (recordPictureURL=='noimage') ? false : true;
            currentContactActivitywrap.pictureURL = recordPictureURL;
            
            //Get Related Activities for Selected Iterated Contact 
            allActivitiesList = contactActivityMap.get(contiterate.Id);

            if (allActivitiesList.size() != 0) {//All Messages
                
                if( (storedActivityNumber >= 0) && (String.isNotBlank(currentContactId)) && ( contiterate.Id == currentContactId ) ){
                    for(Activity__C cactivity :allActivitiesList){ // Collect Latest Activities
                        if(cactivity.Activity_Number__c > storedActivityNumber){
                            allnewActivitiesList.add(cactivity);//All New Messages After Component Load
                        }
                    }  
                }
                for(Activity__C currentact :allActivitiesList){//Collect Unread Activities
                    if(currentact.IsUnread__c){
                        newUnreadActivitiesList.add(currentact);
                    }
                }
                if( (newUnreadActivitiesList.size() > 0) && ( String.isNotBlank(currentContactId) && (contiterate.Id == currentContactId ) ) ){ // Mark Message as read for new Unread Messages for Selected Contact
                    List<Activity__C> updatenewUnreadActivitiesList = new List<Activity__C>();
                    for(Activity__C tempAct :newUnreadActivitiesList){
                        if(tempAct.IsUnread__c){
                            tempAct.IsUnread__c=false;
                            updatenewUnreadActivitiesList.add(tempAct);
                        }
                    }
                    System.debug('updatenewUnreadActivitiesList ' + updatenewUnreadActivitiesList);
                    update updatenewUnreadActivitiesList; 
                }  
                System.debug('Name ' + contiterate.Name);
                currentActivity = (allActivitiesList.size() > 0) ? allActivitiesList[0] :  new Activity__c();
                //TO-DO Modify Rollup Summary fields for Contact or Account or Lead
                Double iterTotalActivityCount = (contiterate.ActivityCount__c != NULL) ? contiterate.ActivityCount__c : 0;
                currentContactActivitywrap.totalActivitysCount = Integer.valueOf(iterTotalActivityCount); 
                currentContactActivitywrap.activity =  currentActivity;
                currentContactActivitywrap.newMessagesCount = contiterate.UnreadActivitiesCount__c;
                if( (storedActivityNumber >= 0) && ( String.isNotBlank(currentContactId) ) && (currentContactId == contiterate.Id ) ){
                    currentContactActivitywrap.LatestActivities = (allnewActivitiesList.size() > 0) ? allnewActivitiesList : new List<Activity__C>();
                }else{
                    currentContactActivitywrap.LatestActivities = (newUnreadActivitiesList.size() > 0) ? newUnreadActivitiesList : new List<Activity__C>();
                }
                if(currentActivity.Type__c  == 'sms'){
                    currentContactActivitywrap.newMessage = currentActivity.Message__c;
                }
                else if(currentActivity.Type__c  == 'mms'){
                    currentContactActivitywrap.newMessage = currentActivity.Direction__c + 'MMS '+ ((currentActivity.Direction__c  == 'INBOUND') ? 'From ' : 'To ') + contiterate.Name;
                }
                else if(currentActivity.Type__c  == 'Call'){
                    currentContactActivitywrap.newMessage = currentActivity.Direction__c + 'Call '+ ((currentActivity.Direction__c  == 'INBOUND') ? 'From ' : 'To ') + contiterate.Name;
                }else{
                    currentContactActivitywrap.newMessage = '';
                }

            } else {// Now Messages for contact
                // Instantiate Wrapper
                System.debug('Name ' + contiterate.Name);
                currentContactActivitywrap.totalActivitysCount =  allActivitiesList.size();
                currentContactActivitywrap.activity =  new Activity__c();
                currentContactActivitywrap.LatestActivities = new List<Activity__C>();
                currentContactActivitywrap.newMessage = 'Say Hello!';
                currentContactActivitywrap.newMessagesCount = 0;               
            }
            ContactActivitywrapList.add(currentContactActivitywrap);
            System.debug('Name ' + contiterate.Name);
            System.debug('currentContactActivitywrap ' + currentContactActivitywrap);
        }
        return ContactActivitywrapList;
    }  

    //Fetch activity messages for contact
    @AuraEnabled
    public static ActivityContactWrapper getMessagesByRecordId(String recordId , Integer messagesLimitPerPage , Integer currentOffset, Boolean markasRead) {
        //TO-DO Find Sobject Dynamically Contact or Account or Lead
        Contact con = [SELECT Id, Name, Phone_Number__c, ActivityCount__c, Appointment_Link__c, Latest_Activity_Number__c,AccountId, Account.Name, RecordType.Name, UnreadActivitiesCount__c, Email , UUID__c FROM Contact WHERE Id =: recordId];
        //Init Record Picture Urls
        List<Id> WhattIdsList = new List<Id>(); 
        WhattIdsList.add(recordId);
        Map<Id, String> WhattIdRecordImagesMap = ImageController.loadWhattIdRecordImagesMap(WhattIdsList);
        String recordPictureURL = WhattIdRecordImagesMap.get(recordId);
        recordPictureURL = (String.IsNotBlank(recordPictureURL)) ? recordPictureURL : 'noimage';
        System.debug('Contact Name ' + con.Name + ' recordPictureURL '+ recordPictureURL);
        List<Activity__c> newUnreadActivitiesList = new List<Activity__c>();
        ActivityContactWrapper currentActivity = new ActivityContactWrapper();
        currentActivity.contactid = con.Id;
        //TO-DO Modify Wrapper to Find Sobject Dynamically Contact or Account or Lead
        currentActivity.cont = con;
        currentActivity.shortNameCode = ImageController.getShortendImageName(con.Name);
        currentActivity.hasPictureURL = (recordPictureURL=='noimage') ? false : true;
        currentActivity.pictureURL = recordPictureURL;

        //TO-DO Find Sobject Dynamically Contact or Account or Lead realted fields and filter based on record Id
        String activityFilterQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Activity__c') +
                ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
                ', ' + SYS_Helper.getAllParentFields('Customer__r.', 'Contact') +
                ', ( SELECT ' + SYS_Helper.getAllFieldsFor('Media_URL__c') + ' FROM Media_Urls__r)' +
                ' FROM Activity__c WHERE Customer__c IN: WhattIdsList ORDER BY CreatedDate ASC LIMIT :messagesLimitPerPage OFFSET: currentOffset';
        List<Activity__c> activitieslist = Database.query(activityFilterQuery);
        system.debug('activitieslist+++===' + activitieslist);

        if(activitieslist.size() > 0){
            for(Activity__C currentact :activitieslist){
                if(currentact.IsUnread__c == true){
                   currentact.IsUnread__c=false;
                   newUnreadActivitiesList.add(currentact);
                }
            }
            if( (newUnreadActivitiesList.size() > 0) && ( markasRead == true ) ){
                update newUnreadActivitiesList;
            }   
            
            currentActivity.latestActivityNumber = con.Latest_Activity_Number__c;
            currentActivity.Count = activitieslist.size();
            currentActivity.LatestActivities = new List < Activity__c > ();
            currentActivity.activity =  new Activity__c();
            currentActivity.allActivities = activitieslist;
            return currentActivity;
        }else{
            currentActivity.latestActivityNumber = con.Latest_Activity_Number__c;
            currentActivity.Count = activitieslist.size();
            currentActivity.LatestActivities = new List < Activity__c > ();
            currentActivity.activity =  new Activity__c();
            currentActivity.allActivities = new List < Activity__c > ();
            return currentActivity;
        }
    }

    // Get Previous messages
    @AuraEnabled
    public static ActivityContactWrapper GetActivitiesRemaining(Id recordId, Integer messagesLimitPerPage , Integer currentOffset) {
        //TO-DO Find Sobject Dynamically Contact or Account or Lead
        Contact con = [SELECT Id, Name, Phone_Number__c, ActivityCount__c, Appointment_Link__c, Latest_Activity_Number__c,AccountId, Account.Name, RecordType.Name, UnreadActivitiesCount__c, Email , UUID__c FROM Contact WHERE Id =: recordId];
        //Init Record Picture Urls
        List<Id> WhattIdsList = new List<Id>(); 
        WhattIdsList.add(recordId);
        Map<Id, String> WhattIdRecordImagesMap = ImageController.loadWhattIdRecordImagesMap(WhattIdsList);
        String recordPictureURL = WhattIdRecordImagesMap.get(recordId);
        recordPictureURL = (String.IsNotBlank(recordPictureURL)) ? recordPictureURL : 'noimage';
        System.debug('Contact Name ' + con.Name + ' recordPictureURL '+ recordPictureURL);

        ActivityContactWrapper currentActivity = new ActivityContactWrapper();
        currentActivity.contactid = con.Id;
        //TO-DO Modify Wrapper to Find Sobject Dynamically Contact or Account or Lead
        currentActivity.cont = con;
        currentActivity.shortNameCode = ImageController.getShortendImageName(con.Name);
        currentActivity.hasPictureURL = (recordPictureURL=='noimage') ? false : true;
        currentActivity.pictureURL = recordPictureURL;
        //TO-DO Find Sobject Dynamically Contact or Account or Lead Related Fields Like Name 
        String activityFilterQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Activity__c') +
                ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
                ', ' + SYS_Helper.getAllParentFields('Customer__r.', 'Contact') +
                ', ( SELECT ' + SYS_Helper.getAllFieldsFor('Media_URL__c') + ' FROM Media_Urls__r)' +
                ' FROM Activity__c WHERE Customer__c IN: WhattIdsList ORDER BY CreatedDate ASC LIMIT :messagesLimitPerPage OFFSET: currentOffset';
        List<Activity__c> activities = Database.query(activityFilterQuery);

        system.debug('activities+++===' + activities);

        currentActivity.latestActivityNumber = con.Latest_Activity_Number__c;
        currentActivity.Count = activities.size();
        currentActivity.LatestActivities = new List < Activity__c > ();
        currentActivity.activity =  new Activity__c();
        currentActivity.allActivities = activities;
        return currentActivity;
    }
    

    @AuraEnabled
    public static String createActivity(String messagebody, String messageSubject, string recordId) {
        Contact con = [SELECT Id, Name, Phone_Number__c, Formatted_Phone_Number__c, AccountId, Account.Name, Account.Plivo_Sender_Id__c, Account.Plivo_PHLO_Id__c, ActivityCount__c, Latest_Activity_Number__c, UnreadActivitiesCount__c FROM Contact WHERE Id =: recordId];
        system.debug('Activity messagebody ' + messagebody);
        Activity__c activity = new Activity__c();
        activity.Type__c = 'sms';
        activity.Status__c = 'Sending';//Queued
        activity.Subject__c = messageSubject;
        activity.Message__c = messagebody;
        activity.Customer__c = recordId;
        activity.Account__c = con.AccountId;
        activity.Phone__c = con.Formatted_Phone_Number__c;
        activity.Log__c = true;
        activity.Direction__c ='OUTBOUND';
        activity.Trackable__c = true;
        activity.IsUnread__c = false;
        activity.When__c = System.now();
        insert activity;

        return activity.Id;
    }

    @AuraEnabled
    public static String calloutSynchronousOutbound(Id recId, String objSetting, String apexHandler, String direction, String accountMergeField) {
        String status;
        status = SYS_ForceSync_Controller.invokeAccountFlow(recId, objSetting, apexHandler, direction, accountMergeField);
        return status;
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

    @AuraEnabled
    public static Id saveTheFile(Id recordId, String fileName, String base64Data )  { 
        
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

        String existingBody     = EncodingUtil.base64Encode(versionData.VersionData);
        versionData.VersionData = EncodingUtil.base64Decode(existingBody + base64Data); 

        update versionData;

    }

    @AuraEnabled
    public static String submitAttachment(Id contentVersionId, String currentfileType , String recordId) {
        System.debug('contentVersionId  ' + contentVersionId);
        String query = 'SELECT Id,FileType, ContentDocument.title, VersionData FROM ContentVersion WHERE Id = :contentVersionId AND IsLatest = true';
        SYS_debug.log('query==' + query);
        List < ContentVersion > contentList = Database.query(query);
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
            System.debug(' test header ' +  header);
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
            req.setEndpoint('callout:Plivo/Account/MAZJM3ZDZLNWRKZWJJYW/Media/');
            req.setHeader('Connection', 'keep-alive');
            req.setHeader('accept-encoding', 'gzip, deflate, br');
            
            String contentLength = string.valueOf(bodyBlob.size());
            SYS_debug.log('contentLength '+ contentLength);
            req.setHeader('Content-Length', contentLength);

            String contentType = 'multipart/form-data; boundary="' + boundary + '"';
            SYS_debug.log('contentType '+ contentType);
            req.setHeader('Content-Type', contentType);

            req.setMethod('POST');
            req.setBodyAsBlob(bodyBlob);
            req.setTimeout(120000);
            SYS_debug.log('endPoint=='+req.getEndPoint());
            Http h = new Http();
            HTTPResponse resp = h.send(req); 
            Database.SaveResult result = generateLogForMediaUpload(resp);
            SYS_debug.log('#### resp status: '+resp.getStatus());
            SYS_debug.log('#### resp code: '+resp.getStatusCode());
            SYS_debug.log('#### resp: '+resp.getBody());
            String responsejson = resp.getBody();
            List <String> mediaUrls = new List <String>();
            if(resp.getStatusCode() == 200 || resp.getStatusCode() == 201 || resp.getStatusCode() == 207) {
                System.debug('Uploaded to Plivo');
                mediaUrls = mediaUploadJSON.parse(responsejson);
                if(mediaUrls.size() > 0){
                    String createdActivityId = createMMSActivity(mediaUrls, recordId);
                    return createdActivityId;
                } else{
                    System.debug('Failed to Create Activity Invalid :: Media URLS');
                    return 'Error';
                }
            } else {
                System.debug('Failed to Upload to Plivo');
                return 'Error';
            }
            
        }
        return 'Error';
    }

    public static Database.SaveResult generateLogForMediaUpload(HttpResponse resp) {
        SYS_IntegrationLog__c logResp = SYS_Helper.getLogsToInsert(resp.getBody());
        if (resp.getStatusCode() != 201 && resp.getStatusCode() != 200 && resp.getStatusCode() != 207) {
            SYS_debug.log('#### resp status: ' + resp.getStatus());
            SYS_debug.log('#### resp code: ' + resp.getStatusCode());
            SYS_debug.log('#### resp: ' + resp.getBody());
            logResp.Status__c = 'ERROR';
            logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
            // logResp.WhatId__c = log.WhatId__c;
            logResp.Type__c = 'RESPONSE';
            logResp.How_To_Process__c = 'ignore_log';
            logResp.Integration_Setting__c = SYS_DataCache.INT_TYPE;
        }
        logResp.Status__c = 'DONE';
        logResp.How_To_Process__c = 'ignore_log';
        logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
        logResp.Type__c = 'RESPONSE';
        logResp.Integration_Setting__c = 'Plivo';
        logResp.ObjectSettingId__c = 'MediaObjectsetting';
        Database.SaveResult result = SYS_Helper.insertLog(logResp);
        return result;
    }

    @AuraEnabled
    public static String createMMSActivity(List <String> mediaurls, string recordId) {
        List < Media_URL__c > mediaUrlList = new List < Media_URL__c >();
        Contact con = [SELECT Id, Name, Phone_Number__c, Formatted_Phone_Number__c, AccountId, Account.Name, Account.Plivo_Sender_Id__c, Account.Plivo_PHLO_Id__c, UnreadActivitiesCount__c FROM Contact WHERE Id =: recordId];
        system.debug('Activity mediaurls ' + mediaurls);
        String mediaurlString = String.join(mediaurls,',');
        Activity__c activity = new Activity__c();
        activity.Type__c = 'mms';
        activity.Status__c = 'Sending';
        activity.media_url__c = mediaurlString;
        activity.Customer__c = recordId;
        activity.Account__c = con.AccountId;
        activity.Phone__c = con.Formatted_Phone_Number__c;
        activity.IsUnread__c = false;
        activity.Log__c = true;
        activity.Direction__c ='OUTBOUND';
        activity.Trackable__c = true;
        activity.When__c = System.now();
        insert activity;

        for(String mUrl :mediaurls){
            Media_URL__c mediaUrl = new Media_URL__c();
            mediaUrl.Media_Url__c = mUrl;  
            mediaUrl.Activity__c = activity.Id;  
            mediaUrlList.add(mediaUrl);
        }
        insert mediaUrlList;

        return activity.Id;
    }

    @AuraEnabled
    public static Boolean createEventActivity( string recordId,string messagebody) {
        Contact con = [SELECT Id, Name, Phone_Number__c, Formatted_Phone_Number__c, AccountId, Account.Name, Account.Plivo_Sender_Id__c, Account.Plivo_PHLO_Id__c, UnreadActivitiesCount__c FROM Contact WHERE Id =: recordId];
       
        Activity__c activity = new Activity__c();
        activity.Type__c = 'sms';
        activity.Status__c = 'Queued';
        activity.Message__c = messagebody;
        activity.Customer__c = recordId;
        activity.Account__c = con.AccountId;
        activity.Phone__c = con.Formatted_Phone_Number__c;
        activity.IsUnread__c = false;
        activity.Log__c = true;
        activity.Direction__c ='OUTBOUND';
        activity.Trackable__c = true;
        activity.When__c = System.now();
        insert activity;
        system.debug('createEventActivity activity+++'+activity);

        return true;
    }

    @AuraEnabled
    public static User fetchCurrentUser() {
        // query current user information  
        User currentUserRecord = PMA_SearchController.fetchCurrentUser();

        return currentUserRecord;
    }

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
    
}