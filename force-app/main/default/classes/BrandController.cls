public without sharing class BrandController {
    // Start Component Properties
    @AuraEnabled
    public Boolean isUploadComponent {get;set;}
    //uuid of related tracker record
    @AuraEnabled
    public String uuid {get; set;}
    //Account Record Id
    @AuraEnabled
    public String accountId { get; set; }
    //Member Record Id
    @AuraEnabled
    public String memberId { get; set; }
    
    @AuraEnabled
    public String todorecordid { get; set; }
    // End Component Properties

	public class BrandControllerException extends Exception {}

    public void initBrandComponent() {
        try {
            
        } catch(Exception ex) {
            System.debug(ex.getMessage()+'\n'+ex.getStackTraceString());
        }     
    }
    
    @AuraEnabled
    public static CustomfileuploaderController.GoogleDriveFileUploaderInitWrapper initFileUploader(Id recordId) {
        try {
            String objectApiName = '', parentFolderId = '', accountMergeField = '';
    
            //Set Merge Field Based on RecordID
            if( recordId != NULL) {
                objectApiName = ((Id)recordId).getSObjectType().getDescribe().getName();
                if( objectApiName == 'Account' ) {
                    accountMergeField = '';
                } else if( objectApiName == 'Contact' ) {
                    accountMergeField = 'AccountId';
                } else {
                    accountMergeField = 'Account__c';
                }
            } else {
                throw new BrandControllerException('Record ID is null');
            }
    
            //Call Fetch googleDrive Wrapper to fetch related Parent Folder Ids
            CustomfileuploaderController.GoogleDriveFileUploaderInitWrapper googleDriveUploadWrapper = CustomfileuploaderController.initFileUploaderWrapper(recordId, accountMergeField, true);
    
            if( (googleDriveUploadWrapper != NULL) && (googleDriveUploadWrapper.currentObjectGoogleFolderId != NULL) ) {
                parentFolderId = googleDriveUploadWrapper.currentObjectGoogleFolderId;
            } else {
                throw new BrandControllerException('Failed to fetch related Parent Folder Id');
            }
            return googleDriveUploadWrapper;
        } catch (Exception e) {
            // throw new AuraHandledException(e.getMessage());
            System.debug(e.getMessage()+'\n'+e.getStackTraceString());
            throw new BrandControllerException(e.getMessage()+'\n'+e.getStackTraceString()); 
        }
    }
    
    @AuraEnabled
    public static GoogleDriveFile__c fetchFileRecordDetailsByWhattId(Id recordId) {
        
        GoogleDriveFile__c brandGoogleFileRecord = new GoogleDriveFile__c();
        List<GoogleDriveFile__c> brandGoogleFileRecordsList = new List<GoogleDriveFile__c>();
    
        // Fetch Brand Google File Record List
        String brandGoogleFileRecordsQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('GoogleDriveFile__c') +
        ' FROM GoogleDriveFile__c WHERE WhatId__c =: recordId AND UseType__c = \'Brand\' ORDER BY LastModifiedDate DESC';
        brandGoogleFileRecordsList = Database.query(brandGoogleFileRecordsQuery);
        brandGoogleFileRecord = (brandGoogleFileRecordsList.size() > 0) ? brandGoogleFileRecordsList[0] : new GoogleDriveFile__c();
    
        return brandGoogleFileRecord;
    }
    
    @AuraEnabled
    public static GoogleDriveFile__c Fileupload(Id RecordId,String accountMergeField, String Tittle, String base64Data, String contentType) {
        string ParentaccountNaming,Useremail,googlefolderparentId;
        integer fileuploadstatuscode;
        Boolean isnewgooglefolderId;
        system.debug('RecordIdNDR' + RecordId);
        String sObjName = RecordId.getSObjectType().getDescribe().getName();
        String integrationSettingtype = 'GoogleDrive';
        String fetchRecordQuery, accountId, googeldrivfolderId;
        List < Sobject > fetchRecord = new list < Sobject > ();
        if (accountMergeField == 'AccountId') {
            ParentaccountNaming = 'Account.';
        } else {
            ParentaccountNaming = 'Account__r.';
        }
        system.debug('ParentaccountNamingNDR'+ParentaccountNaming);
        fetchRecordQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor(sObjName) +
            '  ' + SYS_Helper.getAllAccessibleParentFields(ParentaccountNaming, 'Account') +
            ', ' + SYS_Helper.getAllAccessibleParentFields(ParentaccountNaming + 'Owner.', 'User') +
            ' FROM    ' + sObjName + '  WHERE Id =:RecordId';
        system.debug('fetchRecordQueryNDR ' + fetchRecordQuery);
        fetchRecord = Database.query(fetchRecordQuery);
        system.debug('fetchRecordNDR'+fetchRecord);
        if (fetchRecord.size() > 0) {
            accountId = (String) fetchRecord[0].get(accountMergeField);
        }
        String objectSetting = SYS_DataCacheFactory.metadata.containsKey(sObjName) ? SYS_DataCacheFactory.metadata.get(sObjName) : 'Drive_File_OS';
        if (accountId != NULL) {
            SYS_DataCacheFactory init = new SYS_DataCacheFactory(
                accountId,
                integrationSettingtype,
                integrationSettingtype,
                objectSetting
            );
        } else {
            SYS_DataCacheFactory init = new SYS_DataCacheFactory(
                integrationSettingtype,
                objectSetting
            );
        }
    
        List < SYS_OAuthConfig__c > Oauth = SYS_DataCacheFactory.authRec;
        string accessToken = Oauth[0].Access_Token__c;
        system.debug(accessToken);
        List < HttpHeaders__mdt > headermeta = SYS_DataCacheFactory.headerSetting;
        system.debug('headermeta NDR' + headermeta);
        system.debug('contentType' + contentType);
        String baseEndpoint = SYS_DataCacheFactory.integrationSetting.BaseAPIEndPoint__c;
        system.debug('baseEndpointNDR' + baseEndpoint);
        system.debug('accountMergeFieldNDR' + accountMergeField);
        system.debug('ObjectType' + SYS_DataCacheFactory.OBJ_TYPE);
        String resourceUrl = baseEndpoint + SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).ResourcePath__c;
        /*--*/
        SYS_debug.log('====== MS Endpoint check:' + resourceUrl);
        GoogleDriveFile__c Googlefile;
        string base64Datamod = 'data:' + contentType + ';base64,' + base64Data;
        //TODO Make the folder arrangement correctly
        // Baed on what id we have to allocate the floders
        googeldrivfolderId = (String) fetchRecord[0].get('GoogleDriveFolderId__c');
    
        //TODO Use Type cast to get the sobject fetching the correct sobject retrive the merge fields
        if (accountMergeField == 'AccountId') {
        Useremail = (String) fetchRecord[0].getSObject('Account').getSObject('Owner').get('Email');
       
        }else{
        Useremail = (String) fetchRecord[0].getSObject('Account__r').getSObject('Owner').get('Email'); 
        
        }
      
        //(String)s.getSObject('Contact').getSObject('Account').get('Name');
        system.debug('UseremailNDR ' + Useremail);
        if (string.isBlank(googeldrivfolderId)) {
    
            if (accountMergeField == 'AccountId') {
            googlefolderparentId = (String) fetchRecord[0].getSObject('Account').get('GoogleDriveFolderId__c');
            }else{
            googlefolderparentId = (String) fetchRecord[0].getSObject('Account__r').get('GoogleDriveFolderId__c');   
            }
            //googeldrivfolderId = CustomfileuploaderController.creategooglefolderReclog(accessToken, RecordId, googlefolderparentId, RecordId, baseEndpoint);
            
            isnewgooglefolderId = true;
            system.debug('isnewgooglefolderId' + isnewgooglefolderId);
        }
        system.debug('googeldrivfolderIdNDR' + googeldrivfolderId);
        string file = base64Data;
        string filename = Tittle;
        string tempfiletype = contentType;
        string folderid = googeldrivfolderId;
        system.debug('folderid' + folderid);
        string filetype = contentType;
        system.debug(filetype);
        Integer httpstatuscode;
        if (file != null) {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
    
            String boundary = 'foo_bar_baz';
            String delimiter = '\r\n--' + boundary + '\r\n';
            String closeDelimiter = '\r\n--' + boundary + '--';
    
            //Converts a Blob to an unencoded String representing its normal form
            String encodedFile = EncodingUtil.urlDecode(file, 'UTF-8');
            // Construct the multipart request body
            String body = delimiter + 'Content-Type: application/json\r\n\r\n' +
                '{ "title":"' + fileName + '","type": "anyone","role": "reader",' +
                ' "mimeType":"' + filetype + '", "parents": [{"kind": "drive#fileLink", "id": "' + folderId + '"}]}' +
                delimiter + 'Content-Type: ' + filetype + '\r\nContent-Transfer-Encoding: base64\r\n\r\n' +
                encodedFile + closeDelimiter;
            system.debug('body' + body);
            // Blob tempBlob = Blob.valueOf(body);
            //set methods into req to upload file
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('Content-length', String.valueOf(body.length()));
            req.setHeader('Content-Type', 'multipart/related; boundary=' + boundary);
            req.setEndpoint(resourceUrl); //'https://www.googleapis.com/upload/drive/v2/files?uploadType=multipart');
            // req.setBodyAsBlob(tempBlob);
            req.setBody(body);
            req.setMethod('POST');
            HttpResponse res = h.send(req);
            fileuploadstatuscode = res.getStatusCode();
            system.debug('resp' + res);
            system.debug(res.getBody());
            string jsonRecord = res.getBody();
            //Deserilize JSON and Map Keys 
            if (fileuploadstatuscode == 200 || fileuploadstatuscode == 201) {
                Map < String, Object > newflatKeyMap = new Map < String, Object > ();
                String finalJSON = jsonRecord.replace('\n', ' ');
                Object convert = System.JSON.deserializeUntyped(finalJSON);
                String GooglecontentId, Thumbnaillink, Downloadlink, Previewlink;
                newflatKeyMap = (SYS_Helper.getFlatKeys(finalJSON, 'A.B'));
                GooglecontentId = (String) newflatKeyMap.get('id');
                Thumbnaillink = (String) newflatKeyMap.get('thumbnailLink');
                system.debug('Thumbnaillink' + Thumbnaillink);
                Downloadlink = (String) newflatKeyMap.get('webContentLink');
                Previewlink = (string.isNotBlank(Downloadlink) ? Downloadlink.remove('=download') : Downloadlink);
                system.debug('Downloadlink' + Downloadlink);
                system.debug('GooglecontentId' + GooglecontentId);
                  if (GooglecontentId != null) {
                      //CustomfileuploaderController.googlefilePermission(GooglecontentId, accessToken);
                  }
                if (isnewgooglefolderId == true) {
                    GoogleDriveFolder__c googlefolderrec = new GoogleDriveFolder__c();
                    googlefolderrec.Account__C = accountId;
                    googlefolderrec.Name = sObjName + RecordId + ' folder';
                    googlefolderrec.WhatId__c = RecordId;
                    googlefolderrec.GoogleDrive_ID__c = googeldrivfolderId;
                    googlefolderrec.Synchronous__c = true;
                   
                    system.debug('googlefolderrec' + googlefolderrec);
                    upsert googlefolderrec;
                }
                if (GooglecontentId != null) {
                    Googlefile = new GoogleDriveFile__c();
                    Googlefile.WhatId__c = RecordId;
                    Googlefile.Account__c=accountId;
                    // Googlefile.ContentVersionId__c = contetid;
                    Googlefile.GoogleDrive_ID__c = GooglecontentId;
                    Googlefile.Name = Tittle;
                    //  Googlefile.BrandName__c =con.BrandName__c ;
                    Googlefile.Preview_Link__c = Previewlink;
                    Googlefile.ThumbnailLink__c = Thumbnaillink;
                    Googlefile.ParentFolderId__c = googeldrivfolderId;
                    Googlefile.DownloadLink__c = Downloadlink;
                    Googlefile.ContentType__c = contentType;
                    Googlefile.UseType__c = 'Brand';
                    upsert Googlefile;
                }
    
            }
    
        }
        return Googlefile;
    }
    @AuraEnabled
    public static GoogleDriveFile__c EditFile_g(Id googlefileid, String Tittle, String base64Data, String contentType) {
        system.debug('googlefileid' + googlefileid);
        GoogleDriveFile__c googlefile = [select ParentFolderId__c , GoogleDrive_ID__c, Contact__c from GoogleDriveFile__c where id =: googlefileid];
        system.debug('contentType' + contentType);
        //string googeldrivfolderId;
        //GoogleDriveFile__c Googlefile;
        string base64Datamod = 'data:' + contentType + ';base64,' + base64Data;
        SYS_OAuthConfig__c configue = [select Access_Token__c from SYS_OAuthConfig__c where name = 'GoogleDrive'];
        string accessToken = configue.Access_Token__c;
        system.debug(configue);
        string file = base64Data;
        string filename = Tittle;
        string tempfiletype = contentType;
        //  string folderid = googeldrivfolderId; //googeldrivfolderId;
        // system.debug('folderid' + folderid);
        string filetype = contentType;
        system.debug(filetype);
        Integer httpstatuscode;
        if (file != null) {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
    
            String boundary = 'foo_bar_baz';
            String delimiter = '\r\n--' + boundary + '\r\n';
            String closeDelimiter = '\r\n--' + boundary + '--';
    
            //Converts a Blob to an unencoded String representing its normal form
            String encodedFile = EncodingUtil.urlDecode(file, 'UTF-8');
    
            String body = delimiter + 'Content-Type: application/json\r\n\r\n' + '{ "title":"' + fileName + '","type": "anyone","role": "reader"' +
                ', "mimeType":"' + filetype + '"}' +
                delimiter + 'Content-Type: ' + filetype + '\r\n' + 'Content-Transfer-Encoding: base64\r\n' + '\r\n' +
                encodedFile + closeDelimiter;
    
            system.debug('body' + body);
            // Blob tempBlob = Blob.valueOf(body);
            //set methods into req to upload file
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('Content-length', String.valueOf(body.length())); // multipart/related; boundary=foo_bar_baz
            req.setHeader('Content-Type', 'multipart/related; boundary="' + boundary + '"');
            req.setEndpoint('https://www.googleapis.com/upload/drive/v2/files/' + googlefile.GoogleDrive_ID__c);
            req.setBody(body);
            req.setMethod('PUT');
    
            HttpResponse res = h.send(req);
            httpstatuscode = res.getStatusCode();
            system.debug('resp' + res);
            system.debug(res.getBody());
            string jsonRecord = res.getBody();
            //Deserilize JSON and Map Keys 
            Map < String, Object > newflatKeyMap = new Map < String, Object > ();
    
            String finalJSON = jsonRecord.replace('\n', ' ');
            Object convert = System.JSON.deserializeUntyped(finalJSON);
    
            String GooglecontentId, Thumbnaillink, Downloadlink, Previewlink;
            newflatKeyMap = (SYS_Helper.getFlatKeys(finalJSON, 'A.B'));
            GooglecontentId = (String) newflatKeyMap.get('id');
            Thumbnaillink = (String) newflatKeyMap.get('thumbnailLink');
            system.debug('Thumbnaillink' + Thumbnaillink);
            Downloadlink = (String) newflatKeyMap.get('webContentLink');
            Previewlink = (String) newflatKeyMap.get('embedLink');
            system.debug('Downloadlink' + Downloadlink);
            system.debug('GooglecontentId' + GooglecontentId);
            if (GooglecontentId != null) {
                Googlefile = new GoogleDriveFile__c();
                //s Googlefile.Account__c = parentId;
                // Googlefile.ContentVersionId__c = contetid;
                Googlefile.GoogleDrive_ID__c = GooglecontentId;
                Googlefile.Name = Tittle;
                // Googlefile.b64string__c = base64Datamod;
                Googlefile.Preview_Link__c = Previewlink;
                Googlefile.ThumbnailLink__c = Thumbnaillink;
                //Googlefile.ParentFolderId__c =  googeldrivfolderId;
                Googlefile.DownloadLink__c = Downloadlink;
                Googlefile.ContentType__c = contentType;
                upsert Googlefile;
    
    
            }
    
    
        }
        return Googlefile;
    }
    public static string creategooglefolder(string accessToken, string Tittle, string parentgoogleid, string parentid) {
        //Deserilize JSON and Map Keys 
        Map < String, Object > newflatKeyMap = new Map < String, Object > ();
        list < string > Parentidlist = new list < String > ();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint('https://www.googleapis.com/drive/v3/files');
        string jsonRecord = '{"mimeType":"application/vnd.google-apps.folder","kind":"drive#file"}';
        String finalJSON = jsonRecord.replace('\n', ' ');
        Object convert = System.JSON.deserializeUntyped(finalJSON);
    
        newflatKeyMap = (SYS_Helper.getFlatKeys(finalJSON, 'A.B'));
        if (parentgoogleid != null)
            Parentidlist.add(parentgoogleid);
        ((Map < String, Object > ) convert).put('name', parentid);
        ((Map < String, Object > ) convert).put('parents', Parentidlist);
        system.debug('convert' + convert);
        string midformJSON = JSON.serialize(convert);
        finalJSON = midformJSON.replace('\n', ' ');
        system.debug('finalJSONNarendra' + finalJSON);
        req.setBody(finalJSON);
        req.setMethod('POST');
    
        HttpResponse res = h.send(req);
        string jsonRecordres = res.getBody();
        system.debug('jsonRecordres' + jsonRecordres);
        //Deserilize JSON and Map Keys 
        Map < String, Object > newflatKeyMapres = new Map < String, Object > ();
        String finalJSONres = jsonRecordres.replace('\n', ' ');
        Object convertres = System.JSON.deserializeUntyped(finalJSONres);
        String googlefolderid;
        newflatKeyMapres = (SYS_Helper.getFlatKeys(finalJSONres, 'A.B'));
        system.debug('newflatKeyMapres' + newflatKeyMapres);
        googlefolderid = (String) newflatKeyMapres.get('id');
        system.debug('googlefolderid' + googlefolderid);
    
        return googlefolderid;
    }
    public static string creategooglefolderReclog(string accessToken, string Tittle, string parentgoogleid, string parentid, string baseEndpoint) {
    
        //Deserilize JSON and Map Keys 
        Map < String, Object > newflatKeyMap = new Map < String, Object > ();
        list < string > Parentidlist = new list < String > ();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
    
        List < HttpHeaders__mdt > httpHeader = SYS_DataCacheFactory.headerSetting;
        for (HttpHeaders__mdt head: httpHeader) {
            SYS_debug.log('header is = ' + head.header_name__c + ' ' + head.Value__c);
            req.setHeader(String.valueOf(head.header_name__c), String.valueOf(head.Value__c));
        }
    
        string endpoint = baseEndpoint + 'drive/v3/files';
        system.debug('endpointNDR' + endpoint );
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        // req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(endpoint);
        string jsonRecord = '{"mimeType":"application/vnd.google-apps.folder","kind":"drive#file"}';
        String finalJSON = jsonRecord.replace('\n', ' ');
        Object convert = System.JSON.deserializeUntyped(finalJSON);
        newflatKeyMap = (SYS_Helper.getFlatKeys(finalJSON, 'A.B'));
        if (parentgoogleid != null)
            Parentidlist.add(parentgoogleid);
        ((Map < String, Object > ) convert).put('name', parentid);
        ((Map < String, Object > ) convert).put('parents', Parentidlist);
        system.debug('convert' + convert);
        string midformJSON = JSON.serialize(convert);
        finalJSON = midformJSON.replace('\n', ' ');
        system.debug('finalJSONNarendra' + finalJSON);
        req.setBody(finalJSON);
        req.setMethod('POST');
    
        HttpResponse res = h.send(req);
        string jsonRecordres = res.getBody();
        system.debug('jsonRecordres' + jsonRecordres);
        //Deserilize JSON and Map Keys 
        Map < String, Object > newflatKeyMapres = new Map < String, Object > ();
        String finalJSONres = jsonRecordres.replace('\n', ' ');
        Object convertres = System.JSON.deserializeUntyped(finalJSONres);
        String googlefolderid;
        newflatKeyMapres = (SYS_Helper.getFlatKeys(finalJSONres, 'A.B'));
        system.debug('newflatKeyMapres' + newflatKeyMapres);
        googlefolderid = (String) newflatKeyMapres.get('id');
        system.debug('googlefolderid' + googlefolderid);
    
        return googlefolderid;
    }
    @AuraEnabled
    public static void googlefilePermission(string googlefileid, string accessToken) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://www.googleapis.com/drive/v3/files/' + googlefileid + '/permissions');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        // Set the body as a JSON object
        request.setBody('{"type": "anyone","role": "reader"}');
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
        }
    
    }
    /*
    @AuraEnabled
    public static void MangergooglefilePermission(string googlefileid, string accessToken, string emailAddress) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://www.googleapis.com/drive/v3/files/' + googlefileid + '/permissions');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        // Set the body as a JSON object
        request.setBody('{"type": "user","role": "writer","emailAddress":"' + emailAddress + '"}');
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
        }
    
    }*/
    
    @AuraEnabled
     public static GoogleDriveFile__c uploadFile_g(Id parentId, String Tittle, String base64Data, String contentType) {
        Contact con = [select BrandName__c from Contact where Id =:parentId];
        system.debug('contentType' + contentType);
        string googeldrivfolderId;
        GoogleDriveFile__c Googlefile;
        string base64Datamod = 'data:' + contentType + ';base64,' + base64Data;
        SYS_OAuthConfig__c configue = [select Access_Token__c from SYS_OAuthConfig__c where name = 'GoogleDrive'];
        string accessToken = configue.Access_Token__c;
        system.debug(configue);
        //      Map<String, string> FiletypeMap = new Map<String, string>{'pdf' => 'application/pdf', 
        //  'jpg' => 'image/jpg', 'jpeg' => 'image/jpeg','png' => 'image/png'};
        GoogleDriveFolder__c googlefolderparent = [select GoogleDrive_ID__c, Id from GoogleDriveFolder__c where name = 'Municorn'
            LIMIT 1
        ];
        string googlefolderparentId = googlefolderparent.GoogleDrive_ID__c;
    
    
        list < GoogleDriveFolder__c > googlefolder = [select GoogleDrive_ID__c, Id from GoogleDriveFolder__c where Contact__c =: parentId LIMIT 1];
        if (googlefolder.size() > 0) {
            googeldrivfolderId = googlefolder[0].GoogleDrive_ID__c;
        } else {
            //googeldrivfolderId = CustomfileuploaderController.creategooglefolder(accessToken, parentId, googlefolderparentId, parentId);
        }
        system.debug('googlefolder' + googlefolder);
    
        string file = base64Data;
        string filename = Tittle;
        string tempfiletype = contentType;
        string folderid = googeldrivfolderId; //googeldrivfolderId;
        system.debug('folderid' + folderid);
        string filetype = contentType;
        system.debug(filetype);
        Integer httpstatuscode;
        if (file != null) {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
    
            String boundary = 'foo_bar_baz';
            String delimiter = '\r\n--' + boundary + '\r\n';
            String closeDelimiter = '\r\n--' + boundary + '--';
    
            //Converts a Blob to an unencoded String representing its normal form
            String encodedFile = EncodingUtil.urlDecode(file, 'UTF-8');
    
            String body = delimiter + 'Content-Type: application/json\r\n\r\n' + '{ "title":"' + fileName + '","type": "anyone","role": "reader"' +
                ', "mimeType":"' + filetype + '", "parents": [{"kind": "drive#fileLink", "id": ' +
                '"' + folderId + '"}]}' +
                delimiter + 'Content-Type: ' + filetype + '\r\n' + 'Content-Transfer-Encoding: base64\r\n' + '\r\n' +
                encodedFile + closeDelimiter;
    
            system.debug('body' + body);
            // Blob tempBlob = Blob.valueOf(body);
            //set methods into req to upload file
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('Content-length', String.valueOf(body.length())); // multipart/related; boundary=foo_bar_baz
            req.setHeader('Content-Type', 'multipart/related; boundary="' + boundary + '"');
            req.setEndpoint('https://www.googleapis.com/upload/drive/v2/files?uploadType=multipart');
            // req.setBodyAsBlob(tempBlob);
            req.setBody(body);
            req.setMethod('POST');
    
            HttpResponse res = h.send(req);
            httpstatuscode = res.getStatusCode();
            system.debug('resp' + res);
            system.debug(res.getBody());
            string jsonRecord = res.getBody();
            //Deserilize JSON and Map Keys 
            Map < String, Object > newflatKeyMap = new Map < String, Object > ();
    
            String finalJSON = jsonRecord.replace('\n', ' ');
            Object convert = System.JSON.deserializeUntyped(finalJSON);
    
            String GooglecontentId, Thumbnaillink, Downloadlink, Previewlink;
            newflatKeyMap = (SYS_Helper.getFlatKeys(finalJSON, 'A.B'));
            GooglecontentId = (String) newflatKeyMap.get('id');
            Thumbnaillink = (String) newflatKeyMap.get('thumbnailLink');
            system.debug('Thumbnaillink' + Thumbnaillink);
            Downloadlink = (String) newflatKeyMap.get('webContentLink');
            Previewlink = Downloadlink.remove('=download');
            system.debug('Downloadlink' + Downloadlink);
            system.debug('GooglecontentId' + GooglecontentId);
            if(GooglecontentId != null){
              //CustomfileuploaderController.googlefilePermission(GooglecontentId,accessToken);
                  }
                         
            if (googlefolder.size() == 0) {
                GoogleDriveFolder__c googlefolderrec = new GoogleDriveFolder__c();
                googlefolderrec.Name = Tittle;
                googlefolderrec.Contact__c = parentid;
                googlefolderrec.GoogleDrive_ID__c = googeldrivfolderId;
                googlefolderrec.Synchronous__c = true;
                system.debug('googlefolderrec' + googlefolderrec);
                upsert googlefolderrec;
            }
            if (GooglecontentId != null) {
                Googlefile = new GoogleDriveFile__c();
                Googlefile.Contact__c = parentId;
                // Googlefile.ContentVersionId__c = contetid;
                Googlefile.GoogleDrive_ID__c = GooglecontentId;
                Googlefile.Name = Tittle;
                Googlefile.BrandName__c =con.BrandName__c ;
                Googlefile.Preview_Link__c = Previewlink;
                Googlefile.ThumbnailLink__c = Thumbnaillink; 
                Googlefile.ParentFolderId__c =  googeldrivfolderId;
                Googlefile.DownloadLink__c = Downloadlink;
                Googlefile.ContentType__c = contentType;
                upsert Googlefile;
    
    
            }
    
        }
        return Googlefile;
    }
    

}