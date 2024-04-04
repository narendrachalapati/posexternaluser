public with sharing class LookupController {
    public LookupController() {

    }

    public class ResultWrapper{
        @AuraEnabled public String optionName{get;set;}
        @AuraEnabled public String optionMeta{get;set;}
        @AuraEnabled public String uuid {
            get {
                return UUIDHelper.getUUID();
            }
        }
        @AuraEnabled public sObject record{get;set;}
    }

    @AuraEnabled( cacheable = true )
    public static List<ResultWrapper> getSearchResult(String sObjectApiName, String searchKey) {
        List<ResultWrapper> searchResults = new List<ResultWrapper>();
        try {
            String query = 'SELECT ' + UUIDHelper.getAllFieldsFor(sObjectApiName) + 
            ' FROM ' + sObjectApiName;
            String whereClause = '';
            String limits = ' LIMIT 15';
            if (String.isNotBlank(searchKey)) {
                whereClause = ' WHERE Name LIKE ' + '\'' + String.escapeSingleQuotes(searchKey.trim()) + '%\'';
            }
            System.debug('QUERY '+ whereClause + limits);
            for (sObject record: Database.query(query + whereClause + limits)) {
                ResultWrapper wrapper = new ResultWrapper();
                wrapper.optionName = (String)record.get('Name');
                wrapper.optionMeta = '';
                wrapper.record = record;
                searchResults.add(wrapper);
            }
            System.debug('searchResults '+searchResults);
            
        } catch (Exception e) {
            System.debug('ERROR ' + e.getMessage() + e.getStackTraceString());
            throw new AuraHandledException('Some error occured. Please contact your admin.');
        }
        return searchResults;
    }

    @AuraEnabled( cacheable = true )
    public static ResultWrapper fetchDefaultRecord(Id recordId) {
        ResultWrapper defaultValue = new ResultWrapper();
        try {
            String sObjectApiName = UUIDHelper.getObjectApiName(recordId);
            String query = 'SELECT ' + UUIDHelper.getAllFieldsFor(sObjectApiName) + 
            ' FROM ' + sObjectApiName;
            String whereClause = ' WHERE Id =:recordId';
            String limits = ' LIMIT 1';
            List<sObject> record = Database.query(query + whereClause + limits);
            if (record != NULL && record.size() > 0) {
                defaultValue.optionName = (String)record[0].get('Name');
                defaultValue.optionMeta = '';
                defaultValue.record = record[0];
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return defaultValue;
    }
}