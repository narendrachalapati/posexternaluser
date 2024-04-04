global class PMA_PhoneNumberTrimInvocableHandler {
    global class flowInputRecords {

        @InvocableVariable(label='Current Contact Id' required=true)
        global String currentRecordId;

        @InvocableVariable(label='Current Phone Number' required=true)
        global String currentPhone;

        @InvocableVariable(label='Phone Number FieldApi Name' description='Ex:- Phone_number__c' required=true)
        global String phoneFieldApiName;

    } 
    @InvocableMethod(label='Trim Phone Numbers' description='Trim all Contact Phone Numbers')
    global static List<Contact> getTrimmedPhoneNumber(List<flowInputRecords> listInvocableVariable) {
        List<Contact> newList = new List<Contact>();
        for(flowInputRecords itr:listInvocableVariable){
            String newCurrentphone =itr.currentPhone;
            newCurrentphone = newCurrentphone.replaceAll('[^a-zA-Z0-9\\s+]', '');
            Contact newsObject = new Contact();
            newsObject.put( 'Id', itr.currentRecordId);
            newsObject.put( itr.phoneFieldApiName, newCurrentphone);
            newList.add(newsObject);
        }
        return newList;
    }
}