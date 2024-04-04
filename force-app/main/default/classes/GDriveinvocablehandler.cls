global without sharing class GDriveinvocablehandler {
    global class MyInvocableVariable {
        @InvocableVariable(label = 'WhatId'
            required = true)
        global Id whatId;
        @InvocableVariable(label = 'Gdrivefolderid'
            required = true)
        global string Gfolderid;
    }

    @InvocableMethod(label = 'Gdrive Ids update'
        description = 'Ued for updating the Gdrive ids to respective object records')

    //this method returns a List of Lists of Opps to the flow and receives a List of Ids
    global static void UpdateGdriveIds(List < MyInvocableVariable > myInvocableVariableList) {
        Id RecordId = myInvocableVariableList[0].whatId;
        string GoogleDriveFolderId = myInvocableVariableList[0].Gfolderid;
        String sObjName = RecordId.getSObjectType().getDescribe().getName();
        String fetchRecordQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor(sObjName) +
            ' FROM    ' + sObjName + '  WHERE Id =:RecordId';
        List < Sobject > fetchRecord = Database.query(fetchRecordQuery);
        String name_of_object = sObjName;
        sObject obj = Schema.getGlobalDescribe().get(name_of_object).newSObject();
        obj.put('GoogleDriveFolderId__c', GoogleDriveFolderId);
        obj.put('GDriveSync__c', True);
        obj.put('Id', RecordId);
        update obj;
        system.debug('objNDR' + obj);
        //  List<List<Opportunity>> itemListList = new List<List<Opportunity>>();
        //add the list opps to the list of lists
        // itemListList.add(opps);
        // send list of lists to the Flow	
        //        return itemListList;        
    }
}