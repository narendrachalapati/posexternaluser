public without sharing class ImageController {
    @AuraEnabled
    public static void createSysTrackRecord(String recordId, String contentDocumentId) { 
        SYS_IntegrationLog__c errorLog = new SYS_IntegrationLog__c();
        List< SYS_Tracker__c > sysTrackerList = new List< SYS_Tracker__c >();
        List <ContentDocumentLink> updateFileList = new List <ContentDocumentLink>();

        List<SYS_Tracker__c> existingSysTracker = [SELECT Id, Name, Type__c, WhatId__c, WhoId__c FROM SYS_Tracker__c WHERE WhatId__c =: recordId  LIMIT 1];
        SYS_Tracker__c sysTracker =(!existingSysTracker.isEmpty())? existingSysTracker[0] : new SYS_Tracker__c();
        sysTracker.Type__c = 'Display Pic';
        sysTracker.WhatId__c = recordId;
        sysTracker.WhoId__c = contentDocumentId;
        //sysTracker.Valid_till__c = Now() + 865; 
        sysTrackerList.add(sysTracker);
        system.debug('sysTrackerList'+sysTrackerList);
        //Obtains all Related/Relevant Files for Selected Record
        List <ContentDocumentLink> relatedFiles = [SELECT ContentDocumentId, LinkedEntityId, ShareType, Visibility 
                                                    FROM ContentDocumentLink 
                                                    WHERE LinkedEntityId = :recordId AND Visibility != 'AllUsers']; 

        for  (Integer i = 0; i < relatedFiles.size(); i++) {
            if (relatedFiles[i].ContentDocumentId == contentDocumentId) {
                relatedFiles[i].Visibility = 'AllUsers';
                updateFileList.add(relatedFiles[i]);
            }
        } 

        try {
            upsert sysTracker;
            System.debug('SYS_Tracker Record Created Successfully: ' + sysTracker.Id);
            if (updateFileList.size() > 0) {
                update updateFileList;
            }
            
        } catch (Exception e) {
            System.debug('Error in Storing SYS_Tracker: ' + e.getMessage());
            //Generate a Log record
            errorLog.data0__c = 'Exception Type: ' + e.getTypeName() + ' Exception Message: ' + e.getMessage();
            errorLog.Status__c = 'ERROR';
            errorLog.How_To_Process__c = 'ignore_log';
        }
        if (errorLog != new SYS_IntegrationLog__c()) {
            insert errorLog;
        }

       // return sysTracker.Id;
    }
    
    @AuraEnabled
    public static String getSysTrackRecordDocumentId(String recordId) { 
        //SYS_Tracker__c sysTracker = Database.query('SELECT '+ SYS_Helper.getAllFieldsFor('SYS_Tracker__c') + '  WHERE WhatId__c =' + '\'' + recordId+'\'' + ' LIMIT 1 ' + '\')');
        List<SYS_Tracker__c> sysTrackerList = [SELECT Id, Name, Type__c, WhatId__c, WhoId__c FROM SYS_Tracker__c WHERE WhatId__c =: recordId AND (Type__c = 'Display Pic')];
        SYS_Tracker__c sysTracker = ( sysTrackerList.size()>0) ? sysTrackerList[0] : new SYS_Tracker__c() ;
        return sysTracker.WhoId__c;
    }

    @AuraEnabled
    public static String getSysTrackRecordPictureURL(String recordId) { 
        String pictureURL;
        SYS_Tracker__c sysTracker = new SYS_Tracker__c();
        ContentVersion cvRecord = new ContentVersion();
        List<SYS_Tracker__c> sysTrackerList = [SELECT Id, Name, Type__c, WhatId__c, WhoId__c FROM SYS_Tracker__c WHERE WhatId__c =: recordId AND (Type__c = 'Display Pic') ];
        sysTracker = ( sysTrackerList.size()>0) ? sysTrackerList[0] : new SYS_Tracker__c() ;
        System.debug('( sysTracker!=NULL )' + ( sysTracker!=NULL ));
        System.debug('sysTracker ' + sysTracker);
        if( sysTracker != NULL ){
            try{
                cvRecord = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =:sysTracker.WhoId__c LIMIT 1];
            } catch(Exception e){
                cvRecord =new ContentVersion();
            }
            System.debug('( sysTracker.WhoId__c !=NULL )' + ( sysTracker.WhoId__c !=NULL ));
            System.debug('cvRecord ' + cvRecord);
            if(cvRecord.Id !=NULL){
                pictureURL='/sfc/servlet.shepherd/version/download/' + cvRecord.Id;
            } else{
                pictureURL = 'noimage';
            }
            System.debug('pictureURL ' + pictureURL);
            
        } else {
            pictureURL = 'noimage';
        }    

        return ( String.IsNotBlank(pictureURL) )? pictureURL : 'noimage';
    }
    @AuraEnabled
    public static String getShortendImageName(String nameToShortend){
        List<String> nameArray = nameToShortend.split(' ');
        String newNameShortend = '';
        for (String word : nameArray)
        {
            if(String.isNotBlank(word)){
                newNameShortend += word.substring(0,1).toUpperCase();
            }
        }
        if(String.isBlank(newNameShortend)){
            newNameShortend = 'NONAME';
        } else if(newNameShortend.length()>1){
            newNameShortend = newNameShortend.substring(0,2);
        } else if(newNameShortend.length()>2){
            newNameShortend = newNameShortend.substring(0,3);
        } else if(newNameShortend.length()>3){
            newNameShortend = newNameShortend.substring(0,4);
        } else{
            newNameShortend = newNameShortend;
        }
        System.debug('Original Name:- ' + nameToShortend + ' Short Name:- ' + newNameShortend);
        return newNameShortend;
    }
 
    public static Map < Id, String > loadAllRecordImagesMap() {
        String pictureURL, newPictureURL;
        Map < Id, String > map_RecordsDisplayPic = new Map < Id, String > ();
        Map < Id, String > map_ContentVersions = new Map < Id, String > ();
        Map < String, SYS_Tracker__c > map_SysTrackersDisplayPic = new Map < String, SYS_Tracker__c > ();
    
        // Iterate ContentVersion records and associate image URL
        for (ContentVersion cvRecord: [SELECT Id, ContentDocumentId FROM ContentVersion]) {
            if (cvRecord.Id != NULL) {
                pictureURL = '/sfc/servlet.shepherd/version/download/' + cvRecord.Id;
            } else {
                pictureURL = 'noimage';
            }
            map_ContentVersions.put(cvRecord.Id, pictureURL);
        }
        //Iterate SYS_Tracker__c records and Map with Record Display Picture URL        
        for (SYS_Tracker__c sysTrackerRecord: [SELECT Id, Name, Type__c, WhatId__c, WhoId__c FROM SYS_Tracker__c WHERE(Type__c = 'Display Pic')]) {
            if (map_ContentVersions.containsKey(sysTrackerRecord.WhoId__c)) {
                newPictureURL = map_ContentVersions.get(sysTrackerRecord.WhoId__c);
            } else {
                newPictureURL = 'noimage';
            }
            newPictureURL = (String.IsNotBlank(newPictureURL)) ? newPictureURL : 'noimage';
    
            map_RecordsDisplayPic.put(sysTrackerRecord.WhatId__c, newPictureURL);
        }
        return map_RecordsDisplayPic;
    }

    public static Map<Id, WhattIdSysTrackerWrapper> getWhattIdBasedSystrackerWrapper(List<Id> WhattIdsList) {
        Map<Id, WhattIdSysTrackerWrapper> WhattIdSysTrackerMap = new Map<Id, WhattIdSysTrackerWrapper>();
        List<SYS_Tracker__c> SystrackersList = [SELECT Id, WhatId__c, WhoId__c FROM SYS_Tracker__c
         WHERE WhatId__c IN: WhattIdsList AND (Type__c = 'Activity SMS' OR Type__c = 'Activity Call') LIMIT 50000];
        System.debug('SystrackersList ' + SystrackersList);      

        Map<Id, String> WhattIdRecordImagesMap = loadWhattIdRecordImagesMap(WhattIdsList);

        for(Id whattId :WhattIdsList){
            for(SYS_Tracker__c sysTrackRecord :SystrackersList){
                //Check if whattid matches and add record to map value
                if(sysTrackRecord.WhatId__c == whattId){
                    if(WhattIdSysTrackerMap.containsKey(whattId)){
                        WhattIdSysTrackerWrapper tempWhattIdSystrackWrapper = WhattIdSysTrackerMap.get(whattId);
                        List<SYS_Tracker__c> tempSysTrackerList = tempWhattIdSystrackWrapper.sysTrackerList;
                        tempSysTrackerList.add(sysTrackRecord);                        
                        tempWhattIdSystrackWrapper.sysTrackerList = tempSysTrackerList;
                        WhattIdSysTrackerMap.put(whattId, tempWhattIdSystrackWrapper);
                    }else{
                        List<SYS_Tracker__c> tmpSysTrackerList = new List<SYS_Tracker__c>();
                        tmpSysTrackerList.add(sysTrackRecord);
                        WhattIdSysTrackerWrapper whattIdSystrackWrapper = new WhattIdSysTrackerWrapper();
                        whattIdSystrackWrapper.sysTrackerList = tmpSysTrackerList;
                        whattIdSystrackWrapper.displayPictureURL = WhattIdRecordImagesMap.get(whattId);
                        WhattIdSysTrackerMap.put(whattId, whattIdSystrackWrapper);
                    }
                }
            }
        }

        for(Id whattId :WhattIdsList){
            if(!WhattIdSysTrackerMap.containsKey(whattId)){
                List<SYS_Tracker__c> tmpSysTrackerList = new List<SYS_Tracker__c>();
                WhattIdSysTrackerWrapper whattIdSystrackWrapper = new WhattIdSysTrackerWrapper();
                whattIdSystrackWrapper.sysTrackerList = tmpSysTrackerList;
                whattIdSystrackWrapper.displayPictureURL = WhattIdRecordImagesMap.get(whattId);
                WhattIdSysTrackerMap.put(whattId, whattIdSystrackWrapper);
            }
        }
        System.debug('WhattIdSysTrackerMap ' + WhattIdSysTrackerMap);
        return WhattIdSysTrackerMap;
    }

    // Get WhattId based Picture URL
    public static Map<Id, String> loadWhattIdRecordImagesMap(List<Id> whattIdList) {
        List<Id> whoIdList = new List<Id>();
        Map <Id, Id> whoIdWhattIdMap = new Map <Id, Id> ();
        Map <Id, String> whattIdDisplayPicMap = new Map <Id, String> ();        

        //Iterate SYS_Tracker__c records and Map with Record Display Picture URL  
        for (SYS_Tracker__c sysTrackerRecord: [SELECT Id, Name, Type__c, WhatId__c, WhoId__c FROM SYS_Tracker__c WHERE
         WhatId__c IN :whattIdList AND (Type__c = 'Display Pic') LIMIT 50000]) {
            whoIdList.add(sysTrackerRecord.WhoId__c);
            whoIdWhattIdMap.put(sysTrackerRecord.WhoId__c, sysTrackerRecord.WhatId__c);
        }

        List<ContentVersion> cvRecordsList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :whoIdList LIMIT 50000];
         // Iterate ContentVersion records and associate image URL
         for (ContentVersion cvRecord: cvRecordsList) {
            String tempPictureURL = '/sfc/servlet.shepherd/version/download/' + cvRecord.Id;
            Id cvWhattId = whoIdWhattIdMap.get(cvRecord.ContentDocumentId);
            whattIdDisplayPicMap.put(cvWhattId, tempPictureURL);
        }
        for(Id whattId: whattIdList){
            if(!whattIdDisplayPicMap.containsKey(whattId)){
                String tempnoPicture = 'noimage';
                whattIdDisplayPicMap.put(whattId, tempnoPicture);
            }           
        }
        return whattIdDisplayPicMap;

    }

    //Wrapper to Fetch List of Ids and WhoIds based on Systracker List
    public class WhattIdSysTrackerWrapper {
        @AuraEnabled
        public List<SYS_Tracker__c> sysTrackerList = new List<SYS_Tracker__c>();

        @AuraEnabled
        public String displayPictureURL;

        @AuraEnabled
        public List<Id> sysTrackerIdsList {
            get {
                List<Id> tempSysTrackerIdsList = new List < Id > ();
                if (sysTrackerList != null) {
                    for (SYS_Tracker__c systrackRec: sysTrackerList) {
                        tempSysTrackerIdsList.add(systrackRec.Id);
                    }
                    return tempSysTrackerIdsList;
                } else {
                    return tempSysTrackerIdsList;
                }
            }
        }

        @AuraEnabled
        public Set<Id> sysTrackerWhoIdsList {
            get {
                Set<Id> tempSysTrackerWhoIdsList = new Set<Id> ();
                if (sysTrackerList != null) {
                    for (SYS_Tracker__c systrackRec: sysTrackerList) {
                        tempSysTrackerWhoIdsList.add(systrackRec.WhoId__c);
                    }
                    return tempSysTrackerWhoIdsList;
                } else {
                    return tempSysTrackerWhoIdsList;
                }
            }
        }

    }
    
}