//https://adisols--pma.sandbox.my.salesforce-sites.com/services/apexrest/municorn/v1/Calendar?token=252Fm035j000000dIoZ&key=
public class Google_Calendar_SYS_ApplicationService extends SYS_ApplicationService{

    public Google_Calendar_SYS_ApplicationService() {
        
    }

    public class Google_Calendar_SYS_ApplicationServiceException extends Exception{}

    public override String sanitizeJSONForOutbound(String jsonRecord){
        String finalJSON = jsonRecord.replace('\n',' ');
    
        //Deserilize JSON and Map Keys 
        if(SYS_DataCacheFactory.OBJ_TYPE != 'CalenderWatchEvent') {
            Map<String, Object> newflatKeyMap = new Map<String, Object>();
            String rootkey, attendeesEmails;
            Boolean containsAttendeesKey = false;
            Object responseType = JSON.deserializeUntyped(finalJSON);
            if(responseType instanceof Map<String,Object>){
                rootkey = new List<String>(((Map<String, Object>)responseType).keySet())[0];
                newflatKeyMap = (SYS_Helper.getFlatKeys(finalJSON ,'A.B'));  //
                containsAttendeesKey = newflatKeyMap.containsKey('attendees');
            }
            if( rootkey!='' ){
                //Create Event Override Attendes String to ListWrap Convertion
                if( containsAttendeesKey == true ){
                    attendeesEmails = (String)newflatKeyMap.get('attendees');
                    ((Map < String, Object > ) responseType).remove('attendees');
                    if (String.isNotBlank(attendeesEmails)) {
                        cls_attendees attendees = new cls_attendees();
                        attendees.email = attendeesEmails;
    
                        List<cls_attendees> attendesList = new List<cls_attendees>{attendees};
                        ((Map < String, Object > ) responseType).put('attendees', attendesList);
                    }
                    
                    String newjsonBody = JSON.serialize(responseType);
                    System.debug('newjsonBody ' + newjsonBody);
                    finalJSON = newjsonBody;
                }
                
            }
        }
        return finalJSON;
    }
    
    public override List<SYS_IntegrationLog__c> generateLogForWebhookReq(String method) {
        // String requestBody = RestContext.request.requestBody.toString();
        string resourceurl = RestContext.request.headers.get('X-Goog-Resource-URI');
        
        String requestBody = '';
        if(!Test.isRunningTest()) {
            requestBody = getAllCalendarEvents(resourceurl);
        }

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
        log.Custom_Apex_Handler__c = 'Google_Calendar_SYS_ApplicationService';
        
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

    //parenting is not required for child records
    public override SYS_IntegrationLog__c generateLogForChildRecords(SYS_IntegrationLog__c parentLog,String resource,String recordsJson,String integrationSetting) {

        /*
        String query = 'SELECT '+SYS_Helper.getAllFieldsFor('SYS_IntegrationLog__c')+', Parent__r.WhatId__c, Parent__r.SYS_Operation_Type__c FROM SYS_IntegrationLog__c';
        String whereClause = ' WHERE Id in (' + '\'' + String.escapeSingleQuotes(parentLogId) + '\')';
        List<SYS_IntegrationLog__c> parentLog = 
        Database.query(String.escapeSingleQuotes(query)+whereClause);
        */

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
        // System.debug('log.Resource__c '+log.Resource__c);
        if(parentLog.Resource__c == 'items') {
            log.Requires_process_on_complete__c = true;
        }
        log.On_Complete_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
        /** */

        log.How_to_process__c = 'use_custom_apex_handler';
        log.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;

        return log;
    }

    public String getAllCalendarEvents(String resourceurl) {
        // String requestBody = RestContext.request.requestBody.toString();
        // Map<String, String> reqHeadersMap = RestContext.request.headers;
        // System.debug('mtestheaders ' + reqHeadersMap);
        // System.debug('mtestheaders calendarid' + RestContext.request.headers.get('X-Goog-Resource-URI'));
        // string resourceurl = RestContext.request.headers.get('X-Goog-Resource-URI');
        system.debug('resourceurl+++'+resourceurl);
        String result = '';
        String geturlframing = resourceurl.remove('alt=json');
        //getting the calendarid
        string calendarunsettled = geturlframing.remove('https://www.googleapis.com/calendar/v3/calendars/'); 
        string calendarid = calendarunsettled.remove('/events?');
        system.debug('geturlframing'+geturlframing);
        String geturlpattern = SYS_DataCacheFactory.integrationSetting.BaseAPIEndPoint__c;
        system.debug('geturlpattern'+geturlpattern);
        
        // Integer Year = Date.Today().Year();
        // Integer month = Date.Today().month();
        // Integer Day = Date.Today().Day();
        // string total = Year+'-'+month+'-'+Day;
        // system.debug(total);
        DateTime now =system.Now();
        Integer hours = now.hourGmt();

        Integer Year = now.YearGmt();
        Integer month = now.monthGmt();
        Integer Day = now.DayGmt();
        
        Integer minutes = now.minuteGmt();
        Integer seconds = now.secondGmt();

        string timeminimum = Year+'-'+month+'-'+Day+'T'+hours+':'+minutes+':'+seconds+'Z';
        System.debug('timeminimum++++++'+timeminimum);
        string endpoint = geturlframing+'timeMin='+timeminimum+'&maxResults=400&singleEvents=true&showDeleted=true&orderBy=startTime&timeZone=UTC';
        // string endpoint = geturlframing+'maxResults=1&singleEvents=true&orderBy=startTime';
        system.debug('endpointgetrequest'+endpoint);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);        
        req.setMethod('GET');
        String oauthGrantType = SYS_DataCacheFactory.integrationSetting.AuthenticationType__c;
        if(oauthGrantType.toLowerCase() == 'oauth'){
            List<SYS_OAuthConfig__c> configs = SYS_DataCacheFactory.authRec;
            system.debug('Nchconfigs'+configs);
            if(configs.size()>0){
				system.debug('configs'+configs);  

                if( (configs[0].Grant_Type__c == 'password') && (configs[0].Token_type__c == 'Basic')  ){
                    String Username = configs[0].Username__c;
                    String Password = configs[0].Password__c;
                    Blob headerValue = Blob.valueOf(Username + ':' + Password);
                    String authorizationHeader = EncodingUtil.base64Encode(headerValue);
                    req.setHeader('Authorization',configs[0].Token_type__c+' '+authorizationHeader); 
                }
                if( (configs[0].Grant_Type__c == 'authorization_code') && (configs[0].Token_type__c == 'Bearer')  ){
                    req.setHeader('Authorization',configs[0].Token_type__c+' '+configs[0].Access_Token__c); 
                }                                                      
            }
            SYS_debug.log('MS Header:'+req.getHeader('Authorization'));
        }
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('getbodynl'+res.getBody()); 
        SYS_debug.log('MS Header:'+req.getHeader('Authorization'));
        System.debug('Httpgetstatus'+res.getStatusCode());
        result = res.getBody();

        return result;
    }
   

    public override String getHttpRequestMethod(SYS_IntegrationLog__c log,String externalId){

        String httpMethod;
        if (log.HTTP_Method__c == NULL && log.Force_Sync__c && SYS_DataCacheFactory.OBJ_TYPE == 'CalenderWatchEvent') {
            httpMethod = 'POST';
        }
        else if (log.HTTP_Method__c != NULL){
            httpMethod = log.HTTP_Method__c;
        }
        else if (externalId != NULL && externalId != ''){
            httpMethod =  SYS_DataCacheFactory.integrationSetting.UpdateMethod__c;
        }
        else {
            httpMethod = 'POST';
        }
        
        log.HTTP_Method__c = httpMethod;
        return httpMethod;

    }

    public override String getHttpRequestEndpoint(HttpRequest req,SYS_IntegrationLog__c log, String externalId){
        
        if (log.Callout_URL__c!=NULL) {
            return log.Callout_URL__c;
        }
        
        String urlFromPattern = SYS_Helper.urlFromPattern(log.HTTP_Method__c, log.WhatId__c);

        if (log.Callout_URL__c == NULL && SYS_DataCacheFactory.OBJ_TYPE == 'CalenderWatchEvent' 
        && log.Force_Sync__c && urlFromPattern != null) {
            log.Callout_URL__c = urlFromPattern;
            return urlFromPattern;
        }
        else if (urlFromPattern != null) {
            log.Callout_URL__c = urlFromPattern;
            return log.Callout_URL__c;
        }
        else{
            String baseEndpoint = SYS_DataCacheFactory.integrationSetting.BaseAPIEndPoint__c;
            String resourceUrl = baseEndpoint + SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).ResourcePath__c;
            
            /*--*/SYS_debug.log('====== MS Endpoint check:'+resourceUrl);

            //Log is to create resource
            if(req.getMethod() == 'POST' && (externalId == NULL || externalId == '')){
                String urlParams='';
                if(SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).url_params__c != NULL)
                        urlParams = SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).url_params__c;
                
                if(urlParams!=''){
                    resourceUrl+='/'+urlParams;
                }
            }
            else{
                //Method is PUT / PATCH / DELETE / GET - so the URL will be of the form https://<xyz.abc>/v1/resource/:id
                resourceUrl+= '/'+ externalId;
            }
            /*--*/SYS_debug.log('====== MS Endpoint check:'+resourceUrl);
            log.Callout_URL__c = resourceUrl;
            return resourceUrl;
        }
        
    }

    public override Object getFieldValues(sObject obj, FieldSetting__mdt mapping, String fieldAPIName){
        //TODO - handle case - Account."CreatedBy".Name, where CreatedBy is not an sobject - This can be handled by overriding the current method and add the handler
        // on field setting

        System.debug('fieldAPIName '+fieldAPIName+SYS_DataCacheFactory.metadata?.get('webhook-url'));
        String fvalue= (mapping.Send_Blanks_as_Empty_String__c)?'':null;
        
        if (SYS_DataCacheFactory.OBJ_TYPE == 'CalenderWatchEvent' && fieldAPIName != NULL 
        && fieldAPIName?.equalsIgnoreCase('Google_Calendar_Id__c')) {
            return SYS_Helper.getUUID();
        }
        else if (fieldAPIName == null){
            fvalue = mapping.StaticValue__c;
        }
        else if(fieldAPIName.contains(SYS_DataCacheFactory.FLAT_KEY_SEPERATOR)){
            List<String> splitedFields = fieldAPIName.split('\\'+SYS_DataCacheFactory.FLAT_KEY_SEPERATOR);
            try{
                for(Integer i = 0; i < splitedFields.size() - 1; i++){
                    obj = obj.getSobject(splitedFields[i]);   
                } 
                if(fieldAPIName != NULL && fieldAPIName.equalsIgnoreCase('Account__r.UUID__c') && SYS_DataCacheFactory.OBJ_TYPE == 'CalenderWatchEvent') {
                    String webhookUrl = SYS_DataCacheFactory.metadata?.get('webhook-url');
                    if(webhookUrl != NULL) {
                        return webhookUrl+obj.get(splitedFields[splitedFields.size()-1]);
                    } else {
                        throw new Google_Calendar_SYS_ApplicationServiceException('Integration Metadata key webhook-url is not configured');
                    }
                } else
                    return obj.get(splitedFields[splitedFields.size()-1]);
            }catch(exception ex){
               /*--*/SYS_debug.log('****** Exception while fetching fieldValues as relationship '+fieldAPIName+'  value is blank.'+ex.getmessage()); 
               return null;
            }
            
        } 
        /*
        else if(obj.get(fieldAPIName)!=null && fieldAPIName == SYS_DataCache.namespacePrefix + 'Is_Taxable__c') { //TODO - specific to quickbooks
            return ((Boolean)obj.get(fieldAPIName)) ? 'TAX' : 'NON';
        } 
        else if(obj.get(fieldAPIName) != null && fieldAPIName == SYS_DataCache.namespacePrefix + 'Total_Tax__c') {
            return ((Decimal)obj.get(fieldAPIName)) == 0.00 ? 'null' : obj.get(fieldAPIName);  
        }
        */
        else if(obj.get(fieldAPIName)!=null){
            SObjectType r = obj.getSObjectType();
            DescribeSObjectResult d = r.getDescribe();
                    
            String fieldType = d.fields
                                .getMap()
                                .get(mapping.FieldApiName__c)
                                .getDescribe()
                                .getType()+'';
            if(fieldType == 'MULTIPICKLIST'){
                return ((String)obj.get(fieldAPIName)).split(';');
            }
            else
                return obj.get(fieldAPIName);
        }
        return fvalue;
    }

    public override void setHttpRequestHeaders(HttpRequest req,SYS_IntegrationLog__c log){
        
        List<HttpHeaders__mdt> httpHeader = SYS_DataCacheFactory.headerSetting;
        system.debug('NchhttpHeader'+httpHeader);
        
        for(HttpHeaders__mdt head:httpHeader){
            SYS_debug.log('header is = '+head.header_name__c +' '+head.Value__c);
            req.setHeader(String.valueOf(head.header_name__c), String.valueOf(head.Value__c));       
        }
        
        String oauthGrantType = SYS_DataCacheFactory.integrationSetting.AuthenticationType__c;
        if(oauthGrantType.toLowerCase() == 'oauth'){
            List<SYS_OAuthConfig__c> configs = SYS_DataCacheFactory.authRec;
            system.debug('Nchconfigs'+configs);
            if(configs.size()>0){
                if( (configs[0].Grant_Type__c == 'password') && (configs[0].Token_type__c == 'Basic')  ){
                    String Username = configs[0].Username__c;
                    String Password = configs[0].Password__c;
                    Blob headerValue = Blob.valueOf(Username + ':' + Password);
                    String authorizationHeader = EncodingUtil.base64Encode(headerValue);
                    req.setHeader('Authorization',configs[0].Token_type__c+' '+authorizationHeader); 
                }
                if( (configs[0].Grant_Type__c == 'authorization_code') && (configs[0].Token_type__c == 'Bearer')  ){
                    req.setHeader('Authorization',configs[0].Token_type__c+' '+configs[0].Access_Token__c); 
                }                                                      
            }
            SYS_debug.log('MS Header:'+req.getHeader('Authorization'));
        }
    }
    
    public class attendeesWrap{
        public cls_attendees[] attendees;
    }

    public class cls_attendees {
        public String email;	//lpage@example.com
    }
    
}