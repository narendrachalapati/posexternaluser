public without sharing class FormController {
    public String formJSON {get; set;}
    public String formJSONCmp {get; set;}
    public String formResponseJSON {get; set;}
    public String recordId {get; set;}
    public Custom_Form__c form {get; set;}

    public Transient String VersionData {get; set;}
    public Transient String contentType {get; set;}
    public String PathOnClient {get; set;}
    public String Title {get; set;}
    public String domainUrl {get; set;}

    public ToDo__c todorecord { get; set; }

    public FormController() {

    }

    public class FormControllerException extends Exception {}

    public void getForm() {
        string formid =  ApexPages.currentPage().getParameters().get('formid');
        this.domainUrl = URL.getOrgDomainUrl().toExternalForm();
        if(formid == NULL) {
            //open page invalid
            // return;
        } 
        //check validity
        this.formJSON = getFormJSON(formid);
        if(this.formResponseJSON == NULL && this.form.Survey__r.Autofill_Configuration__c != NULL) {
            SYS_DataCacheFactory.INT_TYPE = 'Form';
            SYS_DataCacheFactory.OBJ_TYPE = this.form.Survey__r.Autofill_Configuration__c;
            // SYS_DataCacheFactory init = new SYS_DataCacheFactory(
            //     SYS_DataCacheFactory.INT_TYPE,
            //     SYS_DataCacheFactory.OBJ_TYPE 
            //     );
            List<Custom_Form__c> records = [select id from Custom_Form__c where id =: recordId];
            SYS_ApplicationService appService;
            appService = (SYS_ApplicationService)Type.forName(SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).ApexHandler__c).newInstance();
            Map<Id, String> jsonListForOutbound = appService.transformSObjectToJson(records);
            this.formResponseJSON = jsonListForOutbound.get(recordId)?.replace('\'', '\\\'');
            System.debug(' autofill '+this.formResponseJSON);
        }

    }

    public void sample(){
        

        String value = apexpages.currentPage().getParameters().get('inpval');
        system.debug(value);
        
    }

    public void saveResponse() {
        try {
            String response = apexpages.currentPage().getParameters().get('response');
            system.debug('response'+response);
            System.debug('this.todorecord '+this.todorecord);
            if (this.todorecord != NULL) {
                this.todorecord.Status__c = 'Completed';
                update this.todorecord;
            }
            this.form.Response_JSON__c = response;
            this.form.Submitted__c = true;
            update this.form;

            SYS_DataCacheFactory.INT_TYPE = 'Form';
            SYS_DataCacheFactory.OBJ_TYPE = this.form.Survey__r.Object_Setting__c;
            // SYS_DataCacheFactory init = new SYS_DataCacheFactory(
            //     SYS_DataCacheFactory.INT_TYPE,
            //     SYS_DataCacheFactory.OBJ_TYPE 
            //     );
            String jsonBody = response;
            String resource = SYS_DataCacheFactory.OBJ_TYPE;
            SYS_ApplicationService appService;
            List<sObject> records = SYS_Transformer.getSObjectsToUpsert(new List<String>{jsonBody},resource,true);

            if(records != NULL && records.size() > 0 && records[0] instanceOf Account) {

                records[0].Id = this.form.Account__c;
                Database.update(records[0]);
            } else if (records != NULL && records.size() > 0 && records[0] instanceOf Feedback__c) {
                records[0].put('WhatId__c', this.form.WhatId__c);
                Database.upsert(records[0]);
            }

            

        } catch(Exception e) {
            System.debug('Exception occured'+e.getMessage()+e.getStackTraceString());
        }
    }

    public void uploadFile() {
        try {
            // String VersionData = apexpages.currentPage().getParameters().get('VersionData');
            // system.debug(VersionData); // 
            List<Custom_Form__c> records = [select id,Account__c from Custom_Form__c where id =: recordId];
            List<SYS_OAuthConfig__c> Oauthlist = [select id from SYS_OAuthConfig__c where Name ='GoogleDrive'];
            
            GoogleDriveFile__c Googlefile = CustomfileuploaderController.uploadFile_g(records[0].Account__c,  Title,  this.VersionData, this.contentType);
            if( Googlefile != NULL && Oauthlist.size()==0){
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S';
            conVer.PathOnClient = this.PathOnClient;
            conVer.IsMajorVersion = true;
            conVer.versionData = EncodingUtil.base64Decode(this.VersionData);
            insert conVer;
                 
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = this.recordId;
            conDocLink.ContentDocumentId = conDoc;
            conDocLink.shareType = 'V';
            conDocLink.Visibility='AllUsers';
            insert conDocLink;

            ContentDocumentLink conDocLinkAccount = New ContentDocumentLink();
            conDocLinkAccount.LinkedEntityId = this.form.Account__c;
            conDocLinkAccount.ContentDocumentId = conDoc;
            conDocLinkAccount.shareType = 'V';
            conDocLinkAccount.Visibility='AllUsers';
            insert conDocLinkAccount;
    
            System.debug('version created');
            }
        } catch(Exception e) {

            System.debug('Exception occured'+e.getMessage()+e.getStackTraceString());
        }
        
    }

    public String getFormJSON(String formid) {
        String jsonStr;
        try {
            String query = 'SELECT '+ getAllFieldsFor('Custom_Form__c') +', '+
                                    getAllParentFields('Survey__r.','Survey__c') +
                                    ' FROM Custom_Form__c WHERE UUID__c =:formid LIMIT 1';
            System.debug('query '+query);
            List<Custom_Form__c> forms = Database.query(query);
            if (forms != NULL && forms.size() > 0) {
                this.form = forms[0];
                this.form.Opened__c = (this.form.Opened__c != NULL ? this.form.Opened__c : 0) + 1;
                this.formResponseJSON = (this.form.Response_JSON__c)?.replace('\'', '\\\'') != NULL ? 
                (this.form.Response_JSON__c)?.replace('\'', '\\\'') : '{}';
                update this.form;
                this.recordId = this.form.Id;
                // jsonStr = getJson(this.form.Survey__c);
                jsonStr = this.form?.Survey__r?.Form_JSON__c;
                System.debug('jsonStr '+jsonStr);
                System.debug('formResponseJSON '+formResponseJSON);
            } 
        } catch(Exception e) {
            System.debug('SP - error occured '+e.getMessage() +e.getStackTraceString());
        }
        
        return jsonStr;
    }

    public String getJson(String recordId){
        String jsonStr = '';
        SYS_DataCache.INT_TYPE = 'Form';
        SYS_DataCache.OBJ_TYPE = 'Survey';
        List<sObject> newSObjectList = [select id from Survey__c where id =: recordId];

        SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).ApexHandler__c).newInstance();
                
        Map<Id, String> jsonListForOutbound = appService.transformSObjectToJson(newSObjectList);
        jsonStr = jsonListForOutbound.get(recordId);

        return jsonStr;
    }

    public String getAllFieldsFor(String objName){

        return (String.join(getAllFields(objName),', '));
    }

    public List<String> getAllFields(String objName) {
        objName = SYS_DataCache.namespacePrefix + objName;

        List<String> fields = new List<String>();
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objName).getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            Schema.DescribefieldResult field = sfield.getDescribe();
            fields.add(field.getname()?.toLowerCase());
        }
        return fields;
    }

    public String getAllParentFields(String prefix, String objName) {
        List<String> fields = getAllFields(objName);
        for(Integer i=0; i<fields.size(); i++) {
            fields[i] = prefix + fields[i];
        }

        return (String.join(fields,', '));
    }

    
}


    // public void uploadFile() {
    //     System.debug('SP file upload');
    //     String boundary = '----------------------------741e90d31eff';
    //     String header = '--' + boundary + '\n' +
    //         'Content-Disposition: form-data; name="file";\n' +
    //         'Content-Type: application/json \n\n' +
    //         '{'+
    //             '"PathOnClient" : "'+ this.PathOnClient+'",'+
    //             '"Title" : "'+ this.Title + '",'+
    //             '"ContentLocation": "S"'+
    //         '}\n\n'+
    //         '--' + boundary +'\n'+
    //         'Content-Type: application/octet-stream' +
    //         'Content-Disposition: form-data; name="' + this.Title +'"; filename="' + this.PathOnClient + '"';
    //     String footer = '--' + boundary + '--';
    //     String body = this.VersionData;
    //     System.debug('body '+body);
    //     System.debug('sign '+this.Title);
    //     System.debug('path '+this.PathOnClient);
    //     // String wrap = EncodingUtil.base64Encode(Blob.valueOf(header)) + body + EncodingUtil.base64Encode(Blob.valueOf(footer));
    //     Blob wrap = Blob.valueOf(header + EncodingUtil.base64Decode(body) + footer);
    //     /* String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));
        
    //     while(headerEncoded.endsWith('=')) {
    //         header += ' ';
    //         headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
    //     }
        
    //     String bodyEncoded = this.VersionData;
    //     Blob bodyBlob = null;
    //     String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
    //     if (last4Bytes.endsWith('==')) {
    //         last4Bytes = last4Bytes.substring(0, 2) + '0K';
    //         bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length() - 4) + last4Bytes;   
    //         String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
    //         bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
    //     } else if (last4Bytes.endsWith('=')) {
    //         last4Bytes = last4Bytes.substring(0, 3) + 'N';
    //         bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length()-4) + last4Bytes;
    //         footer = '\n' + footer;
    //         String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
    //         bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);              
    //     } else {
    //         footer = '\r\n' + footer;
    //         String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
    //         bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);  
    //     } */
        
    //     HttpRequest req = new HttpRequest();
    //     req.setEndpoint(URL.getOrgDomainUrl().toExternalForm()+'/services/data/v57.0/sobjects/ContentVersion');
    //     req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
    //     req.setHeader('Authorization', 'Bearer '+UserInfo.getSessionId());
    //     req.setMethod('POST');
    //     req.setBodyAsBlob(wrap);
    //     req.setTimeout(120000);
    //     System.debug('endPoint=='+req.getEndPoint());
    //     Http h = new Http();
    //     HTTPResponse resp = h.send(req); 
        
    //     System.debug('#### resp status: '+resp.getStatus());
    //     System.debug('#### resp code: '+resp.getStatusCode());
    //     System.debug('#### resp: '+resp.getBody());

    //     if(resp.getStatusCode() == 200 || resp.getStatusCode() == 201) {
    //         System.debug('Uploaded to SF');
    //     } else {
    //         System.debug('Failed to Upload');
    //     }
    // }