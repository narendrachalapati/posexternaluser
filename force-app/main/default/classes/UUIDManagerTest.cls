@isTest
public with sharing class UUIDManagerTest {
    @isTest
    static void UUIDManagerTest() {
        Account acc = new Account(Name = 'Sample Account');
        insert acc;

        UUIDManager.createUUIDFor(new List<Id> {acc.Id});
        UUIDManager.createUUIDFor(acc.Id);
    }
}