trigger ActivityTrigger on Activity__c(before insert, after insert, before update, after update, after delete, after undelete) {

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            ActivityTriggerHandler.handleBeforeInsert();
        }
        when AFTER_INSERT {
            ActivityTriggerHandler.handleAfterInsert();
        }
        when Before_UPDATE {
            ActivityTriggerHandler.handleBeforeUpdate();
        }
        when AFTER_UPDATE {
            ActivityTriggerHandler.handleAfterUpdate();
        }
        when BEFORE_DELETE {
            ActivityTriggerHandler.handleBeforeDelete();
        }
        when AFTER_DELETE {
            ActivityTriggerHandler.handleAfterDelete();
        }
        when AFTER_UNDELETE {
            ActivityTriggerHandler.handleAfterUnDelete();
        }
    }

}