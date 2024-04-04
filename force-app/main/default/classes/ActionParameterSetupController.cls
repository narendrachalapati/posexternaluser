public with sharing class ActionParameterSetupController {
    public ActionParameterSetupController() {

    }

    @AuraEnabled
    public static void sample(String recordId, String objectWrapper) {
        try {
            System.debug(recordId + objectWrapper);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateActionParameterSite(String recordId, String objectWrapper) {
        try {
            System.debug(recordId + objectWrapper);
            Map<String, Object> siteInfo = ((Map<String, Object>)JSON.deserializeUntyped(objectWrapper));
            String siteId = (String)siteInfo.get('Id');
            SiteDetail mySiteDetail = [SELECT SecureURL FROM SiteDetail WHERE DurableId = :siteId];
            
            Action_Parameter__c parameter = new Action_Parameter__c(Id = recordId);
            parameter.Site__c = siteId;
            parameter.Site_Name__c = (String)siteInfo.get('Name');
            parameter.Site_URL__c = mySiteDetail.SecureURL;

            update parameter;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateActionParameterPage(String recordId, String objectWrapper) {
        try {
            Map<String, Object> pageInfo = ((Map<String, Object>)JSON.deserializeUntyped(objectWrapper));

            Action_Parameter__c parameter = new Action_Parameter__c(Id = recordId);
            parameter.VisualForce_Page__c = (String)pageInfo.get('Name');
            parameter.VisualForce_Page_Id__c = (String)pageInfo.get('Id');
            update parameter;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}