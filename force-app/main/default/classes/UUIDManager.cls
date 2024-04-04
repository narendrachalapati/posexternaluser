//without sharing for guest user access in sites.
public without sharing class UUIDManager {
    public UUIDManager() {

    }

    public class UUIDManagerException extends Exception {}

    public static void triggerHandler() {
        try {
            if (Trigger.isBefore || Trigger.isDelete)
            return;
        
            List<Id> recordIds = new List<Id>(Trigger.newMap.keySet());

            for(UUID_Tracker__c tracker : [SELECT Id, WhatId__c 
            FROM UUID_Tracker__c WHERE WhatId__c in :recordIds]) {
                Integer index = recordIds.indexOf(tracker.WhatId__c);
                if (index >= 0) {
                    recordIds.remove(index);
                }
            }
            if (recordIds.size() > 0)
                createUUIDFor(recordIds);
        } catch (Exception e) {
            System.debug(e.getMessage() + '\n' + e.getStackTraceString());
            throw new UUIDManagerException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public static void createUUIDFor(List<Id> recordIds) {
        try {
            String sObjectApiName =  UUIDHelper.getObjectApiName(recordIds[0]);
            List<UUID_Tracker__c> trackers = new List<UUID_Tracker__c>();
            for(Id recordId : recordIds) {
                UUID_Tracker__c tracker = new UUID_Tracker__c();
                tracker.WhatId__c = recordId;
                trackers.add(tracker);
            }
            insert trackers;
        } catch(Exception e) {
            System.debug(e.getMessage() + '\n' + e.getStackTraceString());
            throw new UUIDManagerException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public static void createUUIDFor(Id recordId) {
        try {
            createUUIDFor(new List<Id>{recordId});
        } catch(Exception e) {
            System.debug(e.getMessage() + '\n' + e.getStackTraceString());
            throw new UUIDManagerException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    public static SObject getSObjectFromUUID(String uuid) {
        SObject record;
        try {
            List<UUID_Tracker__c> tracker = [SELECT Id, WhatId__c 
            FROM UUID_Tracker__c WHERE UUID__c =:uuid LIMIT 1];

            if (tracker.size() > 0) {
                String recordId = tracker[0].WhatId__c;
                String sObjectApiName =  UUIDHelper.getObjectApiName(recordId);
                String query = 'SELECT ' + UUIDHelper.getAllFieldsFor(sObjectApiName) + 
                ' FROM ' + sObjectApiName ;
                String whereClause = ' WHERE Id =: recordId';

                List<SObject> records = Database.query(query + whereClause);

                if (records.size() > 0) {
                    record = records[0];
                }
            } else {
                throw new UUIDManagerException('UUID Tracker not found uuid '+uuid);
            }
        } catch(Exception e) {
            System.debug(e.getMessage() + '\n' + e.getStackTraceString());
            throw new UUIDManagerException(e.getMessage() + '\n' + e.getStackTraceString());
        }
        return record;
    }
}