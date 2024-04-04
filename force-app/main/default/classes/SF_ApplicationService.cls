public without sharing class SF_ApplicationService extends SYS_ApplicationService {

    // public override SYS_IntegrationLog__c generateLogForWebhookReq(String method) {
        
    //     String requestBody = RestContext.request.requestBody.toString();
    //     SYS_IntegrationLog__c log = SYS_Helper.getLogsToInsert(requestBody);

    //     String algo = SYS_DataCacheFactory.integrationSetting.Hashing_Algo__c;
    //     if(algo!=NULL && algo!='')
    //     log.Request_Digest__c = generateHash(requestBody,algo);

    //     if(SYS_DataCacheFactory.integrationSetting.Notifications_are_partial__c)
    //         log.Is_Notification_Only__c = true;

    //     log.Type__c = 'INBOUND';
    //     log.SYS_Operation_Type__c = getOperationTypeFor(method);
    //     log.Flat_Key_for_Resource__c = SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource__c;
    //     log.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
    //     log.Status__c = 'NEW';
    //     log.How_to_process__c = 'use_custom_apex_handler';
    //     log.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
    //     log.Resource__c = 'survey';
    //     return log;
    // }

    public override List<SYS_IntegrationLog__c> generateLogForWebhookReq(String method) {
        String requestBody = RestContext.request.requestBody.toString();
        SYS_IntegrationLog__c log = new SYS_IntegrationLog__c();
        List<SYS_IntegrationLog__c> logAfterPartition = new List<SYS_IntegrationLog__c>();
        
        //Check criteria when chars more than 1M
        if(requestBody != NULL && requestBody.length() > SYS_Constants.TEXT_AREA_MAX_SIZE*10) {
            logAfterPartition = SYS_Helper.getLogsAfterPartition(requestBody);
            if(logAfterPartition != NULL && logAfterPartition.size() > 0) {
                // SYS_Helper.upsertLog(logs[0]);
                // List<SYS_IntegrationLog__c> childs = SYS_Helper.getChildRecords(logs);
                
                // SYS_Helper.upsertLog(childs);
                log = logAfterPartition[0];
            }
            System.debug('SP 1M<<');
        } else {
            log = SYS_Helper.getLogsToInsert(requestBody);
            System.debug('SP 1M>>');
        }

        String algo = SYS_DataCacheFactory.integrationSetting.Hashing_Algo__c;
        if(algo!=NULL && algo!='')
        log.Request_Digest__c = generateHash(requestBody,algo);

        if(SYS_DataCacheFactory.integrationSetting.Notifications_are_partial__c)
            log.Is_Notification_Only__c = true;

        log.Type__c = 'INBOUND';
        log.SYS_Operation_Type__c = getOperationTypeFor(method);
        log.Flat_Key_for_Resource__c = SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource__c;
        log.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
        log.Status__c = 'NEW';
        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
        log.Resource__c = 'survey';
        
        log.Account_Id__c = SYS_DataCacheFactory.accountId;
        log.Integration_Type__c = SYS_DataCacheFactory.integrationSetting?.Integration_Type__c;

        List<SYS_IntegrationLog__c> returnVal = new List<SYS_IntegrationLog__c>();
        returnVal.add(log);
        if(logAfterPartition != NULL && logAfterPartition.size() > 0) {
            log.Status__c = 'PENDING_PARTITIONED_LOOKUP';
            for(integer i = 1 ; i < logAfterPartition.size() ; i++) {
                returnVal.add(logAfterPartition[i]);
            }
        }

        return returnVal;
    }


    // public override Boolean doInbound(SYS_IntegrationLog__c log) {
        
    //     String jsonBody = '';
    //     jsonBody =  SYS_Helper.getDataFrom(log); 
    //     jsonBody = preprocessJSONForInbound(log,jsonBody);

    //     if(SYS_DataCacheFactory.integrationSetting.Notifications_are_partial__c && 
    //         log.Is_Notification_Only__c
    //         ){
    //         //String baseEndpoint = SYS_DataCacheFactory.integrationSetting.BaseAPIEndPoint__c;
    //         String getURLPattern = SYS_DataCacheFactory.integrationSetting.GET_URL_Pattern__c;
            
    //         SYS_NotificationInterface it = 
    //         (SYS_NotificationInterface)Type.forName(SYS_DataCacheFactory.integrationSetting.Notification_Wrapper__c).newInstance();
            
    //         List<SYS_IntegrationLog__c> insertSysLog = new List<SYS_IntegrationLog__c>();

    //         for(Map<String,String> rMap:it.getIterator(jsonBody)){
    //             String getURL = getURLPattern;
    //             SYS_IntegrationLog__c  newSysLog = new SYS_IntegrationLog__c();
    //             for(String key:rMap.keySet()){
    //                 getURL = getURL.replaceAll('\\{'+key+'\\}',rMap.get(key));
  
    //             }
    //             /*--*/SYS_debug.log('=============== '+ getURL);

    //             newSysLog.Status__c = 'NEW';
    //             newSysLog.HTTP_Method__c = 'GET';
    //             newSysLog.Callout_URL__c = getURL;
    //             newSysLog.Type__c = 'OUTBOUND';
    //             newSysLog.WhatId__c = log.Id;
    //             newSysLog.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
    //             newSysLog.SYS_Operation_Type__c = 'UPSERT';
    //             newSysLog.How_to_process__c = 'use_custom_apex_handler';
    //             newSysLog.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
    //             insertSysLog.add(newSysLog);
    //         }

            
    //         if(insertSysLog.size()>0 && SYS_DataCacheFactory.enableCheck){
    //             SYS_Helper.insertLog(insertSysLog);
    //         }

    //         return true;

    //     }
    //     else{
    //         String resource = getResourceFromJSON(log,jsonBody);
    //         log.Resource__c = resource;
    //         SYS_debug.log('\n\n ------------------------------- \n\n Application Service resource:'+resource);

    //         List<sObject> sObjectsToDML = transformJsonToSObject(jsonBody, resource, log);

    //         SYS_debug.log('\n\n ------------------------------- \n\n Application Service sObjects to DML:'+sObjectsToDML);
    //         SYS_debug.log('\n\n ------------------------------- \n\n Application Service externalKeyByResourceMap:'+SYS_DataCacheFactory.externalKeyByResourceMap);

    //         String externalIdFieldAPIName = SYS_DataCacheFactory.externalKeyByResourceMap.get(resource);
    //         //String externalIdFieldAPIName = log.External_Id_Field_API_Name__c!=NULL?log.External_Id_Field_API_Name__c:'';
    //         for(sObject obj:sObjectsToDML) {
    //             if(resource == 'survey') {
    //                 obj.put('UUID__c', SYS_Helper.getUUID());
    //                 //TODO - implement ordering, 
    //                 obj.put('Form_JSON__c', log.data0__c);
    //             }
    //         }
    //         return doDML(sObjectsToDML,log.SYS_Operation_Type__c,externalIdFieldAPIName,log);
    //     }
        
    // }

    public override void processInboundRecord(SYS_IntegrationLog__c log, Map<SYS_IntegrationLog__c, sObject> mapLogrecVsObject, List<SYS_IntegrationLog__c> partialSysLogs, List<SYS_IntegrationLog__c> allChildLogs) {
        
        String jsonBody = '';
        // jsonBody =  SYS_Helper.getDataFrom(log);
        jsonBody =  SYS_Helper.getDataFromNew(log, allChildLogs); 
        jsonBody = preprocessJSONForInbound(log,jsonBody);

        if(SYS_DataCacheFactory.integrationSetting.Notifications_are_partial__c && 
            log.Is_Notification_Only__c
            ){
            String baseEndpoint = SYS_DataCache.integrationSetting.get(SYS_Datacache.INT_TYPE).BaseAPIEndPoint__c;
            String getURLPattern = baseEndpoint + SYS_DataCacheFactory.integrationSetting.GET_URL_Pattern__c;
            
            SYS_NotificationInterface it = 
            (SYS_NotificationInterface)Type.forName(SYS_DataCacheFactory.integrationSetting.Notification_Wrapper__c).newInstance();
            
            // List<SYS_IntegrationLog__c> insertSysLog = new List<SYS_IntegrationLog__c>();

            for(Map<String,String> rMap:it.getIterator(jsonBody)){
                String getURL = getURLPattern;
                SYS_IntegrationLog__c  newSysLog = new SYS_IntegrationLog__c();
                for(String key:rMap.keySet()){
                    getURL = getURL.replaceAll('\\{'+key+'\\}',rMap.get(key));
  
                }
                /*--*/SYS_debug.log('=============== '+ getURL);

                newSysLog.Status__c = 'NEW';
                newSysLog.HTTP_Method__c = 'GET';
                newSysLog.Callout_URL__c = getURL;
                newSysLog.Type__c = 'OUTBOUND';
                newSysLog.WhatId__c = log.WhatId__c;
                newSysLog.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
                newSysLog.SYS_Operation_Type__c = 'UPSERT';
                newSysLog.How_to_process__c = 'use_custom_apex_handler';
                newSysLog.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
                newSysLog.Parent__c = log.Id;
                partialSysLogs.add(newSysLog);
            }

            
            // if(insertSysLog.size()>0 && SYS_DataCache.enableCheck.get(SYS_DataCache.INT_TYPE.toUpperCase())){
            //     SYS_Helper.insertLog(insertSysLog);
            // }

            // return true;

        }
        else{
            String resource = getResourceFromJSON(log,jsonBody);
            log.Resource__c = resource;
            SYS_debug.log('\n\n ------------------------------- \n\n Application Service resource:'+resource);

            List<sObject> sObjectsToDML = transformJsonToSObject(jsonBody, resource, log);

            SYS_debug.log('\n\n ------------------------------- \n\n Application Service sObjects to DML:'+sObjectsToDML);
            SYS_debug.log('\n\n ------------------------------- \n\n Application Service externalKeyByResourceMap:'+SYS_DataCache.externalKeyByResourceMap);

            String externalIdFieldAPIName = SYS_DataCacheFactory.externalKeyByResourceMap.get(resource);
            //String externalIdFieldAPIName = log.External_Id_Field_API_Name__c!=NULL?log.External_Id_Field_API_Name__c:'';
            
            for(sObject item: sObjectsToDML) {
                try {
                    item.put('Last_Processed_SYSLog__c', log.Id);
                } catch(Exception e) {
                    throw new SYS_ApplicationServiceException('Last Processed SYSLog field is not implemented : \n '+e.getMessage());
                }
                if( item.get('Id') == NULL && log.WhatId__c != NULL) {
                    item.put('Id', log.WhatId__c);
                }
                if(resource == 'survey') {
                    item.put('UUID__c', SYS_Helper.getUUID());
                    //TODO - implement ordering, 
                    item.put('Form_JSON__c', log.data0__c);
                }
            }
            if(sObjectsToDML.size() > 0)
                mapLogrecVsObject.put(log, sObjectsToDML[0]);
        }
        return ;
    }

    public override SYS_IntegrationLog__c generateLogForChildRecords(SYS_IntegrationLog__c parentLog,String resource,String recordsJson,String integrationSetting) {

        SYS_IntegrationLog__c log = SYS_Helper.getLogsToInsert(recordsJson);

        log.ObjectSettingId__c = parentLog.ObjectSettingId__c;
        log.Account_Id__c = parentLog.Account_Id__c;
        log.Integration_Type__c = parentLog.Integration_Type__c;
        /* ------------------------------------ FOR ALL OR NONE HANDLING -------------------------------------- */
        if(log.ObjectSettingId__c!=NULL && SYS_DataCacheFactory.objectSettingMap.get(log.ObjectSettingId__c).All_OR_None__c){
            //log.Custom_Field_Value__c = parentLog[0].WhatId__c;
            log.SYS_Operation_Type__c = 'INSERT';
        }
        else {
            log.SYS_Operation_Type__c = 'UPSERT';
        }
        /* ------------------------------------ FOR ALL OR NONE HANDLING -------------------------------------- */

        String algo = SYS_DataCacheFactory.integrationSetting.Hashing_Algo__c;
        if(algo!=NULL && algo!='')
            log.Request_Digest__c = generateHash(recordsJson,algo);

        SYS_debug.log('MS SYS_DataCache.log in generate child log:'+SYS_DataCache.log.Id);
        log.Parent__c = parentLog.Id;       
        log.Type__c = 'INBOUND';
 
        /**
         * If there the Parent Resource Map is defined on IS the use it to derive the resource for child records else
         * If Flat key to identify resource for child records is defined on Integration Setting, consider that
         * Else take the root key as Resource that is passed on while processing parent record
         */
        String flat_key_for_child = SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource_Child__c;

        if(SYS_DataCacheFactory.PARENT_RESOURCE_MAP != NULL){
            log.Resource__c = SYS_DataCacheFactory.PARENT_RESOURCE_MAP.get(parentLog.Resource__c);
        }
        else if(flat_key_for_child != NULL && flat_key_for_child!='') {
            log.Flat_Key_for_Resource__c = flat_key_for_child;
        }
        else if(resource == 'elements' && parentLog.Resource__c == 'elements') {
            log.Resource__c = 'elements'+'.'+resource;
            log.Flat_Key_for_Resource__c = '';
        }
        else{
            log.Resource__c = resource;
            log.Flat_Key_for_Resource__c = '';
        }
        log.Integration_Setting__c = integrationSetting;
        log.Status__c = 'NEW';
        /**
         * Applies when the child records require parenting after creation
         */
        log.Requires_process_on_complete__c = true;
        log.On_Complete_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
        /** */

        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;

        return log;
    }

    public override void fixParent(String parentLogId,SYS_IntegrationLog__c childLog){

        List<FieldSetting__mdt> fsm = getPrimaryLookupFieldSetting(childLog.Resource__c);

        /*--*/SYS_debug.log('MS Fixing Relationship:'+fsm);

        List<sObject> childRecords = new List<sObject>();
        List<String> dupeCheckList = new List<String>();
        List<SYS_IntegrationLog__c> childLogs = [SELECT Id,WhatId__c,Parent__r.WhatId__c FROM SYS_IntegrationLog__c WHERE Parent__c = :parentLogId AND Status__c='PENDING_PARENT'];

        for(SYS_IntegrationLog__c cLog:childLogs)
        {
            /*--*/SYS_debug.log('MS dupeCheckList:'+dupeCheckList);

            if(!dupeCheckList.contains(cLog.WhatId__c) && cLog.WhatId__c!=null){
                childRecords.clear();
                sObject sObj = Schema.getGlobalDescribe().get(fsm[0].ObjectApiName__c).newSObject();
                /*--*/SYS_debug.log('MS cLog:'+cLog);
                /*--*/SYS_debug.log('MS cLog.Parent__r.WhatId__c:'+cLog.Parent__r.WhatId__c);
                sObj.put('Id',cLog.WhatId__c);
                sObj.put(fsm[0].FieldApiName__c,cLog.Parent__r.WhatId__c);
                childRecords.add(sObj);
                dupeCheckList.add(String.valueOf(sObj.get('Id')));

                //TODO Add Limit check. This is to make sure each log is processed separately and thereby avoid overriding of log properties
                if(doDML(childRecords, 'UPDATE', '',cLog)){
                    cLog.Status__c ='DONE';
                    cLog.retry__c =false;
                    SYS_Helper.updateLog(cLog);
                }
            }
            if(!dupeCheckList.contains(cLog.WhatId__c) && cLog.WhatId__c!=null ) {
                dupeCheckList.add(cLog.WhatId__c);
            }
        }


        /* ------------------------------------ ALL OR NONE HANDLING STARTS -------------------------------------- */

        /**
         * Check if Object Setting is configured with ALL-OR-NONE checked
         * If yes, delete the existing child records. To identify the EXISTING child records
         * on the SAME object to which this child records belong we will take just the first record
         * generate child log - identify the resource - followed by field setting for lookup
         * and get the object api name
         */


        if(SYS_DataCacheFactory.objectSettingMap.get(childLog.ObjectSettingId__c).All_OR_None__c){

            String qry = 
            'SELECT Id FROM '+
            fsm[0].ObjectApiName__c;
            
            String whereClauseVal = (childLogs[0].Parent__r.WhatId__c==null)?'':childLogs[0].Parent__r.WhatId__c;
            String whereClause = 
            ' WHERE '+String.escapeSingleQuotes(fsm[0].FieldApiName__c)+'=\''+
            String.escapeSingleQuotes(whereClauseVal)+'\''+
                            ' AND Id NOT IN (\''+ 
            String.join(dupeCheckList,'\',\'')+'\')';  
            
            /*--*/SYS_debug.log('MS All or none delete records query:'+qry);

            List<sObject> childRecordsToDelete = new List<sObject>();
            childRecordsToDelete = Database.query(String.escapeSingleQuotes(qry)+whereClause);

            /*--*/SYS_debug.log('MS All or none delete records:'+childRecordsToDelete);
            if(childRecordsToDelete.size() > 0)
                SYS_Helper.deleteWithFLSCheck(childRecordsToDelete);
        }

        /* ------------------------------------ ALL OR NONE HANDLING ENDS ---------------------------------------- */


    }
}