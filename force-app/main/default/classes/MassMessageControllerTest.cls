@isTest
public with sharing class MassMessageControllerTest {
    @isTest
    static void MassMessageController_Test() {
        Account acc = new Account(Name = 'Sample Account');
        insert acc;
        List<ListView> listviews = MassMessageController.getListviewFilters('Account');
        try {
            MassMessageController.gettinglistviewfilteredRecords(listviews[0].Id, 'Account');
        } catch (Exception e) {

        }
        try {
            MassMessageController.saveChunk(new List<Id> {acc.Id}, 'Sample', 'SGVsbG8=', '', '');
        } catch (Exception e) {

        }
        try {
            MassMessageController.saveChunk(new List<Id> {acc.Id}, 'Sample', 'SGVsbG8=', '', '');
        } catch (Exception e) {

        }
        try {
            MassMessageController.createActivity('Sample message', 'Sample message', new List<Id> {acc.Id}, 'Account', '9364756826',
            '', '');
        } catch (Exception e) {

        }
    }
}