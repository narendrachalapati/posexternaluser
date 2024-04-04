public class Gmail_OB_SYS_ApplicationService extends SYS_ApplicationService {
    
    public Gmail_OB_SYS_ApplicationService() {}
    
    public class Gmail_OB_SYS_ApplicationServiceException extends Exception {}
    public override  String preprocessJSONForOutbound(SYS_IntegrationLog__c log,String jsonBody,HttpRequest req) {
        /*--*/SYS_debug.log('Default preprocessJSONForOutbound called');
        
        if(req.getHeader('content-type') == 'application/x-www-form-urlencoded'){
            String formUrlEncodedBody='';
            Map<String,Object> jsonobj = SYS_Helper.getFlatKeys(jsonBody,SYS_DataCacheFactory.FLAT_KEY_PATTERN);//(Map<String,Object>)JSON.deserializeUntyped(flatJSON);
            List<String> reqkeymap = new List<String>(jsonobj.keySet());
            List<String> keyValueList = new List<String>();
            reqkeymap.sort();
            
            for (String key: reqkeymap) {
                if (!String.isBlank(key) /*&& jsonobj.get(key) != '' && (jsonobj.get(key)) instanceOf String*/){
                    
                    keyValueList.add(key.toLowerCase() + '=' + EncodingUtil.urlEncode(String.valueOf(jsonobj.get(key)!=NULL?jsonobj.get(key):''),'UTF-8'));
                }
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
            //
            //Gmail specific override for making the b64 encoded string
            Map<String, Object> newflatKeyMap = new Map<String, Object>();
            List<String> keyValueList = new List<String>();
            newflatKeyMap = (SYS_Helper.getFlatKeys(jsonBody ,'A.B')); 
            for (String key: newflatKeyMap.keySet()) {
                if(newflatKeyMap.get(key)!=NULL){
                if( (key.toLowerCase() == 'from') || (key.toLowerCase() == 'reply-to') || (key.toLowerCase() == 'to') || (key.toLowerCase() == 'subject') || (key.toLowerCase() == 'content-type')  ) {
                    keyValueList.add( key +': '+ String.valueOf(newflatKeyMap.get(key)!=NULL?newflatKeyMap.get(key): '') );	
                }
                }
                if( (key.toLowerCase() == 'body') ) {
                    keyValueList.add('\n'+ String.valueOf(newflatKeyMap.get(key)!=NULL?newflatKeyMap.get(key): '') );	
                }
            }
            String finaljson = String.join(keyValueList,'\n');
            //String finaljson = midJson.replaceAll('Body: ', '\n');
            system.debug('NDR' + finaljson);
            Blob binaryData = Blob.valueOf(finaljson);
            //TO-Do Create Wrapper for Gmail Send Mail API
            ((Map < String, Object > ) newflatKeyMap).put('raw', binaryData);
            // Encode the Blob as a Base64 string
            String base64String = EncodingUtil.base64Encode(binaryData);
            string newjsonBody = JSON.serialize(newflatKeyMap);
            SYS_debug.log('newjsonBody ' + newjsonBody);
            jsonBody = newjsonBody;  
            log.data0__c = jsonBody;
            log.data1__c = finalJson;
            
        }
        return jsonBody;
    }
    
    
}