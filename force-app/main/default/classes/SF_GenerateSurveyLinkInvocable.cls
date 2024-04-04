public without sharing class SF_GenerateSurveyLinkInvocable {
    

    public class VariableBucket {
        @InvocableVariable(label='Contact Id' description= 'Fill either contact or account or lead Id.' required=false)  
        public Id contactId;
    
        @InvocableVariable(label='Account Id' description= 'Fill either contact or account or lead Id.' required=false)  
        public Id accountId;

        @InvocableVariable(label='Lead Id' description= 'Fill either contact or account or lead Id.' required=false)  
        public Id leadId;

        @InvocableVariable(label='Survey Id' description= 'Fill the survey Id need to be used.' required=true)  
        public Id surveyId;
    }

    @InvocableMethod(label='Capture Request for Outbound' description='To capture outbound request and create a SYS_IntegrationLog record for Municorn')
    public static List<Custom_Form__c> generateSurveyLink(List<VariableBucket> requestList) {
        List<Custom_Form__c> formList = new List<Custom_Form__c>();

        if(requestList.size() == 0) return formList;
        try {
            
            for(VariableBucket item: requestList) {
                Custom_Form__c form = new Custom_Form__c();
                form.uuid__c = SYS_Helper.getUUID();
                form.Account__c = item.accountId;
                form.Contact__c = item.contactId;
                form.Lead__c = item.leadId;
                form.Survey__c = item.surveyId;
    
                formList.add(form);
            }
    
            insert formList;
        } catch(Exception e) {
            throw new SF_GenerateSurveyLinkInvocableException('Error occured while creating custom survey form \n'+ e.getMessage());
        }
        return formList;
        
    }


    public class SF_GenerateSurveyLinkInvocableException extends Exception{}
}