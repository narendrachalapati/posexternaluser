public without sharing class QB_ApplicationServiceOutbound extends SYS_ApplicationService {
   /* ------------------------------------------------------------------------ */
   public override void setHttpRequestHeaders(HttpRequest req,SYS_IntegrationLog__c log){

    List<HttpHeaders__mdt> httpHeader = SYS_DataCacheFactory.headerSetting;
    for(HttpHeaders__mdt head:httpHeader){
        SYS_debug.log('header is = '+head.header_name__c +' '+head.Value__c);
        req.setHeader(String.valueOf(head.header_name__c), String.valueOf(head.Value__c));       
    }
    SYS_debug.log('Narendra object' + SYS_DataCacheFactory.OBJ_TYPE);
    if(SYS_DataCacheFactory.OBJ_TYPE =='QBObjectSetting_SendInvoiceEmail'){
        req.setHeader('Content-Type', 'application/octet-stream');  
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

/* ------------------------------------------------------------------------ */
}