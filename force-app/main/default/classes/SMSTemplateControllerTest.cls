@isTest
public with sharing class SMSTemplateControllerTest {
    @TestSetup
    static void makeData(){
        SMSTemplateController.upsertTemplate(null, 'templateName', 'Hello {!Contact.FirstName, Sir}  {!Contact.LastName}'+
        +' Welcome to {!Contact.Account.Name}', true);
        Contact con = new Contact( LastName='Steve Balmer');
        insert con;
    }

    @isTest
    static void getResultsTest() {
        List<SMSTemplateController.SObJectResult> result = SMSTemplateController.getResults('Converse_Template__c', 'Name', 'temp');
        System.assert(result.size()>0);
    }

    @isTest
    static void fetchTemplatetest() {
        List<Converse_Template__c> templates = [SELECT Id from Converse_Template__c LIMIT 1];
        if (templates != NULL && templates.size() > 0) {
            String recordId = templates[0].Id;
            Converse_Template__c temp = SMSTemplateController.fetchTemplate((Id)recordId);
            List<Contact> contacts = [SELECT Id FROM Contact];

            String preview = SMSTemplateController.fetchPreview(contacts[0].Id, temp.Template__c);
            System.debug(preview);
            System.assert(preview?.containsIgnoreCase('Steve'));

        }
    }
}