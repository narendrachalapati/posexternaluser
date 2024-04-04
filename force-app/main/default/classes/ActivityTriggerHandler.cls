public without sharing class ActivityTriggerHandler {

    //Helper Method to Get Whattid
    public static String getWhattIdFromActivityRecord(Activity__c activityRecord){
        Id whattId;
        // if(activityRecord.Account__c != null){
        //     whattId = activityRecord.Account__c;
        // }
        // if(activityRecord.Lead__c != null){
        //     whattId = activityRecord.Lead__c;
        // }
        if(activityRecord.Contact__c != null){
            whattId = activityRecord.Contact__c;
        }
        whattId = String.isBlank(whattId) ? activityRecord.WhatId__c : whattId;
        return whattId;
    }

    //Helper Method to Get ContactName
    public static String getContactNameFromActivityRecord(Activity__c activityRecord){
        String memberName;
        // if(activityRecord.Account__c != null){
        //     memberName = activityRecord.Account__r.Name;
        // }
        // if(activityRecord.Lead__c != null){
        //     memberName = (String.isNotBlank(activityRecord.Lead__r.FirstName) ? activityRecord.Lead__r.FirstName : '') + '' + (String.isNotBlank(activityRecord.Lead__r.LastName) ? ' ' + activityRecord.Lead__r.LastName : '');
        // }
        if(activityRecord.Contact__c != null){
            memberName = (String.isNotBlank(activityRecord.Contact__r.FirstName) ? activityRecord.Contact__r.FirstName : '') + '' + (String.isNotBlank(activityRecord.Contact__r.LastName) ? ' ' + activityRecord.Contact__r.LastName : '');
        }
        memberName = String.isBlank(memberName) ? activityRecord.Formatted_Phone__c : memberName;
        return memberName;
    }

    //Helper Method to Get Name
    public static String getFormattedPhoneNumber(String countryCode, String unFormattedPhone){
        if(!String.isBlank(unFormattedPhone)) {
            String nondigits = '[^0-9]';
            String PhoneNumberDigitsOnly;
            Integer PhoneNumberLength = 0;
            countryCode = String.isNotBlank(countryCode) ? countryCode : System.Label.PlivoContryCode;
            
            // remove all non numeric
            PhoneNumberDigitsOnly = unFormattedPhone.replaceAll(nondigits,'');
            PhoneNumberLength = PhoneNumberDigitsOnly.length();

            if (PhoneNumberLength == 10) {
                //Add Country Code to PhoneNumber
                return  countryCode + PhoneNumberDigitsOnly;
            } else if(PhoneNumberLength == 11){
                return PhoneNumberDigitsOnly;
            } else if(PhoneNumberLength > 10){
                return countryCode + PhoneNumberDigitsOnly.substring(0,10);
            }else {
                return PhoneNumberDigitsOnly.substring(0,PhoneNumberLength);
            }            
        }
        return unFormattedPhone;
    }

    public static void handleAfterInsert() {
        List<Inbox__c> inboxList = new List<Inbox__c>();

        for(Activity__c iterActivity : ((List<Activity__c>)Trigger.new)){
            String IterContactName = getContactNameFromActivityRecord(iterActivity);
            String IterContactPhoneNumber = getFormattedPhoneNumber(iterActivity.Country_Code__c, iterActivity.Phone__c);

            String ExternalContactPoint = String.isNotBlank(IterContactPhoneNumber) ? IterContactPhoneNumber : iterActivity.Email__c;
            String latestMessage;
            if(iterActivity.Type__c  == 'sms'){
                latestMessage = iterActivity.Message__c;
            }
            else if(iterActivity.Type__c  == 'mms'){
                latestMessage = iterActivity.Direction__c + ' MMS '+ ((iterActivity.Direction__c  == 'INBOUND') ? 'From ' : 'To ') + IterContactName;
            }
            else if(iterActivity.Type__c  == 'Call'){
                latestMessage = iterActivity.Direction__c + ' Call '+ ((iterActivity.Direction__c  == 'INBOUND') ? 'From ' : 'To ') + IterContactName;
            }else{
                latestMessage = 'Say Hello!';
            }

            Inbox__c inboxRecord = new Inbox__c();
            inboxRecord.Contact__c = iterActivity.Contact__c;
            inboxRecord.Account__c = iterActivity.Account__c;
            // inboxRecord.Lead__c = iterActivity.Lead__c;
            inboxRecord.WhatId__c = iterActivity.WhatId__c;
            inboxRecord.WhatId_ObjectApi_Name__c = iterActivity.WhatId_ObjectApi_Name__c;
            inboxRecord.Latest_Message__c = latestMessage;
            inboxRecord.Latest_Message_Received_At__c = iterActivity.When__c;
            inboxRecord.Latest_Activity_Number__c = Integer.valueOf(iterActivity.Activity_No__c);

            inboxRecord.Email__c = iterActivity.Email__c;
            inboxRecord.Phone__c = IterContactPhoneNumber;
            inboxRecord.External_Phone__c = iterActivity.External_Number__c;
            inboxRecord.External_Contact_Point__c = ExternalContactPoint;
            if(String.isNotBlank(ExternalContactPoint)){
                inboxList.add(inboxRecord);
            }
        }
        if(inboxList.size() > 0) {
            Schema.SObjectField externalIdField = Inbox__c.Fields.External_Contact_Point__c;
            List<SYS_IntegrationLog__c> errorLogs = new List<SYS_IntegrationLog__c>();
            Database.UpsertResult[] srList = Database.upsert(inboxList, externalIdField, false);
            for (Database.UpsertResult sr: srList) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors                
                    String errMsg = 'The following error has occurred while performing DML: ';
                    for (Database.Error err: sr.getErrors()) {
                        errMsg += err.getStatusCode() + ': ' + err.getMessage() + '. Fields affected are: ' + err.getFields() + '\n';
                    }
                    SYS_IntegrationLog__c log = new SYS_IntegrationLog__c();
                    log.How_to_process__c = 'ignore_log';
                    log.Type__c = 'RESPONSE';
                    log.retry__c = false;
                    log.Status__c = 'FAIL';
                    log.Message__c = errMsg;
                    errorLogs.add(log);
                }
            }
            if(errorLogs.size() > 0){
                SYS_Helper.upsertLog(errorLogs);
            }
        }
    }

    public static void handleBeforeInsert() {
        for(Activity__c iterActivity : ((List<Activity__c>)Trigger.new)){
            String ObjectApiName;
            String IterContactPhoneNumber = getFormattedPhoneNumber(iterActivity.Country_Code__c, iterActivity.Phone__c);
            // Id IterWhattId = getWhattIdFromActivityRecord(iterActivity);
            Id IterWhattId = iterActivity.Contact__c;
            //Set Formatted Phone Number on Activity
            iterActivity.Formatted_Phone__c = IterContactPhoneNumber;
            //Set When If Its Blank
            iterActivity.When__c =  (iterActivity.When__c != null) ? iterActivity.When__c : iterActivity.CreatedDate;
            if(IterWhattId != null){
                iterActivity.WhatId__c = IterWhattId;
                ObjectApiName = IterWhattId.getSObjectType().getDescribe().getName();
                iterActivity.WhatId_ObjectApi_Name__c = ObjectApiName;
            }
        }
    }

    public static void handleBeforeUpdate() {
        Map<Id, Activity__c> oldMap  = (Map<Id, Activity__c>)Trigger.oldMap;
        for(Activity__c iterActivity : ((List<Activity__c>)Trigger.new)){
            String ObjectApiName;
            String IterContactPhoneNumber = getFormattedPhoneNumber(iterActivity.Country_Code__c, iterActivity.Phone__c);
            // Id IterWhattId = getWhattIdFromActivityRecord(iterActivity);
            Id IterWhattId = iterActivity.Contact__c;
            //Set Formatted Phone Number on Activity
            iterActivity.Formatted_Phone__c = IterContactPhoneNumber;
            //Set When If Its Blank
            iterActivity.When__c =  (iterActivity.When__c != null) ? iterActivity.When__c : iterActivity.CreatedDate;
            if(IterWhattId != null){
                iterActivity.WhatId__c = IterWhattId;
                ObjectApiName = IterWhattId.getSObjectType().getDescribe().getName();
                iterActivity.WhatId_ObjectApi_Name__c = ObjectApiName;
            }
            if( (oldMap.containsKey(iterActivity.Id)) && (oldMap.get(iterActivity.Id).Status__c == 'Delivered') ){ 
                iterActivity.Status__c = 'Delivered';
            }
        }
    }

    public static void handleAfterUpdate() {

    }

    public static void handleBeforeDelete() {
        // for(Activity__c iterActivity : ((List<Activity__c>)Trigger.old)){
        //     String ExternalContactPoint = String.isNotBlank(iterActivity.Formatted_Phone__c) ? iterActivity.Formatted_Phone__c : iterActivity.Email__c;
        // }
        
    }

    public static void handleAfterDelete() {
        
    }

    public static void handleAfterUnDelete() {
       
    }
    
}