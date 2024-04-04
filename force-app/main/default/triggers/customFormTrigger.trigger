trigger customFormTrigger on Custom_Form__c (before insert, before update) {
    for(Custom_Form__c i:trigger.new){
        if(i.uuid__c == NULL) {
            i.uuid__c = SYS_Helper.getUUID();
        }
    }
}