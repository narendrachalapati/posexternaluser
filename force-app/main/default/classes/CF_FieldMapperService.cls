public with sharing class CF_FieldMapperService extends SYS_FieldMapperService{
    public static integer MAX = 120;
    public static string int_setting = 'Form';

    public CF_FieldMapperService() {

    }

    public class CF_FieldMapperServiceException extends Exception {}

    public override String getSavedJson(Id recordId) {
        String jsonBody = '{}'; 
        try {
            String sObjectApiName = SYS_Helper.getsObjectApiName(recordId);
            String query = 'SELECT '+ SYS_Helper.getAllFieldsFor(sObjectApiName) + ' FROM ' + sObjectApiName
            + ' WHERE Id =:recordId LIMIT 1';
            List<sObject> records = Database.query(query);
            if (records != NULL && records.size() > 0) {

                if(sObjectApiName == 'Survey__c') {
                    jsonBody = (String)records[0].get('Form_JSON__c');
                }
                else if (sObjectApiName == 'Custom_Form__c') {
                    jsonBody = (String)records[0].get('Response_JSON__c');
                }
            }

        } catch (Exception e) {
            System.debug(e.getStackTraceString() + e.getMessage());
            throw new CF_FieldMapperServiceException('Some error occured. '+e.getMessage());
        }
        return jsonBody;
    }

    public override Integer deployRequest(Id recordId, String request) {
        Integer result = 0;
        try{
            System.debug('body '+ request);
            List<SYS_FieldMapperController.FieldWrapper> fslist = 
            (List<SYS_FieldMapperController.FieldWrapper>)JSON.deserialize(request, List<SYS_FieldMapperController.FieldWrapper>.class);
            
            
            //container for Object Setting.
            
            if(fslist.size() > 0) {
                String primaryObjectApiName = fslist[0]?.primarySObjectApiName;

                if (primaryObjectApiName != NULL && primaryObjectApiName.equalsignorecase('Account')) {
                    result = createAccountMetadata(fslist, recordId);
                }
                else if (primaryObjectApiName != NULL && primaryObjectApiName.equalsignorecase('Feedback__c')) {
                    result = createFeedbackMetadata(fslist, recordId);
                }

            }

            
        } catch(Exception e) {
            System.debug('Error '+e.getStackTraceString()+e.getMessage());
            throw new CF_FieldMapperServiceException(e.getMessage());
        }
        return result;
    }

    public static Integer createFeedbackMetadata(List<SYS_FieldMapperController.FieldWrapper> fslist, Id recordId) {
        String objectSettingname = '', objectSettingnameForm = '';
        Integer result = 0;

        Map<String, String> apiNameMap = new Map<String , String>();
        Map<String, Map<String, Object>> containerMd = new Map<String, Map<String, Object>>();

        Map<String, Object> fieldWithValuesMapOS = new Map<String, Object>();
        objectSettingname = 'OS_'+SYS_Helper.getUUID()?.replace('-','_');

        fieldWithValuesMapOS.put('ApexHandler__c', 'SYS_ApplicationService');
        fieldWithValuesMapOS.put('IntegrationType__c', 'Form');
        fieldWithValuesMapOS.put('ObjectApiName__c', fslist[0]?.primarySObjectApiName);
        fieldWithValuesMapOS.put('Skip_Keys__c', '');
        fieldWithValuesMapOS.put('Trigger_Condition__c', '');
        fieldWithValuesMapOS.put('TriggerEvents__c', '');
        fieldWithValuesMapOS.put('url_params__c', '');

        apiNameMap.put(objectSettingname, 'ObjectSetting__mdt');
        containerMd.put(objectSettingname, fieldWithValuesMapOS);

        getFSToDeactivate(objectSettingname, apiNameMap, containerMd);
        // if(recordId != NULL) {
            // Custom_Form__c form = new Custom_Form__c(
            //     Id = recordId,
            //     Object_Setting__c = objectSettingname
            // );
            // update form;
        // }

        //container for field settings
        integer count = 1;
        for(SYS_FieldMapperController.FieldWrapper item:fslist) {
            if(item.FieldApiName != NULL && item.FieldApiName.endsWith('.')) {
                continue;
            }
            Map<String, Object> fieldWithValuesMap = new Map<String, Object>();

            // fieldWithValuesMap.put('Direction__c', SYS_Constants.INBOUND);
            // fieldWithValuesMap.put('FieldApiName__c', item.fieldApiName);
            // fieldWithValuesMap.put('Field_Mapping_Handler__c', 'SYS_ApplicationService');
            // fieldWithValuesMap.put('Is_Active__c', true);
            // fieldWithValuesMap.put('Key__c', item.flatkey);
            // fieldWithValuesMap.put('Level__c','0');
            // fieldWithValuesMap.put('ObjectApiName__c', item.sObjectApiName);

            
            fieldWithValuesMap.put('Direction__c', item.Direction);
            fieldWithValuesMap.put('FieldApiName__c', item.FieldApiName);
            fieldWithValuesMap.put('Field_Mapping_Handler__c', item.Field_Mapping_Handler);
            fieldWithValuesMap.put('Is_Active__c', item.Is_Active );
            fieldWithValuesMap.put('Key__c', item.Key);
            fieldWithValuesMap.put('ObjectApiName__c', item.ObjectApiName);
            fieldWithValuesMap.put('ObjectSetting__c', item.ObjectSetting);
            fieldWithValuesMap.put('Skip_Field_Setting__c', item.Skip_Field_Setting);
            fieldWithValuesMap.put('StaticValue__c', item.StaticValue);
            fieldWithValuesMap.put('Key_For_Events__c', item.Key_For_Events);
            fieldWithValuesMap.put('RestResource__c', String.isEmpty(item.RestResource) ? objectSettingname : item.RestResource);
            fieldWithValuesMap.put('Is_External_Field__c', item.Is_External_Field);
            fieldWithValuesMap.put('Is_Lookup__c', item.Is_Lookup);
            fieldWithValuesMap.put('Lookup_Object_API_Name__c', item.Lookup_Object_API_Name);
            fieldWithValuesMap.put('Datetime_Conversion_Format__c', item.Datetime_Conversion_Format);
            fieldWithValuesMap.put('Get_value_from_Log__c', item.Get_value_from_Log);
            fieldWithValuesMap.put('Log_API_for_field_mapping__c', item.Log_API_for_field_mapping);
            fieldWithValuesMap.put('Lookup_External_Key__c', item.Lookup_External_Key);
            fieldWithValuesMap.put('Mapping_is_for__c', item.Mapping_is_for);
            fieldWithValuesMap.put('Level__c', item.Level);
            fieldWithValuesMap.put('Send_Blanks_as_Empty_String__c', true);
            fieldWithValuesMap.put('ChildRootElement__c', item.ChildRootElement);
            fieldWithValuesMap.put('ParentField__c', item.ParentField);


            //TODO- create object setting after selecting primary object.
            fieldWithValuesMap.put('ObjectSetting__c', objectSettingname);
            

            // apiNameMap.put('FS_' + item.FieldApiName + count, 'FieldSetting__mdt');
            // containerMd.put('FS_' + item.FieldApiName + count, fieldWithValuesMap);

            String developername = 'a'+item.developername.replace('-','_');
            apiNameMap.put(developername, 'FieldSetting__mdt');
            containerMd.put(developername, fieldWithValuesMap);
            count++;
        }
        
        updateSurveyFormDetails( recordId, objectSettingname, objectSettingnameForm);


        result = apiNameMap.values().size();
        System.debug('feedbackCount '+result);
        /**
         * @apiNameMap contains map of developername and cmd apiname
         * @containerMd contains map of developername and field<-->value cmd
         */
        SYS_customMetadataDeploy.requestDeployment(
            apiNameMap, containerMd
        );

        return result;
    }

    public static Integer createAccountMetadata(List<SYS_FieldMapperController.FieldWrapper> fslist, Id recordId) {
        String objectSettingname = '', objectSettingnameForm = '';
        Integer result = 0;

        Map<String, String> apiNameMap = new Map<String , String>();
        Map<String, Map<String, Object>> containerMd = new Map<String, Map<String, Object>>();

        Map<String, Object> fieldWithValuesMapOS = new Map<String, Object>();
        objectSettingname = 'OS_'+SYS_Helper.getUUID()?.replace('-','_');

        fieldWithValuesMapOS.put('ApexHandler__c', 'SYS_ApplicationService');
        fieldWithValuesMapOS.put('IntegrationType__c', 'Form');
        fieldWithValuesMapOS.put('ObjectApiName__c', fslist[0]?.primarySObjectApiName);
        fieldWithValuesMapOS.put('Skip_Keys__c', '');
        fieldWithValuesMapOS.put('Trigger_Condition__c', '');
        fieldWithValuesMapOS.put('TriggerEvents__c', '');
        fieldWithValuesMapOS.put('url_params__c', '');

        apiNameMap.put(objectSettingname, 'ObjectSetting__mdt');
        containerMd.put(objectSettingname, fieldWithValuesMapOS);

        Map<String, Object> fieldWithValuesMapForm = new Map<String, Object>();
        objectSettingnameForm = 'OS_'+SYS_Helper.getUUID()?.replace('-','_');

        fieldWithValuesMapForm.put('ApexHandler__c', 'SYS_ApplicationService');
        fieldWithValuesMapForm.put('IntegrationType__c', int_setting);
        fieldWithValuesMapForm.put('ObjectApiName__c', 'Custom_Form__c');
        fieldWithValuesMapForm.put('Skip_Keys__c', '');
        fieldWithValuesMapForm.put('Trigger_Condition__c', '');
        fieldWithValuesMapForm.put('TriggerEvents__c', '');
        fieldWithValuesMapForm.put('url_params__c', '');

        apiNameMap.put(objectSettingnameForm, 'ObjectSetting__mdt');
        containerMd.put(objectSettingnameForm, fieldWithValuesMapForm);

        getFSToDeactivate(objectSettingname, apiNameMap, containerMd);
        // if(recordId != NULL) {
            // Custom_Form__c form = new Custom_Form__c(
            //     Id = recordId,
            //     Object_Setting__c = objectSettingname
            // );
            // update form;
        // }

        //container for field settings
        integer count = 1;
        for(SYS_FieldMapperController.FieldWrapper item:fslist) {
            if(item.FieldApiName != NULL && item.FieldApiName.endsWith('.')) {
                continue;
            }
            Map<String, Object> fieldWithValuesMap = new Map<String, Object>();

            // fieldWithValuesMap.put('Direction__c', SYS_Constants.INBOUND);
            // fieldWithValuesMap.put('FieldApiName__c', item.fieldApiName);
            // fieldWithValuesMap.put('Field_Mapping_Handler__c', 'SYS_ApplicationService');
            // fieldWithValuesMap.put('Is_Active__c', true);
            // fieldWithValuesMap.put('Key__c', item.flatkey);
            // fieldWithValuesMap.put('Level__c','0');
            // fieldWithValuesMap.put('ObjectApiName__c', item.sObjectApiName);

            
            fieldWithValuesMap.put('Direction__c', item.Direction);
            fieldWithValuesMap.put('FieldApiName__c', item.FieldApiName);
            fieldWithValuesMap.put('Field_Mapping_Handler__c', item.Field_Mapping_Handler);
            fieldWithValuesMap.put('Is_Active__c', item.Is_Active );
            fieldWithValuesMap.put('Key__c', item.Key);
            fieldWithValuesMap.put('ObjectApiName__c', item.ObjectApiName);
            fieldWithValuesMap.put('ObjectSetting__c', item.ObjectSetting);
            fieldWithValuesMap.put('Skip_Field_Setting__c', item.Skip_Field_Setting);
            fieldWithValuesMap.put('StaticValue__c', item.StaticValue);
            fieldWithValuesMap.put('Key_For_Events__c', item.Key_For_Events);
            fieldWithValuesMap.put('RestResource__c', String.isEmpty(item.RestResource) ? objectSettingname : item.RestResource);
            fieldWithValuesMap.put('Is_External_Field__c', item.Is_External_Field);
            fieldWithValuesMap.put('Is_Lookup__c', item.Is_Lookup);
            fieldWithValuesMap.put('Lookup_Object_API_Name__c', item.Lookup_Object_API_Name);
            fieldWithValuesMap.put('Datetime_Conversion_Format__c', item.Datetime_Conversion_Format);
            fieldWithValuesMap.put('Get_value_from_Log__c', item.Get_value_from_Log);
            fieldWithValuesMap.put('Log_API_for_field_mapping__c', item.Log_API_for_field_mapping);
            fieldWithValuesMap.put('Lookup_External_Key__c', item.Lookup_External_Key);
            fieldWithValuesMap.put('Mapping_is_for__c', item.Mapping_is_for);
            fieldWithValuesMap.put('Level__c', item.Level);
            fieldWithValuesMap.put('Send_Blanks_as_Empty_String__c', true);
            fieldWithValuesMap.put('ChildRootElement__c', item.ChildRootElement);
            fieldWithValuesMap.put('ParentField__c', item.ParentField);


            //TODO- create object setting after selecting primary object.
            fieldWithValuesMap.put('ObjectSetting__c', objectSettingname);
            

            // apiNameMap.put('FS_' + item.FieldApiName + count, 'FieldSetting__mdt');
            // containerMd.put('FS_' + item.FieldApiName + count, fieldWithValuesMap);

            String developername = 'a'+item.developername.replace('-','_');
            apiNameMap.put(developername, 'FieldSetting__mdt');
            containerMd.put(developername, fieldWithValuesMap);
            count++;
        }
        addFSForCustomFormOutbound(objectSettingnameForm,  fslist, apiNameMap, containerMd);
        updateSurveyFormDetails( recordId, objectSettingname, objectSettingnameForm);


        result = apiNameMap.values().size();

        /**
         * @apiNameMap contains map of developername and cmd apiname
         * @containerMd contains map of developername and field<-->value cmd
         */
        SYS_customMetadataDeploy.requestDeployment(
            apiNameMap, containerMd
        );

        return result;
    }

    public static void addFSForCustomFormOutbound(String objectSettingname, List<SYS_FieldMapperController.FieldWrapper> fslist, 
    Map<String, String> apiNameMap, Map<String, Map<String, Object>> containerMd) {
        for(SYS_FieldMapperController.FieldWrapper item:fslist) {
            if(item.FieldApiName != NULL && item.FieldApiName.endsWith('.')) {
                continue;
            }
            Map<String, Object> fieldWithValuesMap = new Map<String, Object>();

            // fieldWithValuesMap.put('Direction__c', SYS_Constants.INBOUND);
            // fieldWithValuesMap.put('FieldApiName__c', item.fieldApiName);
            // fieldWithValuesMap.put('Field_Mapping_Handler__c', 'SYS_ApplicationService');
            // fieldWithValuesMap.put('Is_Active__c', true);
            // fieldWithValuesMap.put('Key__c', item.flatkey);
            // fieldWithValuesMap.put('Level__c','0');
            // fieldWithValuesMap.put('ObjectApiName__c', item.sObjectApiName);

            
            fieldWithValuesMap.put('Direction__c', 'OUTBOUND');
            fieldWithValuesMap.put('FieldApiName__c', 'Account__r.'+item.FieldApiName);
            fieldWithValuesMap.put('Field_Mapping_Handler__c', item.Field_Mapping_Handler);
            fieldWithValuesMap.put('Is_Active__c', item.Is_Active );
            fieldWithValuesMap.put('Key__c', item.Key);
            fieldWithValuesMap.put('ObjectApiName__c', 'Custom_Form__c');
            fieldWithValuesMap.put('ObjectSetting__c', item.ObjectSetting);
            fieldWithValuesMap.put('Skip_Field_Setting__c', item.Skip_Field_Setting);
            fieldWithValuesMap.put('StaticValue__c', item.StaticValue);
            fieldWithValuesMap.put('Key_For_Events__c', item.Key_For_Events);
            fieldWithValuesMap.put('RestResource__c', item.RestResource);
            fieldWithValuesMap.put('Is_External_Field__c', item.Is_External_Field);
            fieldWithValuesMap.put('Is_Lookup__c', item.Is_Lookup);
            fieldWithValuesMap.put('Lookup_Object_API_Name__c', item.Lookup_Object_API_Name);
            fieldWithValuesMap.put('Datetime_Conversion_Format__c', item.Datetime_Conversion_Format);
            fieldWithValuesMap.put('Get_value_from_Log__c', item.Get_value_from_Log);
            fieldWithValuesMap.put('Log_API_for_field_mapping__c', item.Log_API_for_field_mapping);
            fieldWithValuesMap.put('Lookup_External_Key__c', item.Lookup_External_Key);
            fieldWithValuesMap.put('Mapping_is_for__c', item.Mapping_is_for);
            fieldWithValuesMap.put('Level__c', '0');
            fieldWithValuesMap.put('Send_Blanks_as_Empty_String__c', item.Send_Blanks_as_Empty_String);
            fieldWithValuesMap.put('ChildRootElement__c', item.ChildRootElement);
            fieldWithValuesMap.put('ParentField__c', item.ParentField);


            //TODO- create object setting after selecting primary object.
            fieldWithValuesMap.put('ObjectSetting__c', objectSettingname);
            

            // apiNameMap.put('FS_' + item.FieldApiName + count, 'FieldSetting__mdt');
            // containerMd.put('FS_' + item.FieldApiName + count, fieldWithValuesMap);

            String developername = 'f'+SYS_Helper.getUUID().replace('-','_');
            apiNameMap.put(developername, 'FieldSetting__mdt');
            containerMd.put(developername, fieldWithValuesMap);
        }
    }


    @future
    public static void updateSurveyFormDetails(Id recordId, String objectSettingname, String objectSettingnameForm) {
        if(SYS_Helper.getsObjectApiName(recordId) == 'Survey__c') {
            Survey__c survey = new Survey__c(
                Id = recordId, Object_Setting__c=objectSettingname , 
                Autofill_Configuration__c = objectSettingnameForm ,
                Integration_Setting__c = int_setting);
                Database.SaveResult sr = Database.update(survey);
                
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted account. Survey ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Survey fields that affected this error: ' + err.getFields());
                    }
                }
        }
    }
}