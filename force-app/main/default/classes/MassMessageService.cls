public virtual inherited sharing class MassMessageService {
    private Boolean doChainJob = true;

    public MassMessageService() {

    }
    public class MassMessageServiceException extends Exception {}

    public virtual String getListviewFilterhttp(String filterId, String objectName) {
        
        String query;
        HttpRequest req = new HttpRequest();
        String endpointUrl = 'callout:SF_Credentials'+'/services/data/v56.0/sobjects/'+ objectName +'/listviews/'+ filterId +'/describe';
        req.setEndpoint(endpointUrl);
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse response = http.send(req);
        if( response.getStatusCode() == 200 ) {
            Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            query = (String) tokenResponse.get('query');
        }
        string tempwhereclause = query.substringAfter('WHERE');
        string lastnamevertual = 'Virtual Terminal';
    
        String  whereclause =  ' WHERE Formatted_Phone_Number__c != Null AND Active__c = true ' +((String.isNotBlank(tempwhereclause))?' AND ' + tempwhereclause : '');
        String querySub = 'SELECT Id, Name, Phone_Number__c, Formatted_Phone_Number__c, AccountId, Account.Name, Account.Plivo_PHLO_Id__c FROM Contact';
        query = String.escapeSingleQuotes(querySub)+whereClause;
        return query;
    }

    public virtual list<Activity__c> createActivity(String messagebody, String messageSubject, list<Id> recordIdList, String phoneNumber,
    String attachmentId, String currentfileType) {
        list<Activity__c> activitylist = new list <Activity__c>();

        try {
            list<Contact> conList = [SELECT Id, Name, Formatted_Phone_Number__c, 
                                    AccountId, Account.Name FROM Contact WHERE Id  IN : recordIdList];
            if (String.isEmpty(attachmentId)) {

                
                system.debug('Activity messagebody ' + messagebody);
                
                for(Contact con :conList){
                    String parsedMessagebody = getParsedString(con.Id, messagebody);
                    Activity__c activityRecord = new Activity__c();
                    activityRecord.Type__c = 'sms';
                    activityRecord.Direction__c ='OUTBOUND';
                    activityRecord.Status__c = 'Queued'; //Sending
                    activityRecord.Contact__c = con.Id;
                    activityRecord.Account__c = con.AccountId;
                    activityRecord.Lead__c = NULL;
                    activityRecord.WhatId__c = con.Id;
                    activityRecord.WhatId_ObjectApi_Name__c = 'Contact';
                    activityRecord.Subject__c = messageSubject;
                    activityRecord.Message__c = parsedMessagebody;
                    // activityRecord.media_url__c = '';
                    activityRecord.Phone__c = con.Formatted_Phone_Number__c;
                    activityRecord.External_Number__c = phoneNumber;
                    // activityRecord.Email__c = con.Email;
                    // activityRecord.IsInboxMessage__c = true;
                    activityRecord.IsBulkMessage__c = true;
                    activityRecord.Log__c = true;
                    activityRecord.Trackable__c = true;
                    activityRecord.IsUnread__c = false;
                    activityRecord.When__c = System.now();  
                    activitylist.add(activityRecord);              
                }
            
                if(doChainJob){
                    insert activitylist;
                }
                
            }
            else if (conList.size() > 0){
                String accountId = conList[0].accountId;
                List<String> mediaUrls = new List<String>();     
                List<String> mediaErrorMessages = new List<String>();  
                String createdActivityId;   
                
                ChatBotController.UploadApiResponseWrapper uploadApiResponseWrapper = new ChatBotController.UploadApiResponseWrapper();
                HttpResponse resp = ChatBotController.uploadFileToPlivo((Id)attachmentId, currentfileType, accountId);
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
                        activitylist = createActivitiesForMMS('mms', mediaUrls, messagebody, messageSubject, phoneNumber, conList);
                        createdActivityId = activitylist[0].Id;
                        
                    } else {
                        mediaErrorMessages = PlivoMediaUploadWrapper.parseErrorMessages(responsejson);
                        
                    } 
                } else {
                    mediaErrorMessages = new List<String>{'API Error: Failed to Upload File'};
                    
                }
                Database.SaveResult result = ChatBotController.generateLogForMediaUpload(resp , createdActivityId);
            }

            List<Id> activityIds = new List<Id>();
            for(Activity__c item : activitylist) {
                activityIds.add(item.Id);
            }
            Database.executeBatch(new MassSMSBatch(activityIds), 1); 
        } catch (Exception e) {
            System.debug('Error '+e.getMessage()+e.getStackTraceString());
        }
        

        return activitylist;
    }

    /**
     * @brief this method is added for Contact sObject.
     */

    public List<Activity__c> createActivitiesForMMS(String type, List<String> mediaUrls, String messagebody, String messageSubject,String fromPhone, List<Contact> contacts) {
        List<Activity__c> allActivities = new List<Activity__c>();
        try {
            Id contactId, leadId = null;
            String objectApiName = '';
            String mediaurlString = '';
            List<Media_URL__c> mediaUrlList = new List<Media_URL__c>();
            if(contacts != null && contacts.size() > 0) {    
                
                if(mediaUrls.size() > 0){
                    mediaurlString = String.join(mediaurls,',');
                }
                
                for(Contact contact : contacts) {
                    String toPhone = contact.Formatted_Phone_Number__c;

                    String parsedMessagebody = getParsedString(contact.Id, messagebody);

                    Activity__c activityRecord = new Activity__c();
                    activityRecord.Type__c = type;
                    activityRecord.Direction__c ='OUTBOUND';
                    activityRecord.Status__c = 'Queued'; //Sending
                    activityRecord.Contact__c = contactId;
                    activityRecord.Account__c = contact.accountId;
                    activityRecord.Lead__c = leadId;
                    activityRecord.WhatId__c = contact.Id;
                    activityRecord.WhatId_ObjectApi_Name__c = objectApiName;
                    activityRecord.Subject__c = messageSubject;
                    activityRecord.Message__c = parsedMessagebody;
                    activityRecord.media_url__c = mediaurlString;
                    activityRecord.Phone__c = toPhone;
                    activityRecord.External_Number__c = fromPhone;
                    // activityRecord.Email__c = email;
                    activityRecord.IsBulkMessage__c = true;
                    activityRecord.Log__c = true;
                    activityRecord.Trackable__c = true;
                    activityRecord.IsUnread__c = false;
                    activityRecord.When__c = System.now();
                    allActivities.add(activityRecord);

                }
                insert allActivities;
                for(Activity__c activity : allActivities) {
                    for (String mUrl: mediaurls) {
                        Media_URL__c mediaUrl = new Media_URL__c();
                        mediaUrl.Media_Url__c = mUrl;
                        mediaUrl.Activity__c = activity.Id;
                        mediaUrlList.add(mediaUrl);
                    }
                }
                insert mediaUrlList;
            }
            else {
                throw new MassMessageServiceException('Selected list view is null.');
            }
        } catch (Exception e) {
            System.debug(e.getMessage()+e.getStackTraceString());
            throw new MassMessageServiceException('Some error occured. Please contact your Admin.');
        }

        return allActivities;
    }

    public static String getParsedString(String recordId, String template) {
        String parsedOutput = template;
        if(!String.isBlank(recordId))
            parsedOutput = MergeFields.parseBody(recordId, parsedOutput);
        parsedOutput = MergeFields.parseBody(UserInfo.getUserId(), parsedOutput);
        return parsedOutput;
    }
}