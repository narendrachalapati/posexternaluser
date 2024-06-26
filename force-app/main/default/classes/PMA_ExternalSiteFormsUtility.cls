public without sharing class PMA_ExternalSiteFormsUtility {
    public static  TimeZone tz = UserInfo.getTimeZone();
    public static  DateTime dt = Datetime.now();
    
    public static String formatPhone(String Phone) {
        if(!String.isBlank(Phone)) {
            string nondigits = '[^0-9]';
            string PhoneDigits;
            
            // remove all non numeric
            PhoneDigits = Phone.replaceAll(nondigits,'');
            
            // 10 digit: reformat with dashes
            if (PhoneDigits.length() == 10) {
                if ( (PhoneDigits.substring(0,1) != '1') ){
                	return '1'+PhoneDigits.substring(0,10);
                }else{
                    return PhoneDigits.substring(0,10);
                }
            }
            // 11 digit: if starts with 1, format as 10 digit 
            if (PhoneDigits.length() == 11 && PhoneDigits.substring(0,1) == '1') {          
                return  PhoneDigits.substring(0,11);
            }
        }
        
        return( Phone );
    }
    
    public static String getOrgUrl() {
        return Url.getOrgDomainUrl().toExternalForm();
    }
    /*
    @AuraEnabled
    Public static void updateGuestForm(Contact contactform,String parentId,string attachId){
        System.debug('contactform: '+contactform+' parentId: '+parentId);
        if(contactform.First_submitted_date__c ==  null){
            contactform.First_submitted_date__c =  dt.addSeconds((tz.getOffset(dt)/1000));
        }
        contactform.Last_submitted_date__c = dt.addSeconds((tz.getOffset(dt)/1000));
        if(contactform.Number_of_submissions__c == null){
            contactform.Number_of_submissions__c = 1;
        }else{
            contactform.Number_of_submissions__c = contactform.Number_of_submissions__c + 1;
        }
        contactform.Parent__c = parentId;
        contactform.Status__c = constants.SUBMITTED;
        try{
            update contactform;
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    */
    public static List<Sobject> getRecord(Id rId) {
        
        String sObjName = Rid.getSObjectType().getDescribe().getName();
        String query='';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sObjName).getDescribe().fields.getMap();
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
        query = 'select ' + commaSepratedFields + ' from ' + sObjName;
        query += ' WHERE Id = \''+rId+'\'';
        System.debug('******soqlQuery*********'+query );
        list<Sobject> olist =  new list<Sobject>();
        olist = database.query(query);
        System.debug(olist);
        return olist;
    }

    
}