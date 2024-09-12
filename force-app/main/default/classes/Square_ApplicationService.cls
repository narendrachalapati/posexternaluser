public without sharing class Square_ApplicationService extends SYS_ApplicationService {
        
        public Square_ApplicationService() {}
        
        /**
         * Override for Phone Number Formatting for Customer and Team Member resources
         * Override for Quantity in Order
         * Override for PriceMoney in CatalogItemVariant from Dollar to Cents
         * Override for Temporary Id in CatalogItem and CatalogItemVariation
         * OUTBOUND
         * This hook is called from SYS_Transformer to set values for JSON record
         * Relies on Integration Setting in DataCache
         * Override if custom field mapping is required
         */
        public override Object getFieldValues(sObject obj, FieldSetting__mdt mapping, String fieldAPIName){
            //TODO - handle case - Account."CreatedBy".Name, where CreatedBy is not an sobject - This can be handled by overriding the current method and add the handler
            // on field setting
            
            String fvalue= (mapping.Send_Blanks_as_Empty_String__c)?'':null;
            
            if(fieldAPIName == null){
                fvalue = mapping.StaticValue__c;
            }
            else if( (fieldAPIName.contains(SYS_DataCacheFactory.FLAT_KEY_SEPERATOR)) && (  (fieldAPIName == SYS_DataCache.namespacePrefix + 'CatalogItem__r.Id') ||  (fieldAPIName == SYS_DataCache.namespacePrefix + 'catalog_Modifer_List__r.Id') ) ){
                List<String> splitedFields = fieldAPIName.split('\\'+SYS_DataCacheFactory.FLAT_KEY_SEPERATOR);
                try{
                    for(Integer i = 0; i < splitedFields.size() - 1; i++){
                        obj = obj.getSobject(splitedFields[i]);
                    }
                    String lookupValue = (String)obj.get(splitedFields[splitedFields.size()-1]);
                    if ( (String.isNotBlank(lookupValue)) && !(lookupValue.startsWith('#')) ) {
                        lookupValue = '#' + lookupValue; // Add '#' prefix
                    }
                    return lookupValue;
                }catch(exception ex){
                    /*--*/SYS_debug.log('****** Exception while fetching fieldValues as relationship '+fieldAPIName+'  value is blank.'+ex.getmessage());
                    return null;
                }
                
            }

            else if( (fieldAPIName.contains(SYS_DataCacheFactory.FLAT_KEY_SEPERATOR)) && (fieldAPIName == SYS_DataCache.namespacePrefix + 'Location__r.Square_Id__c') ){
                List<String> splitedFields = fieldAPIName.split('\\'+SYS_DataCacheFactory.FLAT_KEY_SEPERATOR);
                try{
                    for(Integer i = 0; i < splitedFields.size() - 1; i++){
                        obj = obj.getSobject(splitedFields[i]);
                    }
                    String lookupValue = (String)obj.get(splitedFields[splitedFields.size()-1]);
                    return ((String.isNotBlank(lookupValue)) ? new List<String>{lookupValue} : NULL);
                }catch(exception ex){
                    /*--*/SYS_debug.log('****** Exception while fetching fieldValues as relationship '+fieldAPIName+'  value is blank.'+ex.getmessage());
                    return null;
                }
                
            }
            else if(fieldAPIName.contains(SYS_DataCacheFactory.FLAT_KEY_SEPERATOR)){
                List<String> splitedFields = fieldAPIName.split('\\'+SYS_DataCacheFactory.FLAT_KEY_SEPERATOR);
                try{
                    for(Integer i = 0; i < splitedFields.size() - 1; i++){
                        obj = obj.getSobject(splitedFields[i]);
                    }
                    return obj.get(splitedFields[splitedFields.size()-1]);
                }catch(exception ex){
                    /*--*/SYS_debug.log('****** Exception while fetching fieldValues as relationship '+fieldAPIName+'  value is blank.'+ex.getmessage());
                    return null;
                }
                
            }
            else if ( (obj.get(fieldAPIName)!=null) && ((fieldAPIName == SYS_DataCache.namespacePrefix + 'PriceMoney__c') ||(fieldAPIName == SYS_DataCache.namespacePrefix + 'Amount__c')) ) {
                Decimal priceMoneyValue = ((Decimal)obj.get(fieldAPIName));
                if ( (priceMoneyValue != NULL) && (priceMoneyValue > 0) ) {
                    priceMoneyValue = priceMoneyValue * 100;
                }
                return priceMoneyValue;
            }
            else if( (obj.get(fieldAPIName)!=null) && (fieldAPIName == SYS_DataCache.namespacePrefix + 'Id') && ( (mapping.ObjectApiName__c == 'CatalogItem__c') || (mapping.ObjectApiName__c == 'CatalogItemVariation__c') || (mapping.ObjectApiName__c == 'CatalogModifier__c') || (mapping.ObjectApiName__c == 'Catalog_Modifer_List__c') ) ){
                String tempSquareId = ((String)obj.get(fieldAPIName));
                if ( !(String.valueof(tempSquareId).startsWith('#')) ) {
                    tempSquareId = '#' + tempSquareId; // Add '#' prefix
                }
                return tempSquareId;
            }
            else if ( (obj.get(fieldAPIName)!=null) && (fieldAPIName == SYS_DataCache.namespacePrefix + 'Formatted_Phone_Number__c') ) {
                String tempPhoneNumber = ((String)obj.get(fieldAPIName));
                if (String.valueof(tempPhoneNumber).startsWith('1')) {
                    tempPhoneNumber = '+' + tempPhoneNumber; // Add '+1' prefix
                }
                return tempPhoneNumber;
            }
            else if ( (obj.get(fieldAPIName)!=null) && (fieldAPIName == SYS_DataCache.namespacePrefix + 'Quantity__c') ) {
                String quantity = ((String)obj.get(fieldAPIName));
                
                return quantity;
            }
            else if(obj.get(fieldAPIName)!=null){
                SObjectType r = obj.getSObjectType();
                DescribeSObjectResult d = r.getDescribe();
                
                String fieldType = d.fields
                    .getMap()
                    .get(mapping.FieldApiName__c)
                    .getDescribe()
                    .getType()+'';
                if(fieldType == 'MULTIPICKLIST'){
                    return ((String)obj.get(fieldAPIName)).split(';');
                }
                else if(fieldType=='TIME') {
                    Time timeValue = ((Time)obj.get(fieldAPIName));
                    String formattedTime = String.valueOf(timeValue.hour()).leftPad(2, '0') + ':' + String.valueOf(timeValue.minute()).rightPad(2, '0') + ':00';
                    
                    return formattedTime;
                }
                else
                    return obj.get(fieldAPIName);
            }
            return fvalue;
        }

        public override Object getFieldValues(sObject obj, IntegrationMetadata.FlatKey mapping, String fieldAPIName){
            //TODO - handle case - Account."CreatedBy".Name, where CreatedBy is not an sobject - This can be handled by overriding the current method and add the handler
            // on field setting
    
            String fvalue= (mapping.sendBlankAsEmptyString)?'':null;
            
            if(fieldAPIName == null){
                fvalue = mapping.staticValue;
            }
            else if(fieldAPIName.contains(SYS_DataCacheFactory.FLAT_KEY_SEPERATOR)){
                List<String> splitedFields = fieldAPIName.split('\\'+SYS_DataCacheFactory.FLAT_KEY_SEPERATOR);
                try{
                    for(Integer i = 0; i < splitedFields.size() - 1; i++){
                        obj = obj.getSobject(splitedFields[i]);   
                    } 
                    return obj.get(splitedFields[splitedFields.size()-1]);
                }catch(exception ex){
                   /*--*/SYS_debug.log('****** Exception while fetching fieldValues as relationship '+fieldAPIName+'  value is blank.'+ex.getmessage()); 
                   return null;
                }
                
            } 
            /*
            else if(obj.get(fieldAPIName)!=null && fieldAPIName == SYS_DataCache.namespacePrefix + 'Is_Taxable__c') { //TODO - specific to quickbooks
                return ((Boolean)obj.get(fieldAPIName)) ? 'TAX' : 'NON';
            } 
            else if(obj.get(fieldAPIName) != null && fieldAPIName == SYS_DataCache.namespacePrefix + 'Total_Tax__c') {
                return ((Decimal)obj.get(fieldAPIName)) == 0.00 ? 'null' : obj.get(fieldAPIName);  
            }
            */
            else if( (fieldAPIName.contains(SYS_DataCacheFactory.FLAT_KEY_SEPERATOR)) && (fieldAPIName == SYS_DataCache.namespacePrefix + 'Location__r.Square_Id__c') ){
                List<String> splitedFields = fieldAPIName.split('\\'+SYS_DataCacheFactory.FLAT_KEY_SEPERATOR);
                try{
                    for(Integer i = 0; i < splitedFields.size() - 1; i++){
                        obj = obj.getSobject(splitedFields[i]);
                    }
                    String lookupValue = (String)obj.get(splitedFields[splitedFields.size()-1]);
                    return ((String.isNotBlank(lookupValue)) ? new List<String>{lookupValue} : NULL);
                }catch(exception ex){
                    /*--*/SYS_debug.log('****** Exception while fetching fieldValues as relationship '+fieldAPIName+'  value is blank.'+ex.getmessage());
                    return null;
                }
                
            }
            else if(fieldAPIName.contains(SYS_DataCacheFactory.FLAT_KEY_SEPERATOR)){
                List<String> splitedFields = fieldAPIName.split('\\'+SYS_DataCacheFactory.FLAT_KEY_SEPERATOR);
                try{
                    for(Integer i = 0; i < splitedFields.size() - 1; i++){
                        obj = obj.getSobject(splitedFields[i]);
                    }
                    return obj.get(splitedFields[splitedFields.size()-1]);
                }catch(exception ex){
                    /*--*/SYS_debug.log('****** Exception while fetching fieldValues as relationship '+fieldAPIName+'  value is blank.'+ex.getmessage());
                    return null;
                }
                
            }
            else if ( (obj.get(fieldAPIName)!=null) && ((fieldAPIName == SYS_DataCache.namespacePrefix + 'PriceMoney__c') ||(fieldAPIName == SYS_DataCache.namespacePrefix + 'Amount__c')) ) {
                Decimal priceMoneyValue = ((Decimal)obj.get(fieldAPIName));
                if ( (priceMoneyValue != NULL) && (priceMoneyValue > 0) ) {
                    priceMoneyValue = priceMoneyValue * 100;
                }
                return priceMoneyValue;
            }
            else if( (obj.get(fieldAPIName)!=null) && (fieldAPIName == SYS_DataCache.namespacePrefix + 'Id') && ( (SYS_DataCacheFactory.srType.Primary_Object__c == 'CatalogItem__c') || (SYS_DataCacheFactory.srType.Primary_Object__c == 'CatalogItemVariation__c') || (SYS_DataCacheFactory.srType.Primary_Object__c == 'CatalogModifier__c') || (SYS_DataCacheFactory.srType.Primary_Object__c == 'Catalog_Modifer_List__c') ) ){
                String tempSquareId = ((String)obj.get(fieldAPIName));
                if ( !(String.valueof(tempSquareId).startsWith('#')) ) {
                    tempSquareId = '#' + tempSquareId; // Add '#' prefix
                }
                return tempSquareId;
            }
            else if ( (obj.get(fieldAPIName)!=null) && (fieldAPIName == SYS_DataCache.namespacePrefix + 'Formatted_Phone_Number__c') ) {
                String tempPhoneNumber = ((String)obj.get(fieldAPIName));
                if (String.valueof(tempPhoneNumber).startsWith('1')) {
                    tempPhoneNumber = '+' + tempPhoneNumber; // Add '+1' prefix
                }
                return tempPhoneNumber;
            }
            else if ( (obj.get(fieldAPIName)!=null) && (fieldAPIName == SYS_DataCache.namespacePrefix + 'Quantity__c') ) {
                String quantity = ((String)obj.get(fieldAPIName));
                
                return quantity;
            }
            else if(obj.get(fieldAPIName)!=null){
                SObjectType r = obj.getSObjectType();
                DescribeSObjectResult d = r.getDescribe();
                        
                String fieldType = d.fields
                                    .getMap()
                                    .get(mapping.field)
                                    .getDescribe()
                                    .getType()+'';
                if(fieldType == 'MULTIPICKLIST'){
                    return ((String)obj.get(fieldAPIName)).split(';');
                }
                else
                    return obj.get(fieldAPIName);
            }
            return fvalue;
        }
        
        
        /**
         * Override for Phone Number Formatting for Customer and Team Member resources
         * Override for Expiry Month Formatting for Card resource
         * Override for PriceMoney conversion form Cents to USD for CatalogItemVariation resource
         * INBOUND
         * This hook is called from SYS_Transformer to set values for sObject record
         * Default is mapping based on field type
         * Relies on Integration Setting in DataCache
         * Override if custom field mapping is required
         */
        public override sObject processFieldMapping(FieldSetting__mdt mapping,sObject sObj,Object value, String sObjectApiName){
            
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
            else if ( (mapping.FieldApiName__c == 'PriceMoney__c') ) {
                Decimal priceMoneyValue = 0.0;
                if(value != NUll){
                    priceMoneyValue = Integer.valueOf(value)/100;
                }
                sObj.put(mapping.FieldApiName__c, priceMoneyValue);
            }
            else if ( (mapping.FieldApiName__c == 'Duration_Hours__c') || (mapping.FieldApiName__c == 'Duration_Minutes__c') ) {
                Integer serviceDurationValue = 0;
                if(value != NUll){
                    serviceDurationValue = Integer.valueOf(value); // in milliseconds
                    Integer hours = (Integer)Math.floor(serviceDurationValue / 3600000);
                    Integer minutes = (Integer)Math.floor((serviceDurationValue - hours * 3600000) / 60000);
                    Integer minutesRemainder = (Integer)Math.mod(minutes, 5);
                    Integer minutesInterval = minutes - minutesRemainder;
                    if (minutesRemainder > 0) {
                        minutesInterval += 5;
                    }
                    
                    System.debug( hours + ' hours and ' + minutesInterval + ' minutes');
                    if( (hours != NULL) && (hours >= 0 ) ) {
                        sObj.put('Duration_Hours__c', String.valueof(hours));
                    }
                    if( (minutesInterval != NULL) && (minutesInterval >= 0 ) ) {
                        sObj.put('Duration_Minutes__c', String.valueof(minutesInterval));
                    }
                    
                    // if(mapping.FieldApiName__c == 'Duration_Hours__c') {
                        //     sObj.put(mapping.FieldApiName__c, String.valueof(hours));
                    // }
                    // if(mapping.FieldApiName__c == 'Duration_Minutes__c') {
                        //     sObj.put(mapping.FieldApiName__c, String.valueof(minutesInterval));
                    // }
                }
            }
            else if ( (mapping.FieldApiName__c == 'ExpMonth__c') ) {
                sObj.put(mapping.FieldApiName__c, String.valueof(value));
            }
            else if ( (mapping.FieldApiName__c == 'Phone_Number__c') ) {
                if ( (value != NUll) && (String.valueof(value).startsWith('+1')) ) {
                    value = (String.valueof(value)).replaceAll('\\+1',''); // remove '+1' prefix
                    sObj.put(mapping.FieldApiName__c, String.valueof(value));
                } else {
                    sObj.put(mapping.FieldApiName__c, value);
                }
            }
            else if (fieldType == 'STRING') {
                sObj.put(mapping.FieldApiName__c, String.valueof(value));
            }else if (fieldType == 'BOOLEAN') {
                sObj.put(mapping.FieldApiName__c, Boolean.valueof(value));
            }
            else if(fieldType == 'MULTIPICKLIST'){
                sObj.put(mapping.FieldApiName__c,  String.valueof(value));
            }
            else{
                sObj.put(mapping.FieldApiName__c, value);
            }
            
            SYS_debug.log('MS FINAL SOBJ:'+sObj);
            return sObj;
        }

        public override sObject processFieldMapping(IntegrationMetadata.FlatKey mapping,sObject sObj,Object value, String sObjectApiName){

            /*--*/SYS_debug.log(mapping.field+' +MS+ '+value);
            // if(mapping.Get_value_from_Log__c)
            //     value = SYS_DataCache.log.get(mapping.Log_API_for_field_mapping__c);
    
            // if(mapping.Is_Lookup__c && mapping.Lookup_External_Key__c!=NULL && mapping.Lookup_Object_API_Name__c!=NULL){
            //     value = getIdFromExternalKey(mapping.Lookup_Object_API_Name__c,mapping.Lookup_External_Key__c,String.valueOf(value));
            // }
    
            if(String.isNotBlank(mapping.staticValue))
                value = mapping.staticValue;
                
    
            if(value==NULL) return sObj;
    
            SObjectType r = ((SObject)(Type.forName('Schema.'+sObjectApiName).newInstance())).getSObjectType();
            DescribeSObjectResult d = r.getDescribe();
                    
            String fieldType = d.fields
                                .getMap()
                                .get(mapping.field)
                                .getDescribe()
                                .getType()+'';
    
            //TODO add other field types
            if(fieldType=='DATE'){
                sObj.put(mapping.field, getDateValue(mapping,String.valueOf(value)) /*Date.valueOf((String)value)*/);
            }
            else if(fieldType=='DATETIME'){
                sObj.put(mapping.field, getDatetimeValue(mapping, String.valueOf(value)));
            }
            else if(fieldType=='TIME'){
                sObj.put(mapping.field, getTimeValue(mapping, String.valueOf(value)));
            }
            else if ( (mapping.field == 'PriceMoney__c') ) {
                Decimal priceMoneyValue = 0.0;
                if(value != NUll){
                    priceMoneyValue = Integer.valueOf(value)/100;
                }
                sObj.put(mapping.field, priceMoneyValue);
            }
            else if ( (mapping.field == 'Duration_Hours__c') || (mapping.field == 'Duration_Minutes__c') ) {
                Integer serviceDurationValue = 0;
                if(value != NUll){
                    serviceDurationValue = Integer.valueOf(value); // in milliseconds
                    Integer hours = (Integer)Math.floor(serviceDurationValue / 3600000);
                    Integer minutes = (Integer)Math.floor((serviceDurationValue - hours * 3600000) / 60000);
                    Integer minutesRemainder = (Integer)Math.mod(minutes, 5);
                    Integer minutesInterval = minutes - minutesRemainder;
                    if (minutesRemainder > 0) {
                        minutesInterval += 5;
                    }
                    
                    System.debug( hours + ' hours and ' + minutesInterval + ' minutes');
                    if( (hours != NULL) && (hours >= 0 ) ) {
                        sObj.put('Duration_Hours__c', String.valueof(hours));
                    }
                    if( (minutesInterval != NULL) && (minutesInterval >= 0 ) ) {
                        sObj.put('Duration_Minutes__c', String.valueof(minutesInterval));
                    }
                    
                    // if(mapping.FieldApiName__c == 'Duration_Hours__c') {
                        //     sObj.put(mapping.FieldApiName__c, String.valueof(hours));
                    // }
                    // if(mapping.FieldApiName__c == 'Duration_Minutes__c') {
                        //     sObj.put(mapping.FieldApiName__c, String.valueof(minutesInterval));
                    // }
                }
            }
            else if ( (mapping.field == 'ExpMonth__c') ) {
                sObj.put(mapping.field, String.valueof(value));
            }
            else if ( (mapping.field == 'Phone_Number__c') ) {
                if ( (value != NUll) && (String.valueof(value).startsWith('+1')) ) {
                    value = (String.valueof(value)).replaceAll('\\+1',''); // remove '+1' prefix
                    sObj.put(mapping.field, String.valueof(value));
                } else {
                    sObj.put(mapping.field, value);
                }
            }
            else if (fieldType == 'STRING') {
                sObj.put(mapping.field, String.valueof(value));
            }else if (fieldType == 'BOOLEAN') {
                sObj.put(mapping.field, Boolean.valueof(value));
            }
            else if(fieldType == 'MULTIPICKLIST'){
                sObj.put(mapping.field,  String.valueof(value));
            }
            else{
                sObj.put(mapping.field, value);
            }
    
            SYS_debug.log('MS FINAL SOBJ:'+sObj);
            return sObj;
        }
        
        /**
         * Override for Time value of business hours
         */
        public override Time getTimeValue(FieldSetting__mdt mapping, String ts){
            
            String format = 'hh:mm:ss';
            
            Integer hoursIndex = format.indexOf('hh');
            Integer minutesIndex = format.indexOf('mm');
            Integer secondsIndex = format.indexOf('ss');
            
            Integer hours = Integer.valueOf(ts.substring(hoursIndex, hoursIndex + 2));
            Integer minutes = Integer.valueOf(ts.substring(minutesIndex, minutesIndex + 2));
            Integer seconds = (secondsIndex > 0)?Integer.valueOf(ts.substring(secondsIndex, secondsIndex + 2)):0;
            Integer ms = 0;
            
            Time timeValue =
                Time.newInstance(   hours,
            minutes,
            seconds,
            ms );
            /*--*/SYS_debug.log('=============== '+timeValue);
            
            return timeValue;
        }

        public override Time getTimeValue(IntegrationMetadata.FlatKey mapping, String ts){
            
            String format = 'hh:mm:ss';
            
            Integer hoursIndex = format.indexOf('hh');
            Integer minutesIndex = format.indexOf('mm');
            Integer secondsIndex = format.indexOf('ss');
            
            Integer hours = Integer.valueOf(ts.substring(hoursIndex, hoursIndex + 2));
            Integer minutes = Integer.valueOf(ts.substring(minutesIndex, minutesIndex + 2));
            Integer seconds = (secondsIndex > 0)?Integer.valueOf(ts.substring(secondsIndex, secondsIndex + 2)):0;
            Integer ms = 0;
            
            Time timeValue =
                Time.newInstance(   hours,
            minutes,
            seconds,
            ms );
            /*--*/SYS_debug.log('=============== '+timeValue);
            
            return timeValue;
        }
        
        /**
         * This hook is called from doInbound to identify resource from incoming JSON
         * Arguement: SYS Log record and JSON Body
         * Default is return the root if it exists or the value of falt key mentioned in Flat_Key_for_Resource__c field on log record
         * Override if custom implementation is required for identifying the resoruce for inbound request
         */
        public override String getResourceFromJSON(SYS_IntegrationLog__c log,String jsonBody){
            
            String resource = '';
            if(log.Resource__c!=NULL){
                /*--*/SYS_debug.log('-- MS Resource defined in Log'+log.Resource__c.toLowerCase());
                return log.Resource__c.toLowerCase();
            }
            
            if(log.Flat_Key_for_Resource__c == NULL || log.Flat_Key_for_Resource__c == ''){
                //Root element identifies Resource
                
                Object responseType = JSON.deserializeUntyped(jsonBody);
                if(responseType instanceof Map<String,Object>){
                    resource = new List<String>(((Map<String, Object>)responseType).keySet())[0];
                }
                /*--*/SYS_debug.log('-- MS Root defines resource'+resource.toLowerCase());
            }
            else{
                //Key mentioned in Flat_Key_for_Resource__c identifies Resource
                Map<String, Object> flatKeyMap = SYS_Helper.getFlatKeys(jsonBody,'A_B');
                /*--*/SYS_debug.log('-- MS flatKeyMap in getResourceFromJSON:'+flatKeyMap);
                resource = (String)flatKeyMap.get(log.Flat_Key_for_Resource__c);
            }
            
            //If resource was blank root key was resource
            if(String.isBlank(resource)) {
                //Root element identifies Resource
                
                Object responseType = JSON.deserializeUntyped(jsonBody);
                if(responseType instanceof Map<String,Object>){
                    resource = new List<String>(((Map<String, Object>)responseType).keySet())[0];
                }
                /*--*/SYS_debug.log('-- MS Root defines resource'+resource.toLowerCase());
            }
            
            /*--*/SYS_debug.log('-- MS Final identified resource in getResourceFromJSON:'+resource?.toLowerCase());
            
            return resource?.toLowerCase();
        }

        public override String getResourceFromJSON(Individual log,String jsonBody){

            String resource = '';
            if(log.Resource__c!=NULL){
                /*--*/SYS_debug.log('-- MS Resource defined in Log'+log.Resource__c.toLowerCase());
                return log.Resource__c.toLowerCase();
            }
    
            if(log.Flat_Key_for_Resource__c == NULL || log.Flat_Key_for_Resource__c == ''){
                //Root element identifies Resource
      
                Object responseType = JSON.deserializeUntyped(jsonBody);
                if(responseType instanceof Map<String,Object>){
                    resource = new List<String>(((Map<String, Object>)responseType).keySet())[0];
                }
                /*--*/SYS_debug.log('-- MS Root defines resource'+resource.toLowerCase());
            }
            else{
                //Key mentioned in Flat_Key_for_Resource__c identifies Resource
                Map<String, Object> flatKeyMap = SYS_Helper.getFlatKeys(jsonBody,'A_B');
                /*--*/SYS_debug.log('-- MS flatKeyMap in getResourceFromJSON:'+flatKeyMap);
                resource = (String)flatKeyMap.get(log.Flat_Key_for_Resource__c);
            }
    
            /*--*/SYS_debug.log('-- MS Final identified resource in getResourceFromJSON:'+resource?.toLowerCase());
    
            return resource?.toLowerCase();
        }
        
        /*
         * Override for Team Assigned Locations List transformation
         */
        public override List<SYS_IntegrationLog__c> generatelogForOutboundResultNew(HttpResponse resp,SYS_IntegrationLog__c log ){
            
            SYS_IntegrationLog__c logResp = new SYS_IntegrationLog__c();
            List<SYS_IntegrationLog__c> logAfterPartition = new List<SYS_IntegrationLog__c>();
            String responseBody = resp.getBody();
            System.debug('responseBody ' + responseBody);
            
            //Override for Team Member Assigned Locations
            List<String> locationsList = new List<String>();
            Map<String, Object> newflatKeyMap = (SYS_Helper.getFlatKeys(responseBody ,'A.B'));
            
            String teamMemberAssignedLocations = (newflatKeyMap.containsKey('team_member.assigned_locations.location_ids[]') ? (String)newflatKeyMap.get('team_member.assigned_locations.location_ids[]') :
                (newflatKeyMap.containsKey('data.object.team_member.assigned_locations.location_ids[]') ? (String)newflatKeyMap.get('data.object.team_member.assigned_locations.location_ids[]') : ''));
            
            locationsList = (String.isNotBlank(teamMemberAssignedLocations)) ? teamMemberAssignedLocations.split(';') : new List<String>();
            System.debug('locationsList ' + locationsList.size());
            if(locationsList.size() > 0) {
                Object jsonObject = System.JSON.deserializeUntyped(responseBody);
                Object teamMemberObject = NULL, assignedLocationsObj = NULL;
                teamMemberObject = (jsonObject != NULL) ? ( ((Map<String, Object>)jsonObject).get('team_member')) : NULL;
                if(teamMemberObject == NULL) {
                    Object jsonDataObj = ((Map<String, Object>)jsonObject).get('data');
                    Object jsonObjectObj = ((Map<String, Object>)jsonDataObj).get('object');
                    teamMemberObject = ((Map<String, Object>)jsonObjectObj).get('team_member');
                }
                
                //Fetch assigned_locations object
                assignedLocationsObj = (teamMemberObject != NULL) ? ( ((Map<String, Object>)teamMemberObject).get('assigned_locations') ) : NULL;
                
                
                if( (assignedLocationsObj != NULL) && (teamMemberObject != NULL) ) {
                    system.debug('Update team_member object');
                    //Update team_member object with new assigned_locations object
                    Integer i = 0;
                    for(String iterLocation : locationsList) {
                        //Add New keys for each location as location0, location1 ..
                        //Update assigned_locations object
                        ((Map<String, Object>)assignedLocationsObj).put('location'+i, iterLocation);
                        i = i + 1;
                    }
                    //Update team_member object with new assigned_locations object
                    //Update team_member object
                    ((Map<String, Object>)teamMemberObject).put('assigned_locations', assignedLocationsObj);
                    
                }
                responseBody = JSON.serialize(jsonObject);
            }
            
            //Replace RootKey with data key for Catalog Outbound Response
            String rootKey = '';
            Object jsonObj = JSON.deserializeUntyped(responseBody);
            if(jsonObj instanceof Map<String,Object>){
                rootKey = new List<String>(((Map<String, Object>)jsonObj).keySet())[0];
            }
            if( (rootKey == 'catalog_object') ) {
                Object catalogJsonDataObj = new Map<String, Object>();
                Object newCatalogJsonDataObj = ((Map<String,Object>)jsonObj).get(rootKey);
              
                if(log.ObjectSettingId__c == 'Square_Modfier'){
                    ((Map<String, Object>)catalogJsonDataObj).put('object', newCatalogJsonDataObj);
                    responseBody = JSON.serialize(catalogJsonDataObj);
                }else{
                    ((Map<String, Object>)catalogJsonDataObj).put('data', newCatalogJsonDataObj);
                    responseBody = JSON.serialize(catalogJsonDataObj);
                }
            }
             System.debug('new responseBody ' + responseBody);
            Map<String, Object> catalogJsonDataObj = new Map<String, Object>();
            //string inputjson = '';
            // Parse the input JSON into a Map
            Map<String, Object> inputJson = (Map<String, Object>)(system.JSON.deserializeUntyped(responseBody));
            
            // Create a new list for the modified objects
            List<Map<String, Object>> modifiedObjects = new List<Map<String, Object>>();
            
            List<Object> objectsList = (List<Object>)inputJson.get('objects');
            List<Object> relatedobjects = (List<Object>)inputJson.get('related_objects');
             if(objectsList != null && relatedobjects != null){
            // Iterate over the objects in the input JSON
            for ( Object obj : objectsList) {
                Map<String, Object> currentObj = (Map<String, Object>)obj;
                // Add the related objects to the current object
                currentObj.put('related_objects', relatedobjects);
                modifiedObjects.add(currentObj);
            }
            
            // Set the modified objects and latest time in the output JSON
            catalogJsonDataObj.put('objects', modifiedObjects);
            catalogJsonDataObj.put('latest_time', inputJson.get('latest_time'));
            
            // Serialize the output JSON
          //  String outputJsonString = JSON.serializePretty(catalogJsonDataObj);
           // String finalJSON = outputJsonString.replace('\n',' ');
            // Print the output JSON
           // System.debug(finalJSON);
            responseBody = JSON.serialize(catalogJsonDataObj);
        }
            //Override for GET Cards List Outbound Response - Resource Identifier
            String jsonResource;
            Object jsonObject = System.JSON.deserializeUntyped(responseBody);
            if(jsonObject instanceof Map<String,Object>){
                jsonResource = new List<String>(((Map<String, Object>)jsonObject).keySet())[0];
            }
            
            if(responseBody != NULL && responseBody.length() > SYS_Constants.TEXT_AREA_MAX_SIZE*10) {
                logAfterPartition = SYS_Helper.getLogsAfterPartition(responseBody);
                if(logAfterPartition != NULL && logAfterPartition.size() > 0) {
                    // SYS_Helper.upsertLog(logs[0]);
                    // List<SYS_IntegrationLog__c> childs = SYS_Helper.getChildRecords(logs);
                    
                    // SYS_Helper.upsertLog(childs);
                    logResp = logAfterPartition[0];
                }
            } else {
                logResp =  SYS_Helper.getLogsToInsert(responseBody);
            }
            
            String algo = SYS_DataCacheFactory.integrationSetting.Hashing_Algo__c;
            if(algo!=NULL && algo!='')
                logResp.Request_Digest__c = generateHash(responseBody,algo);
            
            logResp.Force_Sync__c = log.Force_Sync__c;
            
            if(resp.getStatusCode() != 201 && resp.getStatusCode() != 200 && resp.getStatusCode() != 204){
                
                SYS_debug.log('#### resp status: '+resp.getStatus());
                SYS_debug.log('#### resp code: '+resp.getStatusCode());
                SYS_debug.log('#### resp: '+responseBody);
                
                log.Status__c = 'FAIL';
                if(!log.Force_Sync__c)
                    log.retry__c = true;
                
                logResp.Status__c = 'ERROR';
                
                logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
                logResp.WhatId__c = log.WhatId__c;
                logResp.Type__c = SYS_Constants.RESPONSE;
                logResp.How_To_Process__c = 'ignore_log';
                logResp.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
                
            }
            else{
                log.Status__c = 'DONE';
                
                if (String.isEmpty(responseBody)) {
                    logResp.How_To_Process__c = 'ignore_log';
                    logResp.Status__c = 'DONE';
                    logResp.How_To_Process__c = 'use_custom_apex_handler';
                    logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
                }
                else if(log.SYS_Operation_Type__c == 'INSERT' || log.Force_Sync__c){
                    logResp.Status__c = SYS_Constants.NEW_STATUS;
                    logResp.SYS_Operation_Type__c = 'UPDATE';
                    // logResp.Flat_Key_for_Resource__c = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Flat_Key_for_Resource_Response__c;
                    
                    if(SYS_DataCacheFactory.OBJ_TYPE!=NULL)
                        logResp.Resource__c = SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Resource_Name__c;
                    
                    logResp.How_To_Process__c = 'use_custom_apex_handler';
                    logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
                    
                }
                else{
                    
                    
                    if(SYS_DataCacheFactory.OBJ_TYPE != NULL && SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Always_Ignore_Response__c){
                        logResp.How_To_Process__c = 'ignore_log';
                        logResp.Status__c = 'DONE';
                    }
                    else{
                        if(SYS_DataCacheFactory.OBJ_TYPE!=NULL) // Override for Cards List Parent Log
                            logResp.Resource__c = (jsonResource == 'cards') ? jsonResource : (SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Resource_Name__c);
                        
                        logResp.SYS_Operation_Type__c = 'UPSERT';
                        logResp.How_To_Process__c = 'use_custom_apex_handler';
                        logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
                    }
                    //logResp.Status__c = 'DONE';
                    //logResp.How_To_Process__c = 'ignore_log';
                    
                }
                logResp.Flat_Key_for_Resource__c = SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource_Response__c;
                logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
                logResp.WhatId__c = log.WhatId__c;
                logResp.Type__c = SYS_Constants.RESPONSE;
                logResp.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
                logResp.ObjectSettingId__c = log.ObjectSettingId__c;
                
            }
            logResp.Integration_Type__c = log.Integration_Type__c;
            logResp.Account_Id__c = log.Account_Id__c;
            
            //doDML(new List<SYS_IntegrationLog__c>{log}, 'UPSERT', '') ;
            // ##SYS_Helper.upsertLog(new List<SYS_IntegrationLog__c>{log});
            
            logResp.SYS_RequestId__c = log.Id;
            if(log.Id == NULL && log.UUID__c == NULL) {
                log.UUID__c = SYS_Helper.getUUID();
                logResp.Parent_UUID__c = log.UUID__c;
                logResp.UUID__c = SYS_Helper.getUUID();
            }
            List<SYS_IntegrationLog__c> returnVal = new List<SYS_IntegrationLog__c>();
            returnVal.add(log);
            returnVal.add(logResp);
            if(logAfterPartition != NULL && logAfterPartition.size() > 0) {
                logResp.Status__c = SYS_Constants.PENDING_PARTITIONED_LOOKUP;
                for(integer i = 1 ; i < logAfterPartition.size() ; i++) {
                    returnVal.add(logAfterPartition[i]);
                }
            }
            return returnVal;
        }

        public override List<Individual> generatelogForOutboundResultNew(HttpResponse resp,Individual log ){

            Individual logResp = new Individual();
            List<Individual> logAfterPartition = new List<Individual>();
    
            if(resp.getBody() != NULL && resp.getBody().length() > SYS_Constants.TEXT_AREA_MAX_SIZE*10) {
                logAfterPartition = SYS_Helper.getIndividualLogsAfterPartition(resp.getBody());
                if(logAfterPartition != NULL && logAfterPartition.size() > 0) {
                    // SYS_Helper.upsertLog(logs[0]);
                    // List<SYS_IntegrationLog__c> childs = SYS_Helper.getChildRecords(logs);
                    
                    // SYS_Helper.upsertLog(childs);
                    logResp = logAfterPartition[0];
                }
            } else {
                logResp =  SYS_Helper.getIndividualLogsToInsert(resp.getBody());
            }
    
            String algo = SYS_DataCacheFactory.SRIntegrationSetting.Hashing_Algo__c;
            if(algo!=NULL && algo!='')
                logResp.Request_Digest__c = generateHash(resp.getBody(),algo);
    
            logResp.Force_Sync__c = log.Force_Sync__c;
    
            if(resp.getStatusCode() != 201 && resp.getStatusCode() != 200 && resp.getStatusCode() != 204){
    
                SYS_debug.log('#### resp status: '+resp.getStatus());
                SYS_debug.log('#### resp code: '+resp.getStatusCode()); 
                SYS_debug.log('#### resp: '+resp.getBody());
    
                log.Status__c = 'FAIL';
                if(!log.Force_Sync__c)
                    log.retry__c = true;
    
                logResp.Status__c = 'ERROR';
                
                logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
                logResp.WhatId__c = log.WhatId__c;
                logResp.Type__c = SYS_Constants.RESPONSE;
                logResp.How_To_Process__c = 'ignore_log';
                logResp.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
                
            }
            else{
                log.Status__c = 'DONE';
    
                if (String.isEmpty(resp.getBody())) {
                    logResp.How_To_Process__c = 'ignore_log';
                    logResp.Status__c = 'DONE';
                    logResp.How_To_Process__c = 'use_custom_apex_handler';
                    logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
                }
                else if(log.SYS_Operation_Type__c == 'INSERT' || log.Force_Sync__c){
                    logResp.Status__c = SYS_Constants.NEW_STATUS;
                    logResp.SYS_Operation_Type__c = 'UPDATE';
                    // logResp.Flat_Key_for_Resource__c = SYS_DataCache.integrationSetting.get(SYS_DataCache.INT_TYPE).Flat_Key_for_Resource_Response__c;
    
                    if(SYS_DataCacheFactory.OBJ_TYPE!=NULL)
                        logResp.Resource__c = SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Resource_Name__c;
                    
                    logResp.How_To_Process__c = 'use_custom_apex_handler';
                    logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
                
                }
                else{
    
                    
                    if(SYS_DataCacheFactory.OBJ_TYPE != NULL && SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Always_Ignore_Response__c){
                            logResp.How_To_Process__c = 'ignore_log';
                            logResp.Status__c = 'DONE';
                    }
                    else{
                        if(SYS_DataCacheFactory.OBJ_TYPE!=NULL)
                            logResp.Resource__c = SYS_DataCacheFactory.objectSettingMap.get(SYS_DataCacheFactory.OBJ_TYPE).Resource_Name__c;
                    
                        logResp.SYS_Operation_Type__c = 'UPSERT';
                        logResp.How_To_Process__c = 'use_custom_apex_handler';
                        logResp.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
                    }
                    //logResp.Status__c = 'DONE';
                    //logResp.How_To_Process__c = 'ignore_log';
    
                }
                logResp.Flat_Key_for_Resource__c = SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource_Response__c;
                logresp.SYS_Http_Status__c = Integer.valueOf(resp.getStatusCode());
                logResp.WhatId__c = log.WhatId__c;
                logResp.Type__c = SYS_Constants.RESPONSE;
                logResp.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
                logResp.ObjectSettingId__c = log.ObjectSettingId__c;
                
            }
            logResp.Integration_Type__c = log.Integration_Type__c;
            logResp.Account_Id__c = log.Account_Id__c;
            logResp.Service_Request_Type__c = log.Service_Request_Type__c;
            logResp.Service_Request_Group__c = log.Service_Request_Group__c;
    
            //doDML(new List<SYS_IntegrationLog__c>{log}, 'UPSERT', '') ;
            // ##SYS_Helper.upsertLog(new List<SYS_IntegrationLog__c>{log});
            
            logResp.SYS_RequestId__c = log.Id;
            if(log.Id == NULL && log.UUID__c == NULL) {
                log.UUID__c = SYS_Helper.getUUID();
                logResp.Parent_UUID__c = log.UUID__c;
                logResp.UUID__c = SYS_Helper.getUUID();
            }
            List<Individual> returnVal = new List<Individual>();
            returnVal.add(log);
            returnVal.add(logResp);
            if(logAfterPartition != NULL && logAfterPartition.size() > 0) {
                logResp.Status__c = SYS_Constants.PENDING_PARTITIONED_LOOKUP;
                for(integer i = 1 ; i < logAfterPartition.size() ; i++) {
                    returnVal.add(logAfterPartition[i]);
                }
            }
            return returnVal;
        }
        
        /**
         * This hook is called from each of the hook for Http Verb processing
         * Arguement: Http Verb - POST,GET,PATCH,DELETE,PUT
         * Relies on Integration Setting in DataCache and RestContext
         * Override if custom log generation is required
         */
        public override List<SYS_IntegrationLog__c> generateLogForWebhookReq(String method) {
            String requestBody = RestContext.request.requestBody.toString();
            SYS_IntegrationLog__c log = new SYS_IntegrationLog__c();
            List<SYS_IntegrationLog__c> logAfterPartition = new List<SYS_IntegrationLog__c>();
            
            Map<String, String> resourcePathMap = new Map<String, String>{ 'catalog_version' => 'catalog/object','order_created' => 'orders', 'order_fulfillment_updated' => 'orders', 'order_updated' => 'orders'};
            
            //Override for Team Member Assigned Locations
            Map<String, Object> newflatKeyMap = (SYS_Helper.getFlatKeys(requestBody ,'A.B'));
            String resourcePath = newflatKeyMap.containsKey('data.type') ? (String)newflatKeyMap.get('data.type') :'';
            List<String> locationsList = new List<String>();
            
            String teamMemberAssignedLocations = (newflatKeyMap.containsKey('team_member.assigned_locations.location_ids[]') ? (String)newflatKeyMap.get('team_member.assigned_locations.location_ids[]') :
                (newflatKeyMap.containsKey('data.object.team_member.assigned_locations.location_ids[]') ? (String)newflatKeyMap.get('data.object.team_member.assigned_locations.location_ids[]') : ''));
            
            locationsList = (String.isNotBlank(teamMemberAssignedLocations)) ? teamMemberAssignedLocations.split(';') : new List<String>();
            
            System.debug('locationsList ' + locationsList.size());
            if(locationsList.size() > 0) {
                Object jsonObject = System.JSON.deserializeUntyped(requestBody);
                Object teamMemberObject = NULL, assignedLocationsObj = NULL;
                teamMemberObject = (jsonObject != NULL) ? ( ((Map<String, Object>)jsonObject).get('team_member')) : NULL;
                
                if(teamMemberObject == NULL) {
                    Object jsonDataObj = ((Map<String, Object>)jsonObject).get('data');
                    Object jsonObjectObj = ((Map<String, Object>)jsonDataObj).get('object');
                    teamMemberObject = ((Map<String, Object>)jsonObjectObj).get('team_member');
                }
                
                //Fetch assigned_locations object
                assignedLocationsObj = (teamMemberObject != NULL) ? ( ((Map<String, Object>)teamMemberObject).get('assigned_locations') ) : NULL;
                
                
                if( (assignedLocationsObj != NULL) && (teamMemberObject != NULL) ) {
                    system.debug('Update team_member object');
                    //Update team_member object with new assigned_locations object
                    Integer i = 0;
                    for(String iterLocation : locationsList) {
                        //Add New keys for each location as location0, location1 ..
                        //Update assigned_locations object
                        ((Map<String, Object>)assignedLocationsObj).put('location'+i, iterLocation);
                        i = i + 1;
                    }
                    //Update team_member object with new assigned_locations object
                    //Update team_member object
                    ((Map<String, Object>)teamMemberObject).put('assigned_locations', assignedLocationsObj);
                    
                }
                requestBody = JSON.serialize(jsonObject);
            }
            
            if(String.isNotBlank(resourcePath)) {
                resourcePath =  resourcePath.toLowerCase();
                resourcePath = resourcePathMap.containsKey(resourcePath) ? resourcePathMap.get(resourcePath) : resourcePath;
            }
            
            //Check criteria when chars more than 1M
            if(requestBody != NULL && requestBody.length() > SYS_Constants.TEXT_AREA_MAX_SIZE*10) {
                logAfterPartition = SYS_Helper.getLogsAfterPartition(requestBody);
                if(logAfterPartition != NULL && logAfterPartition.size() > 0) {
                    // SYS_Helper.upsertLog(logs[0]);
                    // List<SYS_IntegrationLog__c> childs = SYS_Helper.getChildRecords(logs);
                    
                    // SYS_Helper.upsertLog(childs);
                    log = logAfterPartition[0];
                }
                System.debug('SP 1M<<');
            } else {
                log = SYS_Helper.getLogsToInsert(requestBody);
                System.debug('SP 1M>>');
            }
            
            
            String algo = SYS_DataCacheFactory.integrationSetting.Hashing_Algo__c;
            if(algo!=NULL && algo!='')
                log.Request_Digest__c = generateHash(requestBody,algo);
            
            if( (resourcePath == 'catalog/object') || (resourcePath == 'location') || (resourcePath == 'orders') ) {
                log.Is_Notification_Only__c = true;
            }
            // if(SYS_DataCacheFactory.integrationSetting.Notifications_are_partial__c)
            //     log.Is_Notification_Only__c = true;
            
            log.Type__c = SYS_Constants.INBOUND;
            log.SYS_Operation_Type__c = getOperationTypeFor(method);
            log.Flat_Key_for_Resource__c = SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource__c;
            log.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
            log.Status__c = SYS_Constants.NEW_STATUS;
            log.How_to_process__c = 'use_custom_apex_handler';
            log.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
            
            log.Account_Id__c = SYS_DataCacheFactory.accountId;
            log.Integration_Type__c = SYS_DataCacheFactory.integrationSetting?.Integration_Type__c;
            
            List<SYS_IntegrationLog__c> returnVal = new List<SYS_IntegrationLog__c>();
            returnVal.add(log);
            if(logAfterPartition != NULL && logAfterPartition.size() > 0) {
                log.Status__c = SYS_Constants.PENDING_PARTITIONED_LOOKUP;
                for(integer i = 1 ; i < logAfterPartition.size() ; i++) {
                    returnVal.add(logAfterPartition[i]);
                }
            }
            
            return returnVal;
        }

        public override List<Individual> generateIndividualLogForWebhookReq(String method) {
            String requestBody = RestContext.request.requestBody.toString();
            Individual log = new Individual();
            List<Individual> logAfterPartition = new List<Individual>();
            Map<String, String> resourcePathMap = new Map<String, String>{ 'catalog_version' => 'catalog/object','order_created' => 'orders', 'order_fulfillment_updated' => 'orders', 'order_updated' => 'orders'};
            
            //Override for Team Member Assigned Locations
            Map<String, Object> newflatKeyMap = (SYS_Helper.getFlatKeys(requestBody ,'A.B'));
            String resourcePath = newflatKeyMap.containsKey('data.type') ? (String)newflatKeyMap.get('data.type') :'';
            List<String> locationsList = new List<String>();
            
            String teamMemberAssignedLocations = (newflatKeyMap.containsKey('team_member.assigned_locations.location_ids[]') ? (String)newflatKeyMap.get('team_member.assigned_locations.location_ids[]') :
                (newflatKeyMap.containsKey('data.object.team_member.assigned_locations.location_ids[]') ? (String)newflatKeyMap.get('data.object.team_member.assigned_locations.location_ids[]') : ''));
            
            locationsList = (String.isNotBlank(teamMemberAssignedLocations)) ? teamMemberAssignedLocations.split(';') : new List<String>();
            
            System.debug('locationsList ' + locationsList.size());
            if(locationsList.size() > 0) {
                Object jsonObject = System.JSON.deserializeUntyped(requestBody);
                Object teamMemberObject = NULL, assignedLocationsObj = NULL;
                teamMemberObject = (jsonObject != NULL) ? ( ((Map<String, Object>)jsonObject).get('team_member')) : NULL;
                
                if(teamMemberObject == NULL) {
                    Object jsonDataObj = ((Map<String, Object>)jsonObject).get('data');
                    Object jsonObjectObj = ((Map<String, Object>)jsonDataObj).get('object');
                    teamMemberObject = ((Map<String, Object>)jsonObjectObj).get('team_member');
                }
                
                //Fetch assigned_locations object
                assignedLocationsObj = (teamMemberObject != NULL) ? ( ((Map<String, Object>)teamMemberObject).get('assigned_locations') ) : NULL;
                
                
                if( (assignedLocationsObj != NULL) && (teamMemberObject != NULL) ) {
                    system.debug('Update team_member object');
                    //Update team_member object with new assigned_locations object
                    Integer i = 0;
                    for(String iterLocation : locationsList) {
                        //Add New keys for each location as location0, location1 ..
                        //Update assigned_locations object
                        ((Map<String, Object>)assignedLocationsObj).put('location'+i, iterLocation);
                        i = i + 1;
                    }
                    //Update team_member object with new assigned_locations object
                    //Update team_member object
                    ((Map<String, Object>)teamMemberObject).put('assigned_locations', assignedLocationsObj);
                    
                }
                requestBody = JSON.serialize(jsonObject);
            }
            
            if(String.isNotBlank(resourcePath)) {
                resourcePath =  resourcePath.toLowerCase();
                resourcePath = resourcePathMap.containsKey(resourcePath) ? resourcePathMap.get(resourcePath) : resourcePath;
            }
            //Check criteria when chars more than 1M
            if(requestBody != NULL && requestBody.length() > SYS_Constants.TEXT_AREA_MAX_SIZE*10) {
                logAfterPartition = SYS_Helper.getIndividualLogsAfterPartition(requestBody);
                if(logAfterPartition != NULL && logAfterPartition.size() > 0) {
                    // SYS_Helper.upsertLog(logs[0]);
                    // List<SYS_IntegrationLog__c> childs = SYS_Helper.getChildRecords(logs);
                    
                    // SYS_Helper.upsertLog(childs);
                    log = logAfterPartition[0];
                }
                System.debug('SP 1M<<');
            } else {
                log = SYS_Helper.getIndividualLogsToInsert(requestBody);
                System.debug('SP 1M>>');
            }
    
            String algo = SYS_DataCacheFactory.SRIntegrationSetting.Hashing_Algo__c;
            if(algo!=NULL && algo!='')
            log.Request_Digest__c = generateHash(requestBody,algo);
    
            if(SYS_DataCacheFactory.SRIntegrationSetting.Notifications_are_partial__c)
                log.Is_Notification_Only__c = true;
    
            log.Type__c = SYS_Constants.INBOUND;
            log.SYS_Operation_Type__c = getOperationTypeFor(method);
            log.Flat_Key_for_Resource__c = SYS_DataCacheFactory.SRIntegrationSetting.Flat_Key_for_Resource__c;
            log.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
            log.Service_Request_Type__c = SYS_DataCacheFactory.SR_TYPEID;
            log.Service_Request_Group__c = SYS_DataCacheFactory.SR_GROUPID;
            log.Status__c = SYS_Constants.NEW_STATUS;
            log.How_to_process__c = 'use_custom_apex_handler';
            // log.Custom_Apex_Handler__c = SYS_DataCacheFactory.SRIntegrationSetting.ApexHandler__c;
            log.Custom_Apex_Handler__c = 'SYS_ApplicationService';
    
            log.Account_Id__c = SYS_DataCacheFactory.accountId;
            log.Integration_Type__c = SYS_DataCacheFactory.SRIntegrationSetting?.Integration_Type__c;
    
            List<Individual> returnVal = new List<Individual>();
            returnVal.add(log);
            if(logAfterPartition != NULL && logAfterPartition.size() > 0) {
                log.Status__c = SYS_Constants.PENDING_PARTITIONED_LOOKUP;
                for(integer i = 1 ; i < logAfterPartition.size() ; i++) {
                    returnVal.add(logAfterPartition[i]);
                }
            }
    
            return returnVal;
        }
        
        
        /**
         * This hook is called from SYS_QueueableForInboundChild to generate logs for inbound child records
         * Arguement: record json and Integration setting
         * Override if custom log generation is required
         */
        public override SYS_IntegrationLog__c generateLogForChildRecords(SYS_IntegrationLog__c parentLog,String resource,String recordsJson,String integrationSetting) {
            
            if(String.isNotBlank(recordsJson)) {
                Object jsonObject = System.JSON.deserializeUntyped(recordsJson);

                if(parentLog.Resource__c == 'location'){ // For Location Business Hours
                    String parentJsonBody =  SYS_Helper.getDataFrom(parentLog);
                    Map<String, Object> parentLogflatKeyMap = (SYS_Helper.getFlatKeys(parentJsonBody ,'A.B'));
                    String locationId = parentLogflatKeyMap.containsKey('location.id') ? (String)parentLogflatKeyMap.get('location.id'):'';
                    String locationTimezone = parentLogflatKeyMap.containsKey('location.timezone') ? (String)parentLogflatKeyMap.get('location.timezone'):'';
                    ((Map<String, Object>)jsonObject).put('timezone', locationTimezone);

                    //Extract Child Flat Key Map
                    Map<String, Object> childLogflatKeyMap = (SYS_Helper.getFlatKeys(recordsJson ,'A.B'));
                    String day_of_week = childLogflatKeyMap.containsKey('day_of_week') ? (String)childLogflatKeyMap.get('day_of_week'):'';
                    String businessHoursExId = day_of_week + '_' + locationId;
                    ((Map<String, Object>)jsonObject).put('business_hour_id', businessHoursExId);
                    recordsJson = JSON.serialize(jsonObject);
                }
                if( (parentLog.Resource__c == 'cards') ) { // For Cards List
                    Object dataObj = new Map<String, Object>();
                    Object objectChildObj = new Map<String, Object>();
                    Object cardChildObj = new Map<String, Object>();
                    
                    ((Map<String, Object>)cardChildObj).put('card', jsonObject);
                    ((Map<String, Object>)objectChildObj).put('object', cardChildObj);
                    ((Map<String, Object>)dataObj).put('data', objectChildObj);
                    recordsJson = JSON.serialize(dataObj);
                    
                    parentLog.Status__c = 'DONE';
                    parentLog.Message__c = '';
                    
                    SYS_Helper.updateLog(parentLog);
                }
                if(parentLog.Resource__c == 'modifier_list'){
                    Map<String, Object> newResponseMap = (Map<String, Object>)JSON.deserializeUntyped(recordsJson);
                    Map<String, Object> modifierData = (Map<String, Object>)newResponseMap.get('modifier_data');
                    system.debug(modifierData);
                    // Extract the amount and convert it to decimal
                    Map<String, Object> modifierpriceData = (Map<String, Object>)modifierData.get('price_money');
                    system.debug(modifierpriceData);
                    Decimal amount = (Decimal)modifierpriceData.get('amount');
                    system.debug(amount);
                    Decimal amountNew = amount / 100.0; // Ensure proper decimal division
                    modifierpriceData.put('amount', amountNew);
                    recordsJson = JSON.serialize(newResponseMap);
                    System.debug(recordsJson);
                    parentLog.Status__c = 'DONE';
                    parentLog.Message__c = '';
                    
                    SYS_Helper.updateLog(parentLog);
                }
            }
        
        
            SYS_IntegrationLog__c log = SYS_Helper.getLogsToInsert(recordsJson);
            
            log.ObjectSettingId__c = parentLog.ObjectSettingId__c;
            log.Account_Id__c = parentLog.Account_Id__c;
            log.Integration_Type__c = parentLog.Integration_Type__c;
            /* ------------------------------------ FOR ALL OR NONE HANDLING -------------------------------------- */
            if(log.ObjectSettingId__c!=NULL && SYS_DataCacheFactory.objectSettingMap.get(log.ObjectSettingId__c).All_OR_None__c){
                //log.Custom_Field_Value__c = parentLog[0].WhatId__c;
                log.SYS_Operation_Type__c = 'INSERT';
            }
            else {
                log.SYS_Operation_Type__c = 'UPSERT';
            }
            /* ------------------------------------ FOR ALL OR NONE HANDLING -------------------------------------- */
            
            String algo = SYS_DataCacheFactory.integrationSetting.Hashing_Algo__c;
            if(algo!=NULL && algo!='')
                log.Request_Digest__c = generateHash(recordsJson,algo);
            
            SYS_debug.log('MS SYS_DataCache.log in generate child log:'+SYS_DataCache.log.Id);
            log.Parent__c = parentLog.Id;
            log.Type__c = SYS_Constants.INBOUND;
            
            /**
             * If there the Parent Resource Map is defined on IS the use it to derive the resource for child records else
             * If Flat key to identify resource for child records is defined on Integration Setting, consider that
             * Else take the root key as Resource that is passed on while processing parent record
             */
            String flat_key_for_child = SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource_Child__c;
            
            if( (SYS_DataCacheFactory.PARENT_RESOURCE_MAP != NULL) && SYS_DataCacheFactory.PARENT_RESOURCE_MAP.containsKey(parentLog.Resource__c) ){
                log.Resource__c = SYS_DataCacheFactory.PARENT_RESOURCE_MAP.get(parentLog.Resource__c);
            }
            else if(flat_key_for_child != NULL && flat_key_for_child!='')
                log.Flat_Key_for_Resource__c = flat_key_for_child;
            else{
                log.Resource__c = resource;
                log.Flat_Key_for_Resource__c = '';
            }
            
            log.Integration_Setting__c = integrationSetting;
            log.Status__c = SYS_Constants.NEW_STATUS;
            /**
             * Applies when the child records require parenting after creation
             */
            // For Cards List and Catalog Item Variations List Override
            log.Requires_process_on_complete__c = ( (parentLog.Resource__c == 'cards') || (parentLog.Resource__c == 'catalog/search') || (parentLog.Resource__c == 'item')) ? false : true;
            log.On_Complete_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
            /** */
            
            log.How_to_process__c = 'use_custom_apex_handler';
            log.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
            
            return log;
        }
        
    /* 
    ------------------------------------------------------------------------ 
    Override for resourcePathUrl for Webhooks
    */
    public override void processInboundRecord(SYS_IntegrationLog__c log, Map<SYS_IntegrationLog__c, sObject> mapLogrecVsObject, List<SYS_IntegrationLog__c> partialSysLogs, List<SYS_IntegrationLog__c> allChildLogs) {
        
        String jsonBody = '';
        // jsonBody =  SYS_Helper.getDataFrom(log);
        jsonBody =  SYS_Helper.getDataFromNew(log, allChildLogs);
        jsonBody = preprocessJSONForInbound(log,jsonBody);
        
        if( log.Is_Notification_Only__c ){ //SYS_DataCacheFactory.integrationSetting.Notifications_are_partial__c &&
            String baseEndpoint = SYS_DataCache.integrationSetting.get(SYS_Datacache.INT_TYPE).BaseAPIEndPoint__c;
            String getURLPattern = baseEndpoint + SYS_DataCacheFactory.integrationSetting.GET_URL_Pattern__c;
            
            SYS_NotificationInterface it =
                (SYS_NotificationInterface)Type.forName(SYS_DataCacheFactory.integrationSetting.Notification_Wrapper__c).newInstance();
                
                // List<SYS_IntegrationLog__c> insertSysLog = new List<SYS_IntegrationLog__c>();
                
                for(Map<String,String> rMap:it.getIterator(jsonBody)){
                    String objectSetting = SYS_DataCacheFactory.OBJ_TYPE, resourcePath = '', method = 'GET', requestBody;
                    String getURL = getURLPattern;
                    SYS_IntegrationLog__c  newSysLog = new SYS_IntegrationLog__c();
                    for(String key:rMap.keySet()) {
                        if(key == 'resourcePathUrl') {
                        getURL = getURL.replaceAll('\\{'+key+'\\}',rMap.get(key));
                    }
                    
                    if(key == 'objectSetting') {
                        objectSetting = (rMap.containsKey(key)) ? rMap.get(key) : objectSetting;
                    }
                    if(key == 'resourcePath') {
                        resourcePath = (rMap.containsKey(key)) ? rMap.get(key) : '';
                    }
                    if(key == 'method') {
                        method = (rMap.containsKey(key)) ? rMap.get(key) : 'GET';
                    }
                    if(key == 'requestBody') {
                        requestBody = (rMap.containsKey(key)) ? rMap.get(key) : '';
                    }
                }
                /*--*/SYS_debug.log('=============== '+ getURL);
                
                if(String.isNotBlank(requestBody)) {
                    newSysLog.data0__c = requestBody;
                }
                newSysLog.Status__c = SYS_Constants.NEW_STATUS;
                newSysLog.HTTP_Method__c = method;
                newSysLog.Callout_URL__c = getURL;
                newSysLog.Type__c = SYS_Constants.OUTBOUND;
                newSysLog.WhatId__c = log.WhatId__c;
                newSysLog.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
                newSysLog.ObjectSettingId__c = objectSetting;
                newSysLog.Resource__c = resourcePath;
                newSysLog.SYS_Operation_Type__c = 'UPSERT';
                newSysLog.How_to_process__c = 'use_custom_apex_handler';
                newSysLog.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
                newSysLog.Parent__c = log.Id;
                newSysLog.Integration_Type__c = log.Integration_Type__c;
                newSysLog.Account_Id__c = log.Account_Id__c;
                partialSysLogs.add(newSysLog);
            }

            
            // if(insertSysLog.size()>0 && SYS_DataCache.enableCheck.get(SYS_DataCache.INT_TYPE.toUpperCase())){
            //     SYS_Helper.insertLog(insertSysLog);
            // }

            // return true;

        }
        else{
            String resource = getResourceFromJSON(log,jsonBody);
            log.Resource__c = resource;
            SYS_debug.log('\n\n ------------------------------- \n\n Application Service resource:'+resource);

            List<sObject> sObjectsToDML = transformJsonToSObject(jsonBody, resource, log);

            SYS_debug.log('\n\n ------------------------------- \n\n Application Service sObjects to DML:'+sObjectsToDML);
            SYS_debug.log('\n\n ------------------------------- \n\n Application Service externalKeyByResourceMap:'+SYS_DataCache.externalKeyByResourceMap);

            String externalIdFieldAPIName = SYS_DataCacheFactory.externalKeyByResourceMap.get(resource);
            //String externalIdFieldAPIName = log.External_Id_Field_API_Name__c!=NULL?log.External_Id_Field_API_Name__c:'';
            
            for(sObject item: sObjectsToDML) {
                try {
                    item.put('Last_Processed_SYSLog__c', log.Id);
                } catch(Exception e) {
                    throw new SYS_ApplicationServiceException('Last Processed SYSLog field is not implemented : \n '+e.getMessage());
                }
                if( item.get('Id') == NULL && log.WhatId__c != NULL && SYS_DataCacheFactory.obj_type !='Square_Modfier') {
                    item.put('Id', log.WhatId__c);
                }
            }
            if(sObjectsToDML.size() > 0)
                mapLogrecVsObject.put(log, sObjectsToDML[0]);
            
            // Insert the child logs which are picked up by flows
            if (SYS_DataCacheFactory.childRecordsToInsert.size() > 0) {
                SYS_Helper.insertLog(SYS_DataCacheFactory.childRecordsToInsert);
            }
        }
        return ;
    }

    public override void processInboundRecord(Individual log, Map<Individual, sObject> mapLogrecVsObject, List<Individual> partialSysLogs, List<Individual> allChildLogs) {
        
        String jsonBody = '';
        // jsonBody =  SYS_Helper.getDataFrom(log);
        jsonBody =  SYS_Helper.getDataFromNew(log, allChildLogs); 
        jsonBody = preprocessJSONForInbound(log,jsonBody);

        if(SYS_DataCacheFactory.SRIntegrationSetting.Notifications_are_partial__c && 
            log.Is_Notification_Only__c
            ){
            String baseEndpoint = SYS_DataCacheFactory.SRIntegrationSetting.BaseAPIEndPoint__c;
            String getURLPattern = baseEndpoint + SYS_DataCacheFactory.SRIntegrationSetting.GET_URL_Pattern__c;
            
            SYS_NotificationInterface it = 
            (SYS_NotificationInterface)Type.forName(SYS_DataCacheFactory.SRIntegrationSetting.Notification_Wrapper__c).newInstance();
            
            // List<SYS_IntegrationLog__c> insertSysLog = new List<SYS_IntegrationLog__c>();

            for(Map<String,String> rMap:it.getIterator(jsonBody)){
                String getURL = getURLPattern;
                Individual  newSysLog = new Individual();
                for(String key:rMap.keySet()){
                    getURL = getURL.replaceAll('\\{'+key+'\\}',rMap.get(key));
  
                }
                /*--*/SYS_debug.log('=============== '+ getURL);

                newSysLog.Status__c = SYS_Constants.NEW_STATUS;
                newSysLog.HTTP_Method__c = 'GET';
                newSysLog.Callout_URL__c = getURL;
                newSysLog.Type__c = SYS_Constants.OUTBOUND;
                newSysLog.WhatId__c = log.WhatId__c;
                newSysLog.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
                newSysLog.SYS_Operation_Type__c = 'UPSERT';
                newSysLog.How_to_process__c = 'use_custom_apex_handler';
                newSysLog.Custom_Apex_Handler__c = SYS_DataCacheFactory.IntegrationMetadataRequest.get('l0')[0]?.get('apexHandler');
                newSysLog.Parent__c = log.Id;
                newSysLog.Integration_Type__c = log.Integration_Type__c;
                newSysLog.Account_Id__c = log.Account_Id__c;
                partialSysLogs.add(newSysLog);
            }

            
            // if(insertSysLog.size()>0 && SYS_DataCache.enableCheck.get(SYS_DataCache.INT_TYPE.toUpperCase())){
            //     SYS_Helper.insertLog(insertSysLog);
            // }

            // return true;

        }
        else{
            String resource = getResourceFromJSON(log,jsonBody);
            log.Resource__c = resource;
            SYS_debug.log('\n\n ------------------------------- \n\n Application Service resource:'+resource);

            List<sObject> sObjectsToDML = transformJsonToSObject(jsonBody, resource, log);

            SYS_debug.log('\n\n ------------------------------- \n\n Application Service sObjects to DML:'+sObjectsToDML);
            SYS_debug.log('\n\n ------------------------------- \n\n Application Service externalKeyByResourceMap:'+SYS_DataCacheFactory.externalKeyByResourceMap);

            String externalIdFieldAPIName = SYS_DataCacheFactory.externalKeyByResourceMap.get(resource);
            //String externalIdFieldAPIName = log.External_Id_Field_API_Name__c!=NULL?log.External_Id_Field_API_Name__c:'';
            
            for(sObject item: sObjectsToDML) {
                try {
                    item.put('Last_Processed_Log__c', log.Id);
                } catch(Exception e) {
                    throw new SYS_ApplicationServiceException('Last Processed SYSLog field is not implemented : \n '+e.getMessage());
                }
                if( item.get('Id') == NULL && log.WhatId__c != NULL) {
                    item.put('Id', log.WhatId__c);
                }
            }
            if(sObjectsToDML.size() > 0)
                mapLogrecVsObject.put(log, sObjectsToDML[0]);
            
            // Insert the child logs which are picked up by flows
            if (SYS_DataCacheFactory.childRecordsToInsert.size() > 0) {
                SYS_Helper.insertLog(SYS_DataCacheFactory.childRecordsToInsert);
            }
        }
        return ;
    }

    /* 
    ------------------------------------------------------------------------ 
    Override for root Key Removal for Outbound for Customer Outbound
    */
    public override String sanitizeJSONForOutbound(String jsonRecord){

        String finalJSON = jsonRecord.replace('\n',' ');

        String rootKey = '';
        Object jsonObj = JSON.deserializeUntyped(finalJSON);
        if(jsonObj instanceof Map<String,Object>){
            rootKey = new List<String>(((Map<String, Object>)jsonObj).keySet())[0];
        }

        if( (rootKey == 'customer') || (rootKey == 'payment') || (rootKey == 'refund') ) {
            Object newJsonObj = ((Map<String,Object>)jsonObj).get(rootKey);
            jsonObj = newJsonObj;
        }

        //Add Idempotency Key idempotency_key
        String idempotency_key = SYS_Helper.getUUID();
        ((Map<String, Object>)jsonObj).put('idempotency_key', idempotency_key);
        finalJSON = JSON.serialize(jsonObj);

        return finalJSON;
    }

}