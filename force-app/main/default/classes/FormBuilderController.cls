public virtual with sharing class FormBuilderController {
    public String domainUrl {get; set;}
    public String recordId {get; set;}
    public String status {get; set;}
    public String survey {get; set;}
    public String initialjson {get; set;}

    public FormBuilderController(ApexPages.StandardSetController controller) {

    }
    public FormBuilderController(ApexPages.StandardController controller) {
        this.recordId = ApexPages.CurrentPage().getparameters().get('id');
        
    }

    public FormBuilderController() {}

    public class FormBuilderControllerException extends Exception {}

    public void init() {
        this.domainUrl = URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/municorn/v1/Form';
        if(recordId == NULL){
            this.survey = System.currentPageReference().getParameters().get('survey');
            this.recordId = this.survey;
        }
        System.debug('recordId '+this.recordId);
        this.initialjson = getJson();
        System.debug('initialjson '+initialjson);
        
    }

    public PageReference expand() {
        PageReference target = new
        PageReference('/apex/FormBuilderVf?survey='+this.recordId);
        target.setRedirect(true);
        // This is a permanent redirection
        // target.setRedirectCode(301);
        System.debug('expand called');
        return target;
    }

    public void updateSurveyRecord() {
        try {
            String formMetadata = apexpages.currentPage().getParameters().get('formMetadata');
            Survey__c survey = new Survey__c(Id = recordId, Form_JSON__c = formMetadata);
            if (this.status != 'Published') {
                Database.update(survey);
            } else {
                throw new FormBuilderControllerException('Survey for is Published and connot be modified.');
            }
        } catch (Exception e) {
            System.debug('Exception occured '+e.getMessage()+e.getStackTraceString());
        }
        
    }

    public String getJson(){
        String jsonStr ='{}';
        try{
            // SYS_DataCache.INT_TYPE = 'Form';
            // SYS_DataCache.OBJ_TYPE = 'Survey';
            List<Survey__c> newSObjectList = [select id, Form_JSON__c, Status__c from Survey__c where id =: recordId];
            if(newSObjectList != NULL && newSObjectList.size() > 0) {
                jsonStr = newSObjectList[0].Form_JSON__c != NULL ? newSObjectList[0].Form_JSON__c : '{}';
                this.status = newSObjectList[0].Status__c;
            }

            // SYS_ApplicationService appService = (SYS_ApplicationService)Type.forName(SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).ApexHandler__c).newInstance();
                    
            // Map<Id, String> jsonListForOutbound = appService.transformSObjectToJson(newSObjectList);
            // jsonStr = jsonListForOutbound.get(recordId);

        } catch(Exception e){
            System.debug('SP - error occured '+e.getStackTraceString());
        }
        return jsonStr;
    }

}