public class CustomActivityService {
    public static Activity__c getActivityByUUID(String uuid){
        List<Activity__c> activityList = new List<Activity__c>(); 
        String activitySearchQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Activity__c') +
                ', ' + SYS_Helper.getAllParentFields('Lead__r.', 'Lead') +
                ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
                ', ' + SYS_Helper.getAllParentFields('Contact__r.', 'Contact') +
                ', ' + SYS_Helper.getAllParentFields('Contact_Point__r.', 'Contact_Point__c') +
                ', ( SELECT ' + SYS_Helper.getAllFieldsFor('Media_URL__c') + ' FROM Media_Urls__r)' +
                ' FROM Activity__c WHERE UUID__c =: uuid ORDER BY When__c DESC ' + 'LIMIT 1';
        activityList = Database.query(activitySearchQuery); 
        return (activityList.size() > 0 ) ? activityList[0] : new Activity__c();
    }

    public static Activity__c getActivityById(Id id) {
        List<Activity__c> activityList = new List<Activity__c>(); 
        String activitySearchQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Activity__c') +
                ', ' + SYS_Helper.getAllParentFields('Lead__r.', 'Lead') +
                ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
                ', ' + SYS_Helper.getAllParentFields('Contact__r.', 'Contact') +
                 ', ' + SYS_Helper.getAllParentFields('Contact_Point__r.', 'Contact_Point__c') +
                ', ( SELECT ' + SYS_Helper.getAllFieldsFor('Media_URL__c') + ' FROM Media_Urls__r)' +
                ' FROM Activity__c WHERE Id =: id  ORDER BY When__c DESC ' + 'LIMIT 1';
        activityList = Database.query(activitySearchQuery); 
        return (activityList.size() > 0 ) ? activityList[0] : new Activity__c();
    }

    //Create Activity with InvokeOutbound flow boolean
    public static Activity__c createActivity(Boolean invokeOutboundFlow, String type, List<String> mediaUrls, String messagebody, String messageSubject,String fromPhone, String toPhone, Id recordId) {
        Id contactId, accountId, leadId = null;
        Activity__c createActivityRecord = createActivity(invokeOutboundFlow, type, mediaUrls, messagebody, messageSubject, fromPhone, toPhone, recordId, accountId);

        return createActivityRecord;
    }

    //Create Activity with AccountBased
    public static Activity__c createActivity(Boolean invokeOutboundFlow, String type, List<String> mediaUrls, String messagebody, String messageSubject,String fromPhone, String toPhone, Id recordId, String accountId) {
        Id contactId, leadId = null;
        String objectApiName = '';
        String mediaurlString = '';
        List<Media_URL__c> mediaUrlList = new List<Media_URL__c>();

        if(recordId != null){    
            objectApiName = recordId.getSObjectType().getDescribe().getName();
            if(objectApiName == 'Contact'){
                contactId = recordId;
            }
            if(objectApiName == 'Account'){
                accountId = recordId;
            }
            if(objectApiName == 'Lead'){
                leadId = recordId;
            }
        } else {
            recordId = null;
        }

        if(mediaUrls.size() > 0){
            mediaurlString = String.join(mediaurls,',');
        }

        Activity__c activityRecord = new Activity__c();
        activityRecord.Type__c = type;
        activityRecord.Direction__c ='OUTBOUND';
        activityRecord.Status__c = 'Queued'; //Sending
        activityRecord.Contact__c = contactId;
        activityRecord.Account__c = accountId;
        activityRecord.Lead__c = leadId;
        activityRecord.WhatId__c = recordId;
        activityRecord.WhatId_ObjectApi_Name__c = objectApiName;
        activityRecord.Subject__c = messageSubject;
        activityRecord.Message__c = messagebody;
        activityRecord.media_url__c = mediaurlString;
        activityRecord.Phone__c = toPhone;
        activityRecord.External_Number__c = fromPhone;
        // activityRecord.Email__c = email;
        activityRecord.IsInboxMessage__c = (invokeOutboundFlow == true) ? false : true;
        activityRecord.Log__c = true;
        activityRecord.Trackable__c = true;
        activityRecord.IsUnread__c = false;
        activityRecord.When__c = System.now();
        insert activityRecord;

        for (String mUrl: mediaurls) {
            Media_URL__c mediaUrl = new Media_URL__c();
            mediaUrl.Media_Url__c = mUrl;
            mediaUrl.Activity__c = activityRecord.Id;
            mediaUrlList.add(mediaUrl);
        }

        if(mediaUrlList.size() > 0){
            insert mediaUrlList;
        }       

        Activity__c createNewActivity = getActivityById(activityRecord.Id);

        return createNewActivity;
    }

    /* creating Email Inbound activity mehtod */
    //Create Activity with AccountBased
    public static Activity__c createEmailActivityLog(Boolean invokeOutboundFlow, String type, string Email,
        string Direction, string status, List < String > mediaUrls,
        String EmailSubject, Id parentrecordId, String accountId, string EmailMessage, string Htmlbody) {
        Id contactId, leadId = null;
        String objectApiName = '';
        String mediaurlString = '';
        List < Media_URL__c > mediaUrlList = new List < Media_URL__c > ();

        if (parentrecordId != null) {
            objectApiName = parentrecordId.getSObjectType().getDescribe().getName();
            if (objectApiName == 'Contact') {
                contactId = parentrecordId;
            }
            if (objectApiName == 'Account') {
                accountId = parentrecordId;
            }
            if (objectApiName == 'Lead') {
                leadId = parentrecordId;
            }
        } else {
            parentrecordId = null;
        }

        if (mediaUrls.size() > 0) {
            mediaurlString = String.join(mediaurls, ',');
        }

        Activity__c activityRecord = new Activity__c();
        activityRecord.Type__c = type;
        activityRecord.Direction__c = Direction;
        activityRecord.Status__c = status; //Sending
        activityRecord.Contact__c = contactId;
        activityRecord.Account__c = accountId;
        activityRecord.Lead__c = leadId;
        activityRecord.WhatId__c = parentrecordId;
        activityRecord.WhatId_ObjectApi_Name__c = objectApiName;
        activityRecord.Subject__c = EmailSubject;
         activityRecord.HTML_Body__c = Htmlbody;
        activityRecord.media_url__c = mediaurlString;
        // activityRecord.Phone__c = toPhone;
        // activityRecord.External_Number__c = fromPhone;
        activityRecord.Email__c = Email;
        activityRecord.IsInboxMessage__c = (invokeOutboundFlow == true) ? false : true;
        activityRecord.Log__c = true;
        activityRecord.Trackable__c = true;
        activityRecord.IsUnread__c = false;
        activityRecord.When__c = System.now();
        activityRecord.Text_Body__c = EmailMessage;
        insert activityRecord;

        for (String mUrl: mediaurls) {
            Media_URL__c mediaUrl = new Media_URL__c();
            mediaUrl.Media_Url__c = mUrl;
            mediaUrl.Activity__c = activityRecord.Id;
            mediaUrlList.add(mediaUrl);
        }

        if (mediaUrlList.size() > 0) {
            insert mediaUrlList;
        }

        Activity__c createNewActivity = getActivityById(activityRecord.Id);

        return createNewActivity;
    }
}