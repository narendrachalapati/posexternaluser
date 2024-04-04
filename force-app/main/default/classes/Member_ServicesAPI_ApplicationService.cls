public without sharing class Member_ServicesAPI_ApplicationService extends SYS_ApplicationService {

    public static String RESPONSE = '';
    public static String languageCode = 'en-US';//es-ES
    Map<String, String> languageMap = new Map<String, String>{'en-US' => 'en', 'en' => 'en', 'es-ES' => 'es', 'es' => 'es'};

    public Member_ServicesAPI_ApplicationService() {}

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
        
        //Deserilize JSON and Map Keys for DialogFlow Json
        Map<String, Object> newflatKeyMap = new Map<String, Object>();
        String resource_path = '', additional_action = '', sessionString, currentSessionId, leadsource = '', salesforcerecorduuid = '', phonenumber = '', dateofbirthString = '', firstname = '', lastname = '', accountname = '', stage = '', ambiguity_fields = '', servicesOfferedResponse = '', menuoptions = '';
        Boolean ignoreLog = true, ismemberfound = false, is_ambiguity = false, isphoneverified = false;
        List<sObject> findAccount = new List<sObject>();
        MemberService.Member memberinfo = new MemberService.Member();

        Object responseType = JSON.deserializeUntyped(requestBody);
        if (responseType instanceof Map<String, Object>) {
            newflatKeyMap = (SYS_Helper.getFlatKeys(requestBody, 'A.B')); //
            resource_path = newflatKeyMap.containsKey( 'sessionInfo.parameters.resource_path' ) ? (String) newflatKeyMap.get('sessionInfo.parameters.resource_path') : resource_path;
            additional_action = newflatKeyMap.containsKey( 'sessionInfo.parameters.additional_action' ) ? (String) newflatKeyMap.get('sessionInfo.parameters.additional_action') : additional_action;
            leadsource = newflatKeyMap.containsKey( 'sessionInfo.parameters.leadsource' ) ? (String) newflatKeyMap.get('sessionInfo.parameters.leadsource') : leadsource;
            stage = newflatKeyMap.containsKey('sessionInfo.parameters.stage') ? (String) newflatKeyMap.get('sessionInfo.parameters.stage') : stage;
            Object isphoneverified_obj = newflatKeyMap.containsKey( 'sessionInfo.parameters.isphoneverified' ) ? newflatKeyMap.get('sessionInfo.parameters.isphoneverified') : null;
            isphoneverified = (isphoneverified_obj instanceof Boolean) ?
                (Boolean) isphoneverified_obj :
                ( (isphoneverified_obj instanceof String) ? Boolean.valueOf(String.valueOf(isphoneverified_obj).equalsIgnoreCase('true')) : false);

            phonenumber = newflatKeyMap.containsKey( 'sessionInfo.parameters.phonenumber' ) ? (String) newflatKeyMap.get('sessionInfo.parameters.phonenumber') : phonenumber;
            firstname = newflatKeyMap.containsKey('sessionInfo.parameters.firstname') ? (String) newflatKeyMap.get('sessionInfo.parameters.firstname') : firstname;
            lastname = newflatKeyMap.containsKey('sessionInfo.parameters.lastname') ? (String) newflatKeyMap.get('sessionInfo.parameters.lastname') : lastname;
            dateofbirthString = newflatKeyMap.containsKey( 'sessionInfo.parameters.dateofbirth' ) ? (String) newflatKeyMap.get('sessionInfo.parameters.dateofbirth') : dateofbirthString;
            salesforcerecorduuid = newflatKeyMap.containsKey( 'sessionInfo.parameters.salesforcerecorduuid' ) ? (String) newflatKeyMap.get( 'sessionInfo.parameters.salesforcerecorduuid' ) : salesforcerecorduuid;

            ambiguity_fields = newflatKeyMap.containsKey( 'sessionInfo.parameters.ambiguity_fields' ) ? (String) newflatKeyMap.get('sessionInfo.parameters.ambiguity_fields') : ambiguity_fields;
            Object is_ambiguity_obj = newflatKeyMap.containsKey( 'sessionInfo.parameters.is_ambiguity' ) ? newflatKeyMap.get('sessionInfo.parameters.is_ambiguity') : null;
            is_ambiguity = (is_ambiguity_obj instanceof Boolean) ?
                (Boolean) is_ambiguity_obj :
                ( (is_ambiguity_obj instanceof String) ? Boolean.valueOf(String.valueOf(is_ambiguity_obj).equalsIgnoreCase('true')) : false);

            languageCode = newflatKeyMap.containsKey( 'languageCode' ) ? (String) newflatKeyMap.get( 'languageCode' ) : languageCode;
            languageCode = languageMap.containsKey( languageCode ) ? languageMap.get(languageCode) : 'en';

            sessionString = newflatKeyMap.containsKey('sessionInfo.session') ? (String) newflatKeyMap.get('sessionInfo.session') : '';
            currentSessionId = String.isNotBlank(sessionString) ? sessionString.substringAfterLast('sessions/') : '';
        }
        if (String.isNotBlank(resource_path) && (!newflatKeyMap.isEmpty())) {
            firstname = (firstname != 'null') ? firstname : '';
            lastname = (lastname != 'null') ? lastname : '';
            
            if ( (additional_action == 'findmember') && (String.isNotBlank(salesforcerecorduuid) || String.isNotBlank(phonenumber) || String.isNotBlank(firstname) || String.isNotBlank(lastname)) || String.isNotBlank(dateofbirthString) ) {
                memberinfo = DialogFlow_Helper.findAccount( salesforcerecorduuid, phonenumber, firstname, lastname, dateofbirthString );
                //Found Matching Account Ignore the log and return fullfillment response
                if (memberinfo != NULL && memberinfo.memberRecord != NULL) {
                    salesforcerecorduuid = memberinfo.uuid;
                    firstname = memberinfo.FirstName;
                    lastname = memberinfo.LastName;
                    accountname = memberinfo.Name;
                    phonenumber = memberinfo.PhoneNumberFormatted;
                    stage = memberinfo.Stage;
                    isphoneverified = memberinfo.isphoneverified;
                    ismemberfound = true;

                    if ((stage == 'Lead') && (leadsource == 'Call')) {
                        isphoneverified = true;
                        stage = 'Verified';
                    }

                    sObject updateMember;
                    if (memberinfo != NULL && memberinfo.memberRecord != NULL && memberinfo.memberRecord instanceOf Account) {
                        updateMember = new Account();
                        ((Account)updateMember).Id = (String)memberinfo.memberRecord.get('Id');
                        if (String.isNotBlank(stage)) {
                            ((Account)updateMember).put('Stage__c', stage);
                        }
                        if(isphoneverified == true) {
                            ((Account)updateMember).put('Phone_Verified__c', isphoneverified);
                        }
                        update ((Account)updateMember);
                    } else if (memberinfo != NULL && memberinfo.memberRecord != NULL && memberinfo.memberRecord instanceOf Contact) {
                        updateMember = new Contact();
                        ((Contact)updateMember).Id = (String)memberinfo.memberRecord.get('Id');
                        if (String.isNotBlank(stage)) {
                            ((Contact)updateMember).put('Stage__c', stage);
                        }
                        if(isphoneverified == true) {
                            ((Contact)updateMember).put('Phone_Verified__c', isphoneverified);
                        }
                        update ((Contact)updateMember);
                    }

                    servicesOfferedResponse = getSchedulingServicesResponse(stage);
                    servicesOfferedResponse = (String.isNotBlank(servicesOfferedResponse)) ? ',' + servicesOfferedResponse : servicesOfferedResponse;

                    menuoptions = getMenuOptionParameters(memberinfo);
                    menuoptions = String.isNotBlank(menuoptions) ? ', ' + menuoptions : '';
                    //Fullfillment response for Dialogflow CX
                    RESPONSE = '{"sessionInfo":{"parameters":{"currentSessionId":"' + currentSessionId + '","ismemberfound":' + ismemberfound + ',"salesforcerecorduuid":"' + salesforcerecorduuid + '","accountname":"' + accountname + '","stage":"' + stage + '","isphoneverified":' + isphoneverified + ',"firstname":"' + firstname + '","lastname":"' + lastname + '","phonenumber":"' + phonenumber + '"' + servicesOfferedResponse + '' + menuoptions + '}}}';
                } else {
                    //Not Found Matching Account //
                    if (String.isNotBlank(phonenumber)) {
                        // Create Account With Phonenumber
                        phonenumber = String.isNotBlank(phonenumber) ? phonenumber.replace('.', '') : '';
                        phonenumber = String.isNotBlank(phonenumber) ? phonenumber.replace('+', '') : '';
                    }
                    accountname = (String.isNotBlank(firstname) ? firstname : '') + '' + (String.isNotBlank(lastname) ? ' ' + lastname : '');
                    sObject saveMember;
                    if (SYS_DataCacheFactory.accountId == NULL) {
                        saveMember = new Account();
                        ((Account)saveMember).put('Lead_Source__c', leadsource);
                        ((Account)saveMember).put('Stage__c', (leadsource == 'Call') ? 'Verified' : 'Lead' );
                        ((Account)saveMember).put('Phone_Verified__c', (leadsource == 'Call') ? true : isphoneverified );
                        ((Account)saveMember).put('Name', String.isNotBlank(accountname) ? accountname : phonenumber );
                        ((Account)saveMember).put('Phone', phonenumber );
                        ((Account)saveMember).put('First_Name__c', firstname );
                        ((Account)saveMember).put('Last_Name__c', String.isNotBlank(lastname) ? lastname : phonenumber );
                        if(is_ambiguity == true) {
                            ((Account)saveMember).put('Ambiguity_Fields__c', ambiguity_fields );
                            ((Account)saveMember).put('Is_Ambiguity__c', is_ambiguity );
                        }
                        if (String.isNotBlank(dateofbirthString)) {
                            ((Account)saveMember).put('Date_of_Birth__c', Date.valueOf(dateofbirthString) );
                        }
                        insert ((Account)saveMember);
                    } 
                    else if (SYS_DataCacheFactory.accountId != NULL) {
                        saveMember = new Contact();
                        ((Contact)saveMember).put('Lead_Source__c', leadsource );
                        ((Contact)saveMember).put('Stage__c', (leadsource == 'Call') ? 'Verified' : 'Lead' );
                        ((Contact)saveMember).put('Phone_Verified__c', (leadsource == 'Call') ? true : isphoneverified );
                        
                        ((Contact)saveMember).put('Phone_Number__c', phonenumber );
                        ((Contact)saveMember).put('FirstName', firstname );
                        ((Contact)saveMember).put('LastName', String.isNotBlank(lastname) ? lastname : phonenumber );
                        ((Contact)saveMember).put('AccountId', SYS_DataCacheFactory.accountId );
                        if(is_ambiguity == true) {
                            ((Contact)saveMember).put('Ambiguity_Fields__c', ambiguity_fields );
                            ((Contact)saveMember).put('Is_Ambiguity__c', is_ambiguity );
                        }
                        if (String.isNotBlank(dateofbirthString)) {
                            ((Contact)saveMember).put('Birthdate', Date.valueOf(dateofbirthString) );
                        }
                        insert ((Contact)saveMember);
                    }
                        
                    if ((saveMember != null)) {
                        // Check if Account was Created or not
                        // Refetch Created Record
                        memberinfo = DialogFlow_Helper.findAccount( (String)saveMember.get('Id'), phonenumber, firstname, lastname, dateofbirthString );
                        salesforcerecorduuid = (String.isNotBlank(memberinfo.uuid)) ? memberinfo.uuid : '';
                        firstname = (String.isNotBlank(memberinfo.FirstName)) ? memberinfo.FirstName : '';
                        lastname = (String.isNotBlank(memberinfo.LastName)) ? memberinfo.LastName : '';
                        accountname = (String.isNotBlank(memberinfo.Name)) ? memberinfo.Name : '';
                        phonenumber = (String.isNotBlank(memberinfo.PhoneNumberFormatted)) ? memberinfo.PhoneNumberFormatted : '';
                        stage = (String.isNotBlank(memberinfo.Stage)) ? memberinfo.Stage : '';
                        isphoneverified = memberinfo.isphoneverified != NULL ? memberinfo.isphoneverified : false;

                        servicesOfferedResponse = getSchedulingServicesResponse(stage);
                        servicesOfferedResponse = (String.isNotBlank(servicesOfferedResponse)) ? ',' + servicesOfferedResponse : servicesOfferedResponse;

                        menuoptions = (findAccount.size() > 0) ? getMenuOptionParameters(memberinfo) : '';
                        menuoptions = String.isNotBlank(menuoptions) ? ', ' + menuoptions : '';
                    }
                    
                    //Fullfillment response for Dialogflow CX
                    RESPONSE = '{"sessionInfo":{"parameters":{"currentSessionId":"' + currentSessionId + '","ismemberfound":' + ismemberfound + ',"salesforcerecorduuid":"' + salesforcerecorduuid + '","accountname":"' + accountname + '","stage":"' + stage + '","isphoneverified":' + isphoneverified + ',"firstname":"' + firstname + '","lastname":"' + lastname + '","phonenumber":"' + phonenumber + '"' + servicesOfferedResponse + '' + menuoptions + '}}}';
                }
            } else { //Handle Fetch Services
            //Fullfillment response for Dialogflow CX

            servicesOfferedResponse = getSchedulingServicesResponse(stage);
            servicesOfferedResponse = (String.isNotBlank(servicesOfferedResponse)) ? ',' + servicesOfferedResponse : servicesOfferedResponse;

            RESPONSE = '{"sessionInfo":{"parameters":{"currentSessionId":"' + currentSessionId + '"' + servicesOfferedResponse + '}}}';
            }
        }
        
        //Check criteria when chars more than 1M
        if ( requestBody != null && requestBody.length() > SYS_Constants.TEXT_AREA_MAX_SIZE * 10 ) {
            logAfterPartition = SYS_Helper.getLogsAfterPartition(requestBody);
            if (logAfterPartition != null && logAfterPartition.size() > 0) {
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
        if (algo != null && algo != '')
            log.Request_Digest__c = generateHash(requestBody, algo);
        
        if (SYS_DataCacheFactory.integrationSetting.Notifications_are_partial__c)
            log.Is_Notification_Only__c = true;
        
        log.Type__c = 'INBOUND';
        log.SYS_Operation_Type__c = getOperationTypeFor(method);
        log.Flat_Key_for_Resource__c = SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource__c;
        log.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
        log.Status__c = 'NEW';
        if ((ignoreLog == true)) {
            log.How_to_process__c = 'ignore_log';
        } else {
            log.How_to_process__c = 'use_custom_apex_handler';
        }
        log.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
        
        //new fields
        log.Account_Id__c = SYS_DataCacheFactory.accountId;
        log.Integration_Type__c = SYS_DataCacheFactory.integrationSetting?.Integration_Type__c;
        
        List<SYS_IntegrationLog__c> returnVal = new List<SYS_IntegrationLog__c>();
        returnVal.add(log);
        if (logAfterPartition != null && logAfterPartition.size() > 0) {
            log.Status__c = 'PENDING_PARTITIONED_LOOKUP';
            for (integer i = 1; i < logAfterPartition.size(); i++) {
                returnVal.add(logAfterPartition[i]);
            }
        }
        
        return returnVal;
    }

    /**
     * This hook is called from insertWebhookLog methods and webservice.
    * Default is to set the response body with incoming request
    * Zero Arguments. Relies on Integration Setting in DataCache and RestContext
    * Override if custom handler is required after successful log creation
    */
    public override void setSuccessHttpResponse() {
        SYS_IntegrationLog__c responseLog = (SYS_DataCacheFactory.log != null) ? SYS_DataCacheFactory.log : new SYS_IntegrationLog__c();
        String recordWhattId = (responseLog?.whatid__c != null) ? responseLog.whatid__c : null;
        if (RestContext.response != null) {
            String requestJson = RestContext.request.requestBody.toString();
            if (String.isNotBlank(requestJson)) {
                Map<String, Object> newflatKeyMap = new Map<String, Object>();
                String dialogflowFullFillmentResponse;
                
                String existingLogJson = SYS_Helper.getDataFrom(responseLog);
                requestJson = String.isNotBlank(existingLogJson) ? existingLogJson : requestJson;
                
                Object responseType = JSON.deserializeUntyped(requestJson);
                if (responseType instanceof Map<String, Object>) {
                    newflatKeyMap = (SYS_Helper.getFlatKeys(requestJson, 'A.B'));
                }
                if ((!newflatKeyMap.isEmpty())) {
                    //Fullfillment response for Dialogflow CX
                    dialogflowFullFillmentResponse = RESPONSE;
                    RestContext.response.addHeader('Content-Type', 'application/json');
                    RestContext.response.responseBody = Blob.valueOf(dialogflowFullFillmentResponse);
                } else {
                    RestContext.response.responseBody = Blob.valueOf(requestJson);
                }
            } else {
                RestContext.response.responseBody = Blob.valueOf(requestJson);
            }
        }
    }

    public String getSchedulingServicesResponse(String memberStage) {
        List<Product__c> allSchedulingProductsList = DialogFlow_Helper.getSchedulingProducts('');
        List<Product__c> schedulingProductsList = DialogFlow_Helper.getSchedulingProducts(memberStage);
        
        Set<String> all_services_uuid_list = new Set<String>();
        Set<String> services_uuid_list = new Set<String>();
        Set<String> services_name_list = new Set<String>();
        Set<String> all_services_name_list = new Set<String>();

        List<String> status_values_list = new List<String>();
        String servicesOfferedDialogFlowResponse, services_name_delimited = '', services_uuid_delimited = '', services_offered_name_ssml = '', services_offered_name_text = '' , stageBasedServicesMap_JSON = '';
        Integer services_count = 0;
        Boolean initMap = true;
        Map<String, String> all_services_uuid_name_map = new Map<String, String>();
        Map<String, Set<String>> stageBasedServicesSetMap = new Map<String, Set<String>>();
        Map<String, Map<String, Object>> stageBasedServicesMap = new Map<String, Map<String, Object>>();
        Map<String, Object> stage_based_params = new Map<String, Object>();

        //Fetch List of Stages
        Schema.DescribeFieldResult fieldResult = Product__c.Excluded_Stage__c.getDescribe();
        List<Schema.PicklistEntry> productValueSet = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry itervalueset: productValueSet) {
            status_values_list.add(itervalueset.getValue());
        }

        //Store Product UUID and Name map
        if (allSchedulingProductsList.size() > 0) {
            for (Product__c iterProdrecord: allSchedulingProductsList) {
                all_services_uuid_name_map.put(iterProdrecord.UUID__c, iterProdrecord.Name);
                all_services_uuid_list.add(iterProdrecord.UUID__c);
            }
        }

        //Iterate and Filter based on Excluded Stage
        for (String iterStage : status_values_list) {
            if (allSchedulingProductsList.size() > 0) {
                //Reset for Each Stage Key
                services_uuid_list = new Set<String>();

                for (Product__c iterProdrecord: allSchedulingProductsList) {
                    //remove Excludede stages
                    if (iterProdrecord.Excluded_Stage__c != null && (iterProdrecord.Excluded_Stage__c.contains(iterStage) || iterProdrecord.Excluded_Stage__c == '')) {
                        continue;
                    }
                    services_uuid_list.add(iterProdrecord.UUID__c);
                }
                stageBasedServicesSetMap.put(iterStage, services_uuid_list);
            }
        }

        //Store Default all stage value
        if(initMap == true) {
            initMap = false;
            stageBasedServicesSetMap.put('all', all_services_uuid_list);
        }

        // Format List<String> to Map<String, String>
        for (String stage_key : stageBasedServicesSetMap.keySet()) {
            services_offered_name_ssml = '';
            services_offered_name_text = '';
            services_count = 0;
            //Use the list constructor to convert a set of strings to a list of strings
            List<String> stageBasedServicesUUIDList = new List<String>(stageBasedServicesSetMap.get(stage_key));
            List<String> stageBasedServicesNamesList = new List<String>();

            //Create List of Stage Based Services Name
            for (String iter_service_uuid : stageBasedServicesUUIDList) {
                stageBasedServicesNamesList.add(all_services_uuid_name_map.get(iter_service_uuid));
            }

            //Store size value
            services_count = stageBasedServicesUUIDList.size();
            services_uuid_delimited = String.join(stageBasedServicesUUIDList, ',');
            services_name_delimited = String.join(stageBasedServicesNamesList, ',');
            services_offered_name_ssml = String.join(stageBasedServicesNamesList, ' <break time="300ms" />,');
            services_offered_name_text = String.join(stageBasedServicesNamesList, ', ');

            stageBasedServicesMap.put(stage_key, new Map <String, Object> {
                'services_count' => services_count,
                'services_uuid_delimited' => services_uuid_delimited,
                'services_name_delimited' => services_name_delimited,
                'services_offered_name_ssml' => services_offered_name_ssml,
                'services_offered_name_text' => services_offered_name_text
            });
        }

        //Store Map as JSON 
        if(stageBasedServicesMap.size() > 0) {
            stageBasedServicesMap_JSON = JSON.serialize(stageBasedServicesMap);
        }

        //Send Response
        if ( (stageBasedServicesMap.size() > 0) && (String.isNotBlank(stageBasedServicesMap_JSON)) ) {
            memberStage = String.isNotBlank(memberStage) ? memberStage : 'all';
            stage_based_params = stageBasedServicesMap.containsKey(memberStage) ? stageBasedServicesMap.get(memberStage) : null;
            services_uuid_delimited =  stage_based_params.containsKey('services_uuid_delimited') ? (String)stage_based_params.get('services_uuid_delimited') : '';
            services_name_delimited = stage_based_params.containsKey('services_name_delimited') ? (String)stage_based_params.get('services_name_delimited') : '';
            services_count = stage_based_params.containsKey('services_count') ?  (Integer)stage_based_params.get('services_count') : 0;
            servicesOfferedDialogFlowResponse = '"services_uuid_delimited":"' + services_uuid_delimited + '","services_name_delimited":"' + services_name_delimited + '","services_count":' + services_count + ',"stage_based_services":' + stageBasedServicesMap_JSON;
        } else {
            servicesOfferedDialogFlowResponse = '"services_uuid_delimited":"' + services_uuid_delimited + '","services_name_delimited":"' + services_name_delimited + '","services_count":' + services_count + ',"stage_based_services":' + stageBasedServicesMap_JSON;
        }
        
        return servicesOfferedDialogFlowResponse;
    }

    public String getMenuOptionParameters(MemberService.Member memberinfo) {
        String labreport_names_delimited = '', labreport_links_delimited = '', menu_parameters_response = '';
        List<String> labreport_names_list = new List<String>();
        List<String> labreport_links_list = new List<String>();
        Decimal balance = 0;
        Integer labreportscount = 0;
        String appointmentlink ;
        String profileupdatelink = DialogFlow_Helper.getProfileUpdateLink( memberinfo.Id );

        if (memberinfo != NULL && memberinfo.memberRecord != NULL && memberinfo.memberRecord instanceOf Account) {
            balance = (Decimal) memberinfo.memberRecord.get('Balance__c');
            appointmentlink = (String) memberinfo.memberRecord.get('Schedule_Appointment_Link__c');
        } else if (memberinfo != NULL && memberinfo.memberRecord != NULL && memberinfo.memberRecord instanceOf Contact) {
            balance = (Decimal) memberinfo.memberRecord.get('Balance__c');
            appointmentlink = (String) memberinfo.memberRecord.get('Appointment_Link__c');
        }
        
        //Fetch Patient Reports
        //TO-DO Add member specific Filter
    //   String patientReportsQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Patient_Report__c') +
    //                               ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
    //                               ' FROM Patient_Report__c ORDER BY createdDate DESC LIMIT 1000';
        String patientReportsQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Patient_Report__c') +
                                    ' FROM Patient_Report__c ORDER BY createdDate DESC LIMIT 1000';
        List<Patient_Report__c> patientReportsList = Database.query( patientReportsQuery );
        labreportscount = patientReportsList.size();
        for (Patient_Report__c tempReportRecord : patientReportsList) {
            labreport_names_list.add(tempReportRecord.Report_Name__c);
            labreport_links_list.add(tempReportRecord.Report_Link__c);
        }
        
        if (labreport_names_list.size() > 0) {
            labreport_names_delimited = String.join(labreport_names_list, ',');
        }
        if (labreport_links_list.size() > 0) {
            labreport_links_delimited = String.join(labreport_links_list, ',');
        }
        
        menu_parameters_response = '"appointmentlink" : "' + appointmentlink + '" , "profileupdatelink" : "' + profileupdatelink + '", "labreport_names_delimited" : "' + labreport_names_delimited + '", "labreport_links_delimited" : "' + labreport_links_delimited + '", "balance" : "' + balance + '","labreportscount":' + labreportscount;
        return menu_parameters_response;
    }
}