public with sharing class SearchController {

    @AuraEnabled(Cacheable = true)
    public static List<SObject> search(
            String objectType,
            Map<String, Object> filterParams,
            String searchText,
            String[] selectFields,
            String searchOnField,
            Integer numRecords) {
        String limitClause = numRecords == null || numRecords <= 0 ? ' LIMIT 20' : ' LIMIT ' + numRecords;

        String whereClause = '';
        for (String filter : filterParams.keySet()) {
            whereClause += '(' + filter + getQueryParamValue(filterParams.get(filter)) + ') AND ';
        }
        whereClause += searchOnField + ' LIKE \'%' + searchText.toLowerCase() + '%\'';

        String query = 'SELECT ' + String.join(selectFields, ',') + ' FROM ' + objectType +
                ' WHERE ' + whereClause + ' ORDER BY ' + searchOnField + ' ' + limitClause;
        System.debug('Search query=' + query);

        return Database.query(query);
    }

    private static String getQueryParamValue(Object paramValue) {
        if (paramValue instanceof Integer ||
                paramValue instanceof Long ||
                paramValue instanceof Double ||
                paramValue instanceof Decimal) {
            return String.valueOf(paramValue);
        }
        return '\'' + paramValue + '\'';
    }
}