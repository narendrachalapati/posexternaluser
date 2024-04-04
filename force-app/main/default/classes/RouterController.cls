public without sharing class RouterController {
    public String uuid { get; set; }
    public String error { get; set; }
    public String redirectUrl { get; set; }

    public RouterController() {

    }

    public class RouterControllerException extends Exception {}

    public PageReference routerInit() {
        PageReference returnURL;
        try {
            this.uuid = System.currentPageReference().getParameters().get('uuid');
            System.debug('uuid value '+this.uuid);
            UUID_Tracker__c tracker = getTrackerrecord(this.uuid);

            String vfpage = tracker.Action_Parameter__r.VisualForce_Page__c;
            System.debug('vfpage '+vfpage);
            returnURL = redirectUrl(vfpage, this.uuid);

            tracker.No_Of_Clicks__c += 1;
            update tracker;

        } catch (Exception e) {
            System.debug(e.getMessage()+'\n'+e.getStackTraceString());
        }
        return returnURL;
    }

    public PageReference redirectUrl(String vfpage, String uuid) {
        PageReference pageRef = new PageReference(Site.getBaseSecureUrl()+'/apex/'+vfpage);
        pageRef.getParameters().put('uuid',uuid);
        pageRef.setRedirect(true);

        // return new PageReference('http://www.google.com');
        return pageRef;
    }

    public UUID_Tracker__c getTrackerRecord(String value) {
        UUID_Tracker__c tracker;
        try {
            String query = 'SELECT ' + + UUIDHelper.getAllFieldsFor('UUID_Tracker__c') + 
                +', '+ UUIDHelper.getAllParentFields('Action_Parameter__r.', 'Action_Parameter__c') +
                ' FROM UUID_Tracker__c WHERE UUID__c = :value LIMIT 1';
            tracker = Database.query(query);

        } catch ( Exception e ) {
            throw new RouterControllerException(e.getMessage()+'\n'+e.getStackTraceString());
        }
        return tracker;
    }
}