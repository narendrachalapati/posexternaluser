trigger locationTagTrigger on LocationTags__c (before insert, before update) {
    for(LocationTags__c i:trigger.new){
        if(i.uuid__c == NULL) {
            i.uuid__c = SYS_Helper.getUUID();
        }
    }
}