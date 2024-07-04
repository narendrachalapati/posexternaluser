public with sharing class OB_Square_SYS_ApplicationService extends SYS_ApplicationService {
    
    /**
     * INBOUND
     * This hook is called from SYS_Transformer to set values for sObject record
     * Default is mapping based on field type
     * Relies on Integration Setting in DataCache
     * Override if custom field mapping is required
     */
    public  override sObject processFieldMapping(FieldSetting__mdt mapping,sObject sObj,Object value, String sObjectApiName){

        /*--*/SYS_debug.log(mapping.FieldApiName__c+' +MS+ '+value);
        if(mapping.Get_value_from_Log__c)
            value = SYS_DataCache.log.get(mapping.Log_API_for_field_mapping__c);

        if(mapping.Is_Lookup__c && mapping.Lookup_External_Key__c!=NULL && mapping.Lookup_Object_API_Name__c!=NULL){
            value = getIdFromExternalKey(mapping.Lookup_Object_API_Name__c,mapping.Lookup_External_Key__c,String.valueOf(value));
        }

        if(mapping.StaticValue__c != NULL)
            value = mapping.StaticValue__c;
            

        if(value==NULL) return sObj;

        SObjectType r = ((SObject)(Type.forName('Schema.'+sObjectApiName).newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();
                
        String fieldType = d.fields
                            .getMap()
                            .get(mapping.FieldApiName__c)
                            .getDescribe()
                            .getType()+'';

        //TODO add other field types
        if(fieldType=='DATE'){
            sObj.put(mapping.FieldApiName__c, getDateValue(mapping,String.valueOf(value)) /*Date.valueOf((String)value)*/);
        }
        else if(fieldType=='DATETIME'){
            sObj.put(mapping.FieldApiName__c, getDatetimeValue(mapping, String.valueOf(value)));
        }
        else if(fieldType=='TIME'){
            sObj.put(mapping.FieldApiName__c, getTimeValue(mapping, String.valueOf(value)));
        }
        else if (fieldType == 'STRING') {
            sObj.put(mapping.FieldApiName__c, String.valueof(value));
        }else if (fieldType == 'BOOLEAN') {
            sObj.put(mapping.FieldApiName__c, Boolean.valueof(value));
        }
        else if(fieldType == 'MULTIPICKLIST'){
            sObj.put(mapping.FieldApiName__c,  String.valueof(value));
        }
        else if ( (mapping.FieldApiName__c == 'Formatted_Phone_Number__c') ) {
            if (String.valueof(value).startsWith('1')) {
                value = '+' + value; // Add '+1' prefix
                system.debug('valueNDR' + value);
                sObj.put(mapping.FieldApiName__c, String.valueof(value));
            }
           
        }
        else{
            sObj.put(mapping.FieldApiName__c, value);
        }

        SYS_debug.log('MS FINAL SOBJ:'+sObj);
        return sObj;
    }

}