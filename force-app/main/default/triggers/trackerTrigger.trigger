trigger trackerTrigger on UUID_Tracker__c (before insert, before update) {
    for(UUID_Tracker__c i:trigger.new){
        if(i.uuid__c == NULL) {
            i.uuid__c = UUIDHelper.getUUID();
        }
    }
}