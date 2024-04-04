public with sharing class MapProductWithGoogleCalendar {

    @AuraEnabled
    public static Product__c getProductDetails(Id productRecordId) {
        Product__c prodRecord = new Product__c();
        try {
            String fetchSchedulingProductQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Product__c') +
            ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
            ' FROM Product__c WHERE Id =: productRecordId';
            List<Product__c> fetchSchedulingProductDetails = Database.query(fetchSchedulingProductQuery);
            prodRecord = (fetchSchedulingProductDetails.size() > 0) ? fetchSchedulingProductDetails[0] : new Product__c();
            return prodRecord;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static List<Google_Calendar__c> ListofCalendars(Boolean isAccountBasedMapper, String accountRecordId) {
        String filterAccount = '';
        if(isAccountBasedMapper && String.isNotBlank(accountRecordId)){
            filterAccount = ' AND Account__c =: accountRecordId';
        }
        String fetchgoogleCalendarListQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Google_Calendar__c') +
            ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
            ', ' + SYS_Helper.getAllParentFields('PMA_Product__r.', 'Product__c') +
            ' FROM Google_Calendar__c WHERE Google_Calendar_Id__c != NULL' + filterAccount;
        List<Google_Calendar__c> googleCalendarList = Database.query(fetchgoogleCalendarListQuery);
        return googleCalendarList;
    }

    @AuraEnabled
    public static Product__c updateProductWithCalendarKey( String calendarType, String productId, String calendarSysKey, String calendarId ) {
        try {
            Product__c updateProductRecord = new Product__c();
            updateProductRecord.Id = productId;
            if(calendarType == 'Shift'){
                updateProductRecord.Google_Shift_Calendar_Id__c = calendarSysKey;
                update updateProductRecord;
            }
            if(calendarType == 'Booking'){
                updateProductRecord.Google_Booking_Calendar_Id__c = calendarSysKey;
                update updateProductRecord;
            }           
            Product__c fetchProductRecord = getProductDetails(productId);
            return fetchProductRecord;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static Google_Calendar__c createCustomCalendar(Boolean isAccountBasedMapper, String accountRecordId, String calendarName, String productId, String calendarType, String configTimeZone){
        try {
            Google_Calendar__c googleCalendarRecord = new Google_Calendar__c();
            googleCalendarRecord.Calendar_Name__c = calendarName;
            googleCalendarRecord.PMA_Product__c = productId;
            googleCalendarRecord.Calendar_Type__c = calendarType;
            googleCalendarRecord.TimeZone__c = configTimeZone;
            // googleCalendarRecord.Active__c = false;
            if(isAccountBasedMapper && String.isNotBlank(accountRecordId)){
                googleCalendarRecord.Account__c = accountRecordId;
            }
            insert googleCalendarRecord;
            return googleCalendarRecord;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }  
}