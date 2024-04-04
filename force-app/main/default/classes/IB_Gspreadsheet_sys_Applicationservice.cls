public with sharing class IB_Gspreadsheet_sys_Applicationservice extends SYS_ApplicationService{

    public Override List<SYS_IntegrationLog__c> generatelogForOutboundResultNew(HttpResponse resp,SYS_IntegrationLog__c log ){

        SYS_IntegrationLog__c logResp = new SYS_IntegrationLog__c();
        List<SYS_IntegrationLog__c> logAfterPartition = new List<SYS_IntegrationLog__c>();

        if(resp.getBody() != NULL && resp.getBody().length() > SYS_Constants.TEXT_AREA_MAX_SIZE*10) {
            logAfterPartition = SYS_Helper.getLogsAfterPartition(resp.getBody());
            if(logAfterPartition != NULL && logAfterPartition.size() > 0) {
                // SYS_Helper.upsertLog(logs[0]);
                // List<SYS_IntegrationLog__c> childs = SYS_Helper.getChildRecords(logs);
                
                // SYS_Helper.upsertLog(childs);
                logResp = logAfterPartition[0];
            }
        } else {
            logResp =  SYS_Helper.getLogsToInsert(resp.getBody());
        }

        String algo = SYS_DataCacheFactory.integrationSetting.Hashing_Algo__c;
        if(algo!=NULL && algo!='')
            logResp.Request_Digest__c = generateHash(resp.getBody(),algo);

        logResp.Force_Sync__c = log.Force_Sync__c;

        if(resp.getStatusCode() != 201 && resp.getStatusCode() != 200 && resp.getStatusCode() != 204){

            SYS_debug.log('#### resp status: '+resp.getStatus());
            SYS_debug.log('#### resp code: '+resp.getStatusCode()); 
            SYS_debug.log('#### resp: '+resp.getBody());

            log.Status__c = 'FAIL';
            if(!log.Force_Sync__c)
                log.retry__c = true;

            logResp.Status__c = 'ERROR';
            
            logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
            logResp.WhatId__c = log.WhatId__c;
            logResp.Type__c = SYS_Constants.RESPONSE;
            logResp.How_To_Process__c = 'ignore_log';
            logResp.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
            
        }
        else{
            log.Status__c = 'DONE';

            if (String.isEmpty(resp.getBody())) {
                logResp.How_To_Process__c = 'ignore_log';
                logResp.Status__c = 'DONE';
                logResp.How_To_Process__c = 'use_custom_apex_handler';
                logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
            }
            else if(log.SYS_Operation_Type__c == 'INSERT' || log.Force_Sync__c){
                logResp.Status__c = SYS_Constants.NEW_STATUS;
                logResp.SYS_Operation_Type__c = 'UPDATE';
                // logResp.Flat_Key_for_Resource__c = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Flat_Key_for_Resource_Response__c;

                if(SYS_DataCacheFactory.OBJ_TYPE!=NULL)
                    logResp.Resource__c = 'valueupdate';//SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Resource_Name__c;
                
                logResp.How_To_Process__c = 'use_custom_apex_handler';
                logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
            
            }
            else{

                
                if(SYS_DataCacheFactory.OBJ_TYPE != NULL && SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Always_Ignore_Response__c){
                        logResp.How_To_Process__c = 'ignore_log';
                        logResp.Status__c = 'DONE';
                }
                else{
                    if(SYS_DataCacheFactory.OBJ_TYPE!=NULL)
                        logResp.Resource__c = 'valueupdate';//SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Resource_Name__c;
                
                    logResp.SYS_Operation_Type__c = 'UPSERT';
                    logResp.How_To_Process__c = 'use_custom_apex_handler';
                    logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
                }
                //logResp.Status__c = 'DONE';
                //logResp.How_To_Process__c = 'ignore_log';

            }
            logResp.Flat_Key_for_Resource__c = 'valueupdate';//SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource_Response__c;
            logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
            logResp.WhatId__c = log.WhatId__c;
            logResp.Type__c = SYS_Constants.RESPONSE;
            logResp.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
            logResp.ObjectSettingId__c = log.ObjectSettingId__c;
            
        }

        //doDML(new List<SYS_IntegrationLog__c>{log}, 'UPSERT', '') ;
        // ##SYS_Helper.upsertLog(new List<SYS_IntegrationLog__c>{log});
        
        logResp.SYS_RequestId__c = log.Id;
        if(log.Id == NULL && log.UUID__c == NULL) {
            log.UUID__c = SYS_Helper.getUUID();
            logResp.Parent_UUID__c = log.UUID__c;
            logResp.UUID__c = SYS_Helper.getUUID();
        }
        List<SYS_IntegrationLog__c> returnVal = new List<SYS_IntegrationLog__c>();
        returnVal.add(log);
        returnVal.add(logResp);
        if(logAfterPartition != NULL && logAfterPartition.size() > 0) {
            logResp.Status__c = SYS_Constants.PENDING_PARTITIONED_LOOKUP;
            for(integer i = 1 ; i < logAfterPartition.size() ; i++) {
                returnVal.add(logAfterPartition[i]);
            }
        }
        return returnVal;
    }

   
}