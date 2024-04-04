public with sharing class MassMessageController {
    
    public MassMessageController(){}
    
    @AuraEnabled
    public static list<ListView> getListviewFilters(String sObjectApiName) {
        
        list<ListView> listviewlist = [SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, 
        IsSoqlCompatible, CreatedDate, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name, LastViewedDate, 
        LastReferencedDate FROM ListView WHERE SobjectType = :sObjectApiName];

        return listviewlist;
    }
    
    @AuraEnabled
    public static list<Sobject>  gettinglistviewfilteredRecords(String filterId, String objectName) {

        SYS_DataCacheFactory.INT_TYPE = 'Plivo';
        String MassMessageServiceHandler = 'MassMessageService';
        MassMessageServiceHandler = SYS_DataCacheFactory.metadata?.get(objectName+'_ApexHandler') != NULL ? 
                SYS_DataCacheFactory.metadata?.get(objectName+'_ApexHandler') : 'MassMessageService';
        MassMessageService mmService = (MassMessageService)Type.forName(MassMessageServiceHandler).newInstance();

        string listsoqlresponse = mmService.getListviewFilterhttp( filterId,objectName);
        //TODO move it to overrides
        // string tempwhereclause = listsoqlresponse.substringAfter('WHERE');
        // string lastnamevertual = 'Virtual Terminal';
    
        // String  whereclause =  ' WHERE Formatted_Phone_Number__c !=Null AND Active__c =true ' +((String.isNotBlank(tempwhereclause))?' AND ' + tempwhereclause : '');
    
        // String query = 'SELECT Id, Name, Formatted_Phone_Number__c, AccountId, Account.Name FROM Contact';
                
        List<sObject> sobjList = Database.query(listsoqlresponse);
    
        return sobjList;
    }
    
    @AuraEnabled
    public static list<Activity__c> createActivity(String messagebody, String messageSubject, list<Id> recordIdList, String sObjectApiName, String phoneNumber,
     String attachmentId, String currentfileType) {
        list<Activity__c> activitylist = new list <Activity__c>();
        try {
            
            SYS_DataCacheFactory.INT_TYPE = 'Plivo';
            String MassMessageServiceHandler = 'MassMessageService';
            if(String.isBlank(sObjectApiName)) {
                MassMessageServiceHandler = SYS_DataCacheFactory.metadata?.get(sObjectApiName+'_ApexHandler');
            }
            MassMessageService mmService = (MassMessageService)Type.forName(MassMessageServiceHandler).newInstance();
    
            activitylist = mmService.createActivity(messagebody, messageSubject, recordIdList, phoneNumber, attachmentId, currentfileType);
        } catch (Exception e) {
            System.debug(e.getMessage()+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        
        return activitylist;
    }

    /* File Attachments Component */
    @AuraEnabled
    public static Id saveChunk(List<Id> parentIds, String fileName, String base64Data, String contentType, String fileId) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks   
        if ( String.isBlank(fileId) ) {
            fileId = saveTheFile(parentIds, fileName, base64Data);
        } else {
            appendToFile(fileId, base64Data);
        }
        return Id.valueOf(fileId);
    }

    private static Id saveTheFile(List<Id> recordIds, String fileName, String base64Data )  {         
        ContentVersion contentToInsert =new ContentVersion(); 
        contentToInsert.Title =fileName; 
        contentToInsert.VersionData=EncodingUtil.base64Decode(base64Data);
        contentToInsert.PathOnClient='/' + fileName ;
        contentToInsert.IsMajorVersion = false;
        insert contentToInsert; 
        
        contentToInsert = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentToInsert.Id];
        List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();
        for(Id recordId : recordIds) {
            ContentDocumentLink cl = new ContentDocumentLink();
            cl.ContentDocumentId = contentToInsert.ContentDocumentId;
            cl.LinkedEntityId = recordId; 
            cl.ShareType = 'V';
            cl.Visibility = 'AllUsers';
            documentLinks.add(cl);
        }
        
        insert documentLinks;
        
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
    
    /*@AuraEnabled
    public static String calloutSynchronousOutbound(List<Id> recIdList, String objSetting, String apexHandler, String direction, String accountMergeField) {
        Map<Id, String> recordIdStatusMap = new Map<Id, String>();
        Set<String> calloutResponseStatusSet = new Set<String>();
        String CalloutResponseStatus = 'FAILED';
        for (Id recId: recIdList) {
            String status;
            status = SYS_ForceSync_Controller.invokeAccountFlow(recId, objSetting, apexHandler, direction, accountMergeField);
            calloutResponseStatusSet.add(status);
            recordIdStatusMap.put(recId, status);
        }
        if( (calloutResponseStatusSet.size() > 0 ) ){
            Integer calloutResponseStatusSetSize = calloutResponseStatusSet.size();
            Boolean checkcalloutResponseStatusSuccess = calloutResponseStatusSet.contains('DONE');
            if( (calloutResponseStatusSetSize == 1) && (checkcalloutResponseStatusSuccess == true) ){
                CalloutResponseStatus = 'DONE';
            }
        }
        System.debug(LIMITS.getLimitDMLStatements()+' :: '+Limits.getDMLStatements());
        return CalloutResponseStatus;
    }*/
    }