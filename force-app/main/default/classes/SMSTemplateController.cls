public with sharing class SMSTemplateController {
    public static String ERROR_MESSAGE = 'Some error occured. Please contact admin.';

    public SMSTemplateController() {

    }

    public class SMSTemplateControllerException extends Exception {}

    @AuraEnabled(cacheable = true)
    public static List<SObJectResult> getResults(String ObjectName, String fieldName, String value) {
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        for(sObject so : Database.Query('Select Id,'+fieldName+' FROM '+ObjectName+' WHERE '+fieldName+' LIKE \'%' + value + '%\' LIMIT 20')) {
            String fieldvalue = (String)so.get(fieldName);
            sObjectResultList.add(new SObjectResult(fieldvalue, so.Id));
        }
        
        return sObjectResultList;
    }
    
    public class SObJectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;
        
        public SObJectResult(String recNameTemp, Id recIdTemp) {
            recName = recNameTemp;
            recId = recIdTemp;
        }
    }

    @AuraEnabled
    public static String fetchPreview(String recordId, String templateBody) {
        String parsedOutput = templateBody;
        try {
            if(!String.isBlank(recordId))
                parsedOutput = MergeFields.parseBody(recordId, templateBody);
            parsedOutput = MergeFields.parseBody(UserInfo.getUserId(), parsedOutput);

        } catch (Exception e) {
            System.debug(e.getMessage() + e.getStackTraceString());
            throw new AuraHandledException(ERROR_MESSAGE);
        }
        return parsedOutput;
    }

    
    @AuraEnabled
    public static void upsertTemplate(String recordId, String templateName, String templateBody, Boolean isAvailable) {
        try {
            Converse_Template__c template = new Converse_Template__c();
            template.Id = recordId;
            template.Account__c = getAccountId();
            template.Name = templateName;
            template.IsActive__c = isAvailable;
            template.Object_Name__c = 'Contact';
            template.Template__c = templateBody;

            upsert template;

        } catch (Exception e) {
            System.debug(e.getMessage() + e.getStackTraceString());
            throw new AuraHandledException(ERROR_MESSAGE);
        }
    }

    public static String getAccountId() {
        Id result;
        try {
            User user = [SELECT Id, ContactId__c From User WHERE Id =: UserInfo.getUserId()];
            if (user != NULL) {
                Id contactId = (Id)user.ContactId__c;
                List<Contact> contact = [SELECT Id, AccountId FROM Contact WHERE Id =: contactId];
                if (contact != NULL && contact.size() > 0) {
                    result = (Id)contact[0].AccountId;
                }
            } 
        } catch (Exception e) {
            System.debug(e.getMessage() + e.getStackTraceString());
            throw new SMSTemplateControllerException(ERROR_MESSAGE);
        }
        return result;
    }

    @AuraEnabled
    public static Converse_Template__c fetchTemplate(Id recordId) {
        Converse_Template__c template;
        try {
            String query = 'SELECT '+ SYS_Helper.getAllFieldsFor('Converse_Template__c') +
            ' FROM Converse_Template__c WHERE Id = :recordId';
            List<Converse_Template__c> templates = Database.query(query);
            if(templates != NULL && templates.size() > 0) {
                template = templates[0];
            }

        } catch (Exception e) {
            System.debug(e.getMessage() + e.getStackTraceString());
            throw new AuraHandledException(ERROR_MESSAGE);
        }
        return template;
    }
}