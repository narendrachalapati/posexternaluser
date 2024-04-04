public without sharing class Stripe_Inbound_SYS_ApplicationService extends SYS_ApplicationService {
    public Stripe_Inbound_SYS_ApplicationService() {

    }
    
    /**
     * This hook is called from each of the hook for Http Verb processing
     * Arguement: Http Verb - POST,GET,PATCH,DELETE,PUT
     * Relies on Integration Setting in DataCache and RestContext
     * Override if custom log generation is required
     */
    //Process Webhook Responses for Stripe Integration
    public override List<SYS_IntegrationLog__c> generateLogForWebhookReq(String method) {
        String requestBody = RestContext.request.requestBody.toString();
        SYS_IntegrationLog__c log = new SYS_IntegrationLog__c();
        List<SYS_IntegrationLog__c> logAfterPartition = new List<SYS_IntegrationLog__c>();

        Map<String, Object> newflatKeyMap = new Map<String, Object>();
        newflatKeyMap = (SYS_Helper.getFlatKeys(requestBody ,'A.B')); 
        String eventType = newflatKeyMap.containsKey('type') ? (String)newflatKeyMap.get('type') :'';
        if(eventType == 'payment_method.detached'){
            method = 'DELETE';
        }

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
        
        String algo = SYS_DataCacheFactory.integrationSetting?.Hashing_Algo__c;
        if(algo!=NULL && algo!='')
        log.Request_Digest__c = generateHash(requestBody,algo);

        log.Type__c = 'INBOUND';
        log.SYS_Operation_Type__c = getOperationTypeFor(method);
        //Flat_Key_for_Resource_Response__c
        log.Flat_Key_for_Resource__c = SYS_DataCacheFactory.integrationSetting?.Flat_Key_for_Resource__c;
        log.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
        log.Status__c = 'NEW';
        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting?.ApexHandler__c;

        //new fields
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

        String algo = SYS_DataCacheFactory.integrationSetting?.Hashing_Algo__c;
        if(algo!=NULL && algo!='')
            log.Request_Digest__c = generateHash(recordsJson,algo);

        SYS_debug.log('MS SYS_DataCacheFactory.log in generate child log:'+SYS_DataCacheFactory.log.Id);
        log.Parent__c = parentLog.Id;       
        log.Type__c = 'RESPONSE';
 
        /**
         * If there the Parent Resource Map is defined on IS the use it to derive the resource for child records else
         * If Flat key to identify resource for child records is defined on Integration Setting, consider that
         * Else take the root key as Resource that is passed on while processing parent record
         */
        String flat_key_for_child = SYS_DataCacheFactory.integrationSetting?.Flat_Key_for_Resource_Child__c;

        if(SYS_DataCacheFactory.PARENT_RESOURCE_MAP != NULL){
            log.Resource__c = SYS_DataCacheFactory.PARENT_RESOURCE_MAP.get(parentLog.Resource__c);
        }
        else if(flat_key_for_child != NULL && flat_key_for_child!='')
            log.Flat_Key_for_Resource__c = flat_key_for_child;
        else{
            log.Resource__c = resource;
            log.Flat_Key_for_Resource__c = '';
        }
        log.Integration_Setting__c = integrationSetting;
        log.Status__c = 'NEW';
        /**
         * Applies when the child records require parenting after creation
         */
        log.Requires_process_on_complete__c = false;
        log.On_Complete_Handler__c = SYS_DataCacheFactory.integrationSetting?.ApexHandler__c;
        /** */

        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting?.ApexHandler__c;

        return log;
    }

    /**
     * INBOUND
     * This hook is called from SYS_Transformer to set values for sObject record
     * Default is mapping based on field type
     * Relies on Integration Setting in DataCache
     * Override if custom field mapping is required
     */
    public override sObject processFieldMapping(FieldSetting__mdt mapping,sObject sObj,Object value, String sObjectApiName){

        System.debug(mapping.FieldApiName__c+' +MS+ '+value);
        if(mapping.Get_value_from_Log__c)
            value = SYS_DataCacheFactory.log.get(mapping.Log_API_for_field_mapping__c);

        if(mapping.Is_Lookup__c && mapping.Lookup_External_Key__c!=NULL && mapping.Lookup_Object_API_Name__c!=NULL){
            value = getIdFromExternalKey(mapping.Lookup_Object_API_Name__c,mapping.Lookup_External_Key__c,String.valueOf(value));
        }

        if(mapping.StaticValue__c != NULL)
            value = mapping.StaticValue__c;
            

        if( (value==NULL) && (mapping.FieldApiName__c != 'Default_Payment_Method__c') ) return sObj;

        SObjectType r = ((SObject)(Type.forName('Schema.'+sObjectApiName).newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();
                
        String fieldType = d.fields
                            .getMap()
                            .get(mapping.FieldApiName__c)
                            .getDescribe()
                            .getType()+'';

        
        //TODO add other field types
        if(fieldType=='DATE'){
            sObj.put(mapping.FieldApiName__c, getDateValue(mapping,String.valueOf(value)) /*Date.valueOf((String)value)*/);
        }
        else if(fieldType=='DATETIME'){
            
            sObj.put(mapping.FieldApiName__c, getDatetimeValue(mapping, String.valueOf(value)));
        }
        else if(fieldType=='TIME'){
            sObj.put(mapping.FieldApiName__c, getTimeValue(mapping, String.valueOf(value)));
        }
        else if (fieldType == 'STRING') {
            sObj.put(mapping.FieldApiName__c, String.valueof(value));
        }else if (fieldType == 'BOOLEAN') {
            sObj.put(mapping.FieldApiName__c, Boolean.valueof(value));
        }else if (fieldType == 'CURRENCY') {
            sObj.put(mapping.FieldApiName__c, Double.valueof(value)/100);
        }
        else if ( (mapping.FieldApiName__c == 'Default_Payment_Method__c') ) {
            sObj.put(mapping.FieldApiName__c, '');
        }
        else{
            sObj.put(mapping.FieldApiName__c, value);
        }

        SYS_debug.log('MS FINAL SOBJ:'+sObj);
        return sObj;
    }
    /* ------------------------------------------------------------------------ */
    /**
     * OUTBOUND
     * This hook is called from SYS_Transformer to set values for JSON record
     * Relies on Integration Setting in DataCache
     * Override if custom field mapping is required
     */
    public override Object getFieldValues(sObject obj, FieldSetting__mdt mapping, String fieldAPIName){
        //TODO - handle case - Account."CreatedBy".Name, where CreatedBy is not an sobject - This can be handled by overriding the current method and add the handler
        // on field setting
        String fvalue= (mapping.Send_Blanks_as_Empty_String__c)?'':null;
        
        if(fieldAPIName == null){
            fvalue = mapping.StaticValue__c;
            return fvalue;
        }
        
        //Get Field Type
        SObjectType r = obj.getSObjectType();
        DescribeSObjectResult d = r.getDescribe();

        String fieldType = d.fields
            .getMap()
            .get(fieldAPIName)
            .getDescribe()
            .getType() + '';

        if(fieldAPIName.contains(SYS_DataCacheFactory.FLAT_KEY_SEPERATOR)){
            List<String> splitedFields = fieldAPIName.split('\\'+SYS_DataCacheFactory.FLAT_KEY_SEPERATOR);
            try{
                for(Integer i = 0; i < splitedFields.size() - 1; i++){
                    obj = obj.getSobject(splitedFields[i]);   
                } 
                return obj.get(splitedFields[splitedFields.size()-1]);
            }catch(exception ex){
               System.debug('****** Exception while fetching fieldValues as relationship '+fieldAPIName+'  value is blank.'+ex.getmessage()); 
               return null;
            }
            
        }else if( (obj.get(fieldAPIName)!=null) && (fieldType == 'CURRENCY') ) {
            Decimal amount = (Decimal)obj.get(fieldAPIName);
            return (amount > 0) ? ( (amount) * 100 ).intValue() : 0;
        } 
        else if(obj.get(fieldAPIName)!=null){
            return obj.get(fieldAPIName);
        }
        return fvalue;
    }

     public override Boolean doDelete(List<sObject> records,SYS_IntegrationLog__c log){
        Database.DeleteResult[] results;
        Boolean success = true;
        if (records.size() > 0) {
            for (sObject currentObj: records) {
                if (currentObj instanceOf Payment_Method__c) {
                    String paymentMethodId = (String) currentObj.get('Payment_Method_Id__c');
                    if(String.isNotBlank(paymentMethodId)){
                        Payment_Method__c paymentMethodRecord = [SELECT Id, Payment_Method_Id__c FROM Payment_Method__c WHERE Payment_Method_Id__c =:paymentMethodId ];
                        if(String.isNotBlank(paymentMethodRecord.Id)){
                            currentObj.put('Id', paymentMethodRecord.Id);
                        }                        
                    }
                }
            }
        }
        
        System.debug('doDelete ' + records);
        System.debug('doDelete ' + records[0]);
        results = SYS_Helper.deleteWithFLSCheck(records);
        if(!results[0].isSuccess()){
            success = false;
            handleDMLErrors(results[0].getErrors(),log);
        }
        else{
            log.WhatId__c = results[0].getId();
        }

        return success;
    }

}