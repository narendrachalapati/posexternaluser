public with sharing class MediaAuthentication {
    /*public static string  MediaAcessgetcall( string Accountid,string mediaUrl) {
        List < SYS_OAuthConfig__c > configs = [SELECT Id,Username__c,Password__c FROM SYS_OAuthConfig__c 
                                               WHERE Account__c =:Accountid AND Integration_Type__c='Twilio'];
        
                                               HttpRequest req = new HttpRequest();
                                               req.setMethod('GET');
                                               Blob headerValue = Blob.valueOf(configs[0].Username__c + ':' + configs[0].Password__c);
                                               String authorizationHeader = 'Basic ' +
                                               EncodingUtil.base64Encode(headerValue);
                                               req.setHeader('Authorization', authorizationHeader);
                                               req.setEndpoint(mediaUrl);
                                               req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                                               Http http = new Http();
                                               HTTPResponse res = http.send(req);
                                               System.debug(res.getBody());
                                               return res.getBody();


    }*/
    public static string MediaAcessgetcall( string Accountid,string mediaUrl){
       
       
        List < SYS_OAuthConfig__c > configs = [SELECT Id,Username__c,Password__c FROM SYS_OAuthConfig__c 
        WHERE Account__c =:Accountid AND Integration_Type__c='Twilio'];
        //use for send request
        Http http = new Http();
        // use for set all parameter 
        HttpRequest req = new HttpRequest();
        String endpoint = mediaUrl;
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type','application/text'); 
 
        String username = 'Username';
        String password = 'Password';
        // convert in Blob
        Blob headerValue = Blob.valueOf(configs[0].Username__c + ':' + configs[0].Password__c);
        String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
 
        // HTTPResponse to get response from send request
        HTTPResponse res = http.send(req);
        System.debug('Response Status Code==> '+res.getStatusCode());
        System.debug('Response Status==> '+res.getStatus()); 
        System.debug('Response Headers==> '+res.getHeaders());
        if(res.getStatusCode() == 201 || res.getStatusCode() == 200){
            System.debug('Response Body==> ' + res.getBody());
        }else{
            //handler error
        }
        return res.getBody();
    }
}