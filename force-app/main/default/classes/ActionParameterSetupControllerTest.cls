@isTest
public with sharing class ActionParameterSetupControllerTest {
    @isTest
    static void ActionParameterSetupControllerTest() {
        Action_Parameter__c ap = new Action_Parameter__c();
        ap.Name = 'Sample parameter';
        insert ap;

        String objectWrapper = '{"Name":"FormVf","Id" : "skdhshd-eitruitu-cnvfnn"}';
        ActionParameterSetupController.sample(ap.Id, objectWrapper);
        try {
            ActionParameterSetupController.updateActionParameterSite(ap.Id, objectWrapper);
        } catch (Exception e) {

        }
        try {
            ActionParameterSetupController.updateActionParameterPage(ap.Id, objectWrapper);
        } catch (Exception e) {

        }
    }
}