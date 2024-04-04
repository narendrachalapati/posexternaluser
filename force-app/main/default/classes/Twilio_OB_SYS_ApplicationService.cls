public without sharing class Twilio_OB_SYS_ApplicationService extends SYS_ApplicationService {

    public Twilio_OB_SYS_ApplicationService() {}

    public class Twilio_OB_SYS_ApplicationServiceException extends Exception {}

    /* ------------------------------------------------------------------------ */
    /**
     * OUTBOUND
     * This hook is called from SYS_Transformer to set values for JSON record
     * Relies on Integration Setting in DataCache
     * Override if custom field mapping is required
     */
    public override Object getFieldValues(sObject obj, FieldSetting__mdt mapping, String fieldAPIName){
       
        String fvalue= (mapping.Send_Blanks_as_Empty_String__c)?'':null;
       
        if(fieldAPIName == null){
            fvalue = mapping.StaticValue__c;
        }
        else if(fieldAPIName.contains(SYS_DataCacheFactory.FLAT_KEY_SEPERATOR)){
            List<String> splitedFields = fieldAPIName.split('\\'+SYS_DataCacheFactory.FLAT_KEY_SEPERATOR);
            try{
                for(Integer i = 0; i < splitedFields.size() - 1; i++){
                    obj = obj.getSobject(splitedFields[i]);   
                } 
                return obj.get(splitedFields[splitedFields.size()-1]);
            }catch(exception ex){
               /*--*/SYS_debug.log('****** Exception while fetching fieldValues as relationship '+fieldAPIName+'  value is blank.'+ex.getmessage()); 
               return null;
            }
            
        } 
      
        
        else if((obj.get(fieldAPIName)!=null) && (fieldAPIName == SYS_DataCache.namespacePrefix + 'Formatted_Phone__c'|| fieldAPIName == SYS_DataCache.namespacePrefix + 'External_Number__c') ) { //TODO - specific to quickbooks
            return '+' + obj.get(fieldAPIName);
          
        } 
    
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

    public override String preprocessJSONForOutbound(SYS_IntegrationLog__c log, String jsonBody, HttpRequest req) {
        try{
            /*--*/SYS_debug.log('Default preprocessJSONForOutbound called');
            String dialogflowParametersJson = '';
            Map<String, String> dialogflowParametersMap = new Map<String, String>();
            
            if(req.getHeader('content-type') == 'application/x-www-form-urlencoded'){
                String formUrlEncodedBody='';
                Map<String,Object> jsonobj = SYS_Helper.getFlatKeys(jsonBody,SYS_DataCacheFactory.FLAT_KEY_PATTERN);//(Map<String,Object>)JSON.deserializeUntyped(flatJSON);
                List<String> reqkeymap = new List<String>(jsonobj.keySet());
                List<String> keyValueList = new List<String>();
                reqkeymap.sort();
                
                for (String key: reqkeymap) {
                    if (!String.isBlank(key) /*&& jsonobj.get(key) != '' && (jsonobj.get(key)) instanceOf String*/){
                        if ( (key == 'salesforcerecorduuid') || (key == 'selected_service_uuid') || (key == 'selected_service') ) {
                            dialogflowParametersMap.put(key, String.valueOf(jsonobj.get(key)!=NULL?jsonobj.get(key):'') );
                            jsonobj.remove(key);
                        } else {
                            keyValueList.add(key + '=' + EncodingUtil.urlEncode(String.valueOf(jsonobj.get(key)!=NULL?jsonobj.get(key):''),'UTF-8'));
                        }
                    }
                }
                
                if(dialogflowParametersMap != NULL) {
                    dialogflowParametersJson = JSON.serialize(dialogflowParametersMap);
                }
                
                if( String.isNotBlank(dialogflowParametersJson) ) {
                    keyValueList.add('Parameters=' + EncodingUtil.urlEncode(String.valueOf(dialogflowParametersJson),'UTF-8'));
                    
                    jsonobj.put('Parameters', dialogflowParametersJson);
                    jsonBody = JSON.serialize(jsonobj);
                    log.data0__c = jsonBody; 
                }
                
                formUrlEncodedBody = String.join(keyValueList,'&');
                log.data1__c = formUrlEncodedBody; 
                
                jsonBody = formUrlEncodedBody;
            }
            else if(req.getHeader('content-type') == 'multipart/form-data'){
                //TODO form-data with boundary calculation
            }
            else{
                //TODO throw exception invalid header or just log
            }
        }catch(Exception ex) {
            throw new Twilio_OB_SYS_ApplicationServiceException('Error: Twilio_OB_SYS_ApplicationService.preprocessJSONForOutbound :\n '+ ex.getMessage() +'\n'+ ex.getStackTraceString() +'\n');
        }
        return jsonBody;
    }
    
    public override void setHttpRequestHeaders(HttpRequest req,SYS_IntegrationLog__c log){
        
        List<HttpHeaders__mdt> httpHeader = SYS_DataCacheFactory.headerSetting;
        for(HttpHeaders__mdt head:httpHeader){
            SYS_debug.log('header is = '+head.header_name__c +' '+head.Value__c);
            req.setHeader(String.valueOf(head.header_name__c), String.valueOf(head.Value__c));       
        }

        String oauthGrantType = SYS_DataCacheFactory.integrationSetting.AuthenticationType__c;
        if(oauthGrantType.toLowerCase() == 'oauth'){
            
            List<SYS_OAuthConfig__c> configs = SYS_DataCacheFactory.authRec;
            
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


}