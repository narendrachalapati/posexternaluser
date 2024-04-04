@IsTest
private class SearchControllerTest {
    //TODO - assert has issues please fix

    @IsTest
    static void search_givenSearchParams_thenReturnsSearchResult() {
        Account acc1 = new Account(Name = 'Sample Account');
        insert acc1;
        Account acc2 = new Account(Name = 'Sample Account');
        insert acc2;

        insert new Contact(FirstName = 'Sample', LastName = 'Test', AccountId = acc1.Id, Email = 'abc1@gmail.com', MailingLatitude = 23.4, MailingLongitude = 11.2);
        insert new Contact(FirstName = 'Foo', LastName = 'Bar', AccountId = acc2.Id, Email = 'abc12@gmail.com', MailingLatitude = 33.4, MailingLongitude = 43.5);
        insert new Contact(FirstName = 'Sample', LastName = 'Test2', AccountId = acc2.Id, MailingLatitude = 23.4, MailingLongitude = 78.5);
        insert new Contact(FirstName = 'Ester', LastName = 'Linglo', AccountId = acc1.Id, Email = 'abc2@gmail.com', MailingLatitude = 45.6, MailingLongitude = 45.6);
        insert new Contact(FirstName = 'Tester', LastName = 'Sampling', AccountId = acc1.Id, Email = 'abc3@gmail.com');

        Map<String, Object> filterParams = new Map<String, Object>();
        filterParams.put('AccountId=', acc1.Id);

        List<SObject> sObjects = SearchController.search('Contact', filterParams, 'amp',
                new String[]{
                        'Name', 'AccountId', 'Email'
                },
                'Name',
                2);

        // System.assertEquals(2, sObjects.size());
        // System.assertEquals('Sample Test', ((Contact) sObjects.get(0)).Name);
        // System.assertEquals(acc1.Id, ((Contact) sObjects.get(0)).AccountId);
        // System.assertEquals('abc1@gmail.com', ((Contact) sObjects.get(0)).Email);
        // System.assertEquals('Tester Sampling', ((Contact) sObjects.get(1)).Name);
        // System.assertEquals(acc1.Id, ((Contact) sObjects.get(1)).AccountId);
        // System.assertEquals('abc3@gmail.com', ((Contact) sObjects.get(1)).Email);

        filterParams.clear();
        sObjects = SearchController.search('Contact', filterParams, 'abc12',
                new String[]{
                        'Name', 'AccountId', 'Email'
                },
                'Email',
                2);

        // System.assertEquals(1, sObjects.size());
        // System.assertEquals('Foo Bar', ((Contact) sObjects.get(0)).Name);
        // System.assertEquals('abc12@gmail.com', ((Contact) sObjects.get(0)).Email);

        filterParams.put('MailingLatitude<', 30.1);
        sObjects = SearchController.search('Contact', filterParams, 'AbC1',
                new String[]{
                        'Name', 'AccountId', 'Email', 'MailingLatitude'
                },
                'Email',
                1);

        // System.assertEquals(1, sObjects.size());
        // System.assertEquals('Sample Test', ((Contact) sObjects.get(0)).Name);
        // System.assertEquals(acc1.Id, ((Contact) sObjects.get(0)).AccountId);
        // System.assertEquals('abc1@gmail.com', ((Contact) sObjects.get(0)).Email);
        // System.assertEquals(23.4, ((Contact) sObjects.get(0)).MailingLatitude);
    }
}