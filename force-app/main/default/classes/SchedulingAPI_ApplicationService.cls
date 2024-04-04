public without sharing class SchedulingAPI_ApplicationService extends SYS_ApplicationService {

    public static String RESPONSE = '';
    public static Integer messagesLimitPerPage = 3;
    public static String languageCode = 'en-US';//es-ES
    public static String timeZoneName = 'America/Los_Angeles';
    public static Boolean is_datetime_range = false;
    Map<String, String> languageMap = new Map<String, String>{'en-US' => 'en', 'en' => 'en', 'es-ES' => 'es', 'es' => 'es'};
    
    public SchedulingAPI_ApplicationService() { }

    public class SchedulingAPI_ApplicationServiceException extends Exception { }

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
        String resource_path;
        Boolean ignoreLog = true;
        Boolean isRecurringEvent = false;
        String rrule = '', recurringEventStartDate = '', recurringEventEndDate = '';

        Object responseType = JSON.deserializeUntyped(requestBody);
        if(responseType instanceof Map<String,Object>){
            newflatKeyMap = (SYS_Helper.getFlatKeys(requestBody ,'A.B'));  //
            resource_path = newflatKeyMap.containsKey('sessionInfo.parameters.resource_path') ? (String)newflatKeyMap.get('sessionInfo.parameters.resource_path') : '';

            isRecurringEvent = newflatKeyMap.containsKey('sessionInfo.parameters.is_recurring_event') ? (Boolean)newflatKeyMap.get('sessionInfo.parameters.is_recurring_event') : false;
            rrule = newflatKeyMap.containsKey('sessionInfo.parameters.rrule') ? (String)newflatKeyMap.get('sessionInfo.parameters.rrule') : '';
            // recurringEventStartDate =  CalendarService.getDateTimeISOString( 
            //     newflatKeyMap.containsKey('sessionInfo.parameters.recurring_event_start_date') ? 
            //     (String)newflatKeyMap.get('sessionInfo.parameters.recurring_event_start_date') : ''
            //     );
            // recurringEventEndDate = CalendarService.getDateTimeISOString( 
            //     newflatKeyMap.containsKey('sessionInfo.parameters.recurring_event_end_date') ? 
            //     (String)newflatKeyMap.get('sessionInfo.parameters.recurring_event_end_date') : ''
            //     );

            languageCode = newflatKeyMap.containsKey( 'languageCode' ) ? (String) newflatKeyMap.get( 'languageCode' ) : languageCode;
            languageCode = languageMap.containsKey( languageCode ) ? languageMap.get(languageCode) : 'en';

            if( (resource_path == 'getlatestavailability') || (resource_path == 'checkandbookappointment') || (resource_path == 'membernotification') ){
                RESPONSE = getAvailableSlotsResponse(newflatKeyMap);
            } 
            
            if ( (resource_path == 'fetchupcomingappointment') ) {
                RESPONSE = fetchUpcomingAppointmentsResponse(newflatKeyMap);
            } 

            if ( (resource_path == 'cancelappointment') ) {
                RESPONSE = fetchCancelAppointmentsResponse(newflatKeyMap);
            } 
            
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

        if(SYS_DataCacheFactory.integrationSetting.Notifications_are_partial__c)
            log.Is_Notification_Only__c = true;

        log.Type__c = 'INBOUND';
        log.SYS_Operation_Type__c = getOperationTypeFor(method);
        // log.Flat_Key_for_Resource__c = SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource__c;
        // log.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
        log.Flat_Key_for_Resource__c = 'sessionInfo.parameters.resource_path';
        log.Integration_Setting__c = 'SchedulingAPI';
        log.Status__c = 'NEW';
        if( (ignoreLog == true) ){
            log.How_to_process__c = 'ignore_log';
        } else {
            log.How_to_process__c = 'use_custom_apex_handler';
        }
        // log.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
        log.Custom_Apex_Handler__c = 'SchedulingAPI_ApplicationService';

        //new fields
        log.Account_Id__c = SYS_DataCacheFactory.accountId;
        // log.Integration_Type__c = SYS_DataCacheFactory.integrationSetting?.Integration_Type__c;
        log.Integration_Type__c = 'SchedulingAPI';

        List<SYS_IntegrationLog__c> returnVal = new List<SYS_IntegrationLog__c>();
        returnVal.add(log);
        if(logAfterPartition != NULL && logAfterPartition.size() > 0) {
            log.Status__c = 'PENDING_PARTITIONED_LOOKUP';
            for(integer i = 1 ; i < logAfterPartition.size() ; i++) {
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
    public override void setSuccessHttpResponse(){
        SYS_IntegrationLog__c responseLog = (SYS_DataCacheFactory.log != null) ? SYS_DataCacheFactory.log : new SYS_IntegrationLog__c();
        String recordWhattId = (responseLog?.whatid__c != null) ? responseLog.whatid__c : null;
        if(RestContext.response!=NULL){
            String requestJson = RestContext.request.requestBody.toString();
            if (String.isNotBlank(requestJson) ){
                Map<String, Object> newflatKeyMap = new Map<String, Object>();
                String sessionString, currentSessionId, salesforceRecordId, dialogflowFullFillmentResponse;
                Boolean isauthorized = false;

                String existingLogJson = SYS_Helper.getDataFrom(responseLog);
                requestJson = String.isNotBlank(existingLogJson) ? existingLogJson : requestJson;                

                Object responseType = JSON.deserializeUntyped(requestJson);
                if(responseType instanceof Map<String,Object>){
                    newflatKeyMap = (SYS_Helper.getFlatKeys(requestJson ,'A.B')); 
                }
                if( (!newflatKeyMap.isEmpty()) ){
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

    public String fetchCancelAppointmentsResponse(Map<String, Object> newflatKeyMap) {
        String resource_path = '', salesforcerecorduuid = '', additional_action = '', selected_appointment_uuid = '', dialogflowFullFillmentResponse = '', cancelled_appointment_datetime = '', cancelled_appointment_service = '';
        Boolean is_cancelled = false;

        timeZoneName = String.isNotBlank(timeZoneName) ? timeZoneName : 'America/Los_Angeles';

        resource_path = newflatKeyMap.containsKey('sessionInfo.parameters.resource_path') ? (String)newflatKeyMap.get('sessionInfo.parameters.resource_path') : '';
        salesforcerecorduuid = newflatKeyMap.containsKey('sessionInfo.parameters.salesforcerecorduuid') ? (String)newflatKeyMap.get('sessionInfo.parameters.salesforcerecorduuid') : '';
        additional_action = newflatKeyMap.containsKey('sessionInfo.parameters.additional_action') ? (String)newflatKeyMap.get('sessionInfo.parameters.additional_action') : '';
        selected_appointment_uuid = newflatKeyMap.containsKey('sessionInfo.parameters.selected_appointment_uuid') ? (String)newflatKeyMap.get('sessionInfo.parameters.selected_appointment_uuid') : '';

        if( String.isNotBlank(selected_appointment_uuid) ){
            Appointment_Scheduling__c fetchAppointment = DialogFlow_Helper.cancelAppointment(selected_appointment_uuid);
            if(fetchAppointment.Status__c == 'cancelled') {
                is_cancelled = true;
                Datetime cancelled_Appointment_StartDate = fetchAppointment.StartDate__c;
                cancelled_appointment_datetime = (cancelled_Appointment_StartDate != NULL) ? cancelled_Appointment_StartDate.format('yyyy-MM-dd HH:mm:ss:ssZ', timeZoneName) : ''; // 2023-10-17 06:04:53:53-0700
                cancelled_appointment_service = String.isNotBlank(fetchAppointment.Product__c) ? fetchAppointment.Product__r.Name : ''; // Consultation
            }
        }

        //Fullfillment response for Dialogflow CX
        dialogflowFullFillmentResponse = '{ "sessionInfo": { "parameters": { "is_cancelled": "' + is_cancelled + '", "cancelled_appointment_datetime": "' + cancelled_appointment_datetime + '", "cancelled_appointment_service": "' + cancelled_appointment_service + '" } } }';
        
        return dialogflowFullFillmentResponse;
    }

    public String fetchUpcomingAppointmentsResponse(Map<String, Object> newflatKeyMap) {
        String resource_path, salesforcerecorduuid, dialogflowFullFillmentResponse, upcoming_appointments_slots_delimited, upcoming_appointments_uuid_delimited, upcoming_appointments_service_uuid_delimited, upcoming_appointments_service_name_delimited;
        Integer upcoming_appointments_count = 0;
        List<String> upcoming_appointments_slots_list = new List<String>();
        List<String> upcoming_appointments_uuid_list = new List<String>();

        List<String> upcoming_appointments_service_uuid_list = new List<String>();
        List<String> upcoming_appointments_service_name_list = new List<String>();
        Boolean hasUpcomingAppointments = false;
        
        timeZoneName = String.isNotBlank(timeZoneName) ? timeZoneName : 'America/Los_Angeles';

        resource_path = newflatKeyMap.containsKey('sessionInfo.parameters.resource_path') ? (String)newflatKeyMap.get('sessionInfo.parameters.resource_path') : '';
        salesforcerecorduuid = newflatKeyMap.containsKey('sessionInfo.parameters.salesforcerecorduuid') ? (String)newflatKeyMap.get('sessionInfo.parameters.salesforcerecorduuid') : '';

        List<Appointment_Scheduling__c> upcomingAppointments = DialogFlow_Helper.getUpcomingAppointments(salesforcerecorduuid);
        if( upcomingAppointments.size() > 0 ) {
            hasUpcomingAppointments = true;
            upcoming_appointments_count = upcomingAppointments.size();

            for(Appointment_Scheduling__c iterUpcomingAppointment : upcomingAppointments) {
                upcoming_appointments_uuid_list.add(iterUpcomingAppointment.UUID__c);
                upcoming_appointments_service_uuid_list.add(iterUpcomingAppointment.Product__r.UUID__c);
                upcoming_appointments_service_name_list.add(iterUpcomingAppointment.Product__r.Name);
                Datetime iterAppointmentStartDateTime = iterUpcomingAppointment.StartDate__c;
                //TO DO Use USer Timezone
                String iterAppointmentStartDateTimeString = iterAppointmentStartDateTime.format('YYYY-MM-dd HH:mm:ss', timeZoneName);
                upcoming_appointments_slots_list.add(iterAppointmentStartDateTimeString);

            }

            //generate delimited string, and fetch more option based on size
            upcoming_appointments_uuid_delimited = String.join(upcoming_appointments_uuid_list, ',');
            upcoming_appointments_slots_delimited = String.join(upcoming_appointments_slots_list, ',');
            upcoming_appointments_service_uuid_delimited = String.join(upcoming_appointments_service_uuid_list, ',');
            upcoming_appointments_service_name_delimited = String.join(upcoming_appointments_service_name_list, ',');
            
            dialogflowFullFillmentResponse = '{ "sessionInfo": { "parameters": { "hasupcomingappointments": "' + hasUpcomingAppointments + '", "upcoming_appointments_uuid_delimited": "' + upcoming_appointments_uuid_delimited + '", "upcoming_appointments_slots_delimited": "' + upcoming_appointments_slots_delimited + '", "upcoming_appointments_service_uuid_delimited": "' + upcoming_appointments_service_uuid_delimited + '", "upcoming_appointments_service_name_delimited": "' + upcoming_appointments_service_name_delimited + '", "upcoming_appointments_count": ' + upcoming_appointments_count + ' } } }';
        } else {
            //Fullfillment response for Dialogflow CX
            dialogflowFullFillmentResponse = '{ "sessionInfo": { "parameters": { "hasupcomingappointments": "' + hasUpcomingAppointments + '" } } }';
        }

        return dialogflowFullFillmentResponse;
    }

    public String getAvailableSlotsResponse(Map<String, Object> newflatKeyMap) {
        String resource_path = '', sessionString = '', currentSessionId = '', leadsource = '', salesforcerecorduuid = '', phonenumber = '', dateofbirthString = '', productuuid = '', startDateTime = '', appointment_date = '', appointment_startdatetime = '', appointment_enddatetime = '', scheduling_mode = '', selected_appointment_uuid = '', additional_action = 'latest_availability', dialogflowFullFillmentResponse = '', response_ssmltext = '', latest_available_slot_list = '';

        Integer no_of_days_forward_to_fetch = 1;
        Boolean isSlotAvailable = false;
        
        timeZoneName = String.isNotBlank(timeZoneName) ? timeZoneName : 'America/Los_Angeles';

        resource_path = newflatKeyMap.containsKey('sessionInfo.parameters.resource_path') ? (String)newflatKeyMap.get('sessionInfo.parameters.resource_path') : resource_path;
        leadsource = newflatKeyMap.containsKey('sessionInfo.parameters.leadsource') ? (String)newflatKeyMap.get('sessionInfo.parameters.leadsource') : leadsource;
        phonenumber = newflatKeyMap.containsKey('sessionInfo.parameters.phonenumber') ? (String)newflatKeyMap.get('sessionInfo.parameters.phonenumber') : phonenumber;
        dateofbirthString = newflatKeyMap.containsKey('sessionInfo.parameters.dateofbirth') ? (String)newflatKeyMap.get('sessionInfo.parameters.dateofbirth') : dateofbirthString;
        salesforcerecorduuid = newflatKeyMap.containsKey('sessionInfo.parameters.salesforcerecorduuid') ? (String)newflatKeyMap.get('sessionInfo.parameters.salesforcerecorduuid') : salesforcerecorduuid;

        is_datetime_range = newflatKeyMap.containsKey('sessionInfo.parameters.is_datetime_range') ? (Boolean)newflatKeyMap.get('sessionInfo.parameters.is_datetime_range') : is_datetime_range;

        sessionString = newflatKeyMap.containsKey('sessionInfo.session') ? (String)newflatKeyMap.get('sessionInfo.session') : sessionString;
        currentSessionId = String.isNotBlank(sessionString) ? sessionString.substringAfterLast('sessions/') : currentSessionId;

        productuuid = newflatKeyMap.containsKey('sessionInfo.parameters.selected_service_uuid') ? (String)newflatKeyMap.get('sessionInfo.parameters.selected_service_uuid') : productuuid;

        no_of_days_forward_to_fetch = newflatKeyMap.containsKey('sessionInfo.parameters.number_of_days_forward_to_fetch') ? Integer.valueOf(newflatKeyMap.get('sessionInfo.parameters.number_of_days_forward_to_fetch')) : no_of_days_forward_to_fetch;
        additional_action = newflatKeyMap.containsKey('sessionInfo.parameters.additional_action') ? (String)newflatKeyMap.get('sessionInfo.parameters.additional_action') : additional_action;
        scheduling_mode = newflatKeyMap.containsKey('sessionInfo.parameters.scheduling_mode') ? (String)newflatKeyMap.get('sessionInfo.parameters.scheduling_mode') : scheduling_mode;
        selected_appointment_uuid = newflatKeyMap.containsKey('sessionInfo.parameters.selected_appointment_uuid') ? (String)newflatKeyMap.get('sessionInfo.parameters.selected_appointment_uuid') : selected_appointment_uuid;

        appointment_date = newflatKeyMap.containsKey('sessionInfo.parameters.appointment_date') ? (String)newflatKeyMap.get('sessionInfo.parameters.appointment_date') : appointment_date; //2023-10-11 09:00:00-0700

        appointment_date = String.isNotBlank(appointment_date) ? appointment_date.substring(0, appointment_date.length() - 2) + ':' + appointment_date.substring(appointment_date.length() - 2) : appointment_date;
        System.debug('appointment_date Formatted ' + appointment_date); //2023-10-11 09:00:00-07:00
        //Convert Datetime String to UTC
        Datetime appointment_date_UTC = freeBusyResponseWrapper.formatDateTime(appointment_date, 'YYYY-MM-DD hh:mm:ss_zh:zm');
        System.debug('appointment_date_UTC ' + appointment_date_UTC); //2023-10-11 16:00:00
        String appointment_date_UTC_String = appointment_date_UTC.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        System.debug('appointment_date_UTC_String ' + appointment_date_UTC_String); //2023-10-11T16:00:00.000Z


        appointment_startdatetime = newflatKeyMap.containsKey('sessionInfo.parameters.appointment_startdatetime') ? (String)newflatKeyMap.get('sessionInfo.parameters.appointment_startdatetime') : appointment_startdatetime;//2023-10-11 09:00:00-0700
        appointment_startdatetime = String.isNotBlank(appointment_startdatetime) ? appointment_startdatetime.substring(0, appointment_startdatetime.length() - 2) + ':' + appointment_startdatetime.substring(appointment_startdatetime.length() - 2) : appointment_startdatetime;//2023-10-11 09:00:00-07:00
        System.debug('appointment_startdatetime Formatted ' + appointment_startdatetime);
        //Convert Datetime String to UTC
        Datetime appointment_startdatetime_UTC = String.isNotBlank(appointment_startdatetime) ? freeBusyResponseWrapper.formatDateTime(appointment_startdatetime, 'YYYY-MM-DD hh:mm:ss_zh:zm') : NULL;
        System.debug('appointment_startdatetime_UTC ' + appointment_startdatetime_UTC); //2023-10-11 16:00:00
        String appointment_startdatetime_UTC_String = (appointment_startdatetime_UTC != NULL) ? appointment_startdatetime_UTC.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') : appointment_startdatetime;
        System.debug('appointment_startdatetime_UTC_String ' + appointment_startdatetime_UTC_String); //2023-10-11T16:00:00.000Z
        
        appointment_enddatetime = newflatKeyMap.containsKey('sessionInfo.parameters.appointment_enddatetime') ? (String)newflatKeyMap.get('sessionInfo.parameters.appointment_enddatetime') : appointment_enddatetime;//2023-10-11 09:00:00-0700
        appointment_enddatetime = String.isNotBlank(appointment_enddatetime) ? appointment_enddatetime.substring(0, appointment_enddatetime.length() - 2) + ':' + appointment_enddatetime.substring(appointment_enddatetime.length() - 2) : appointment_enddatetime;//2023-10-11 09:00:00-07:00
        System.debug('appointment_enddatetime Formatted ' + appointment_enddatetime);
        //Convert Datetime String to UTC
        Datetime appointment_enddatetime_UTC = String.isNotBlank(appointment_enddatetime) ? freeBusyResponseWrapper.formatDateTime(appointment_enddatetime, 'YYYY-MM-DD hh:mm:ss_zh:zm') : NULL;
        System.debug('appointment_enddatetime_UTC ' + appointment_enddatetime_UTC); //2023-10-11 16:00:00
        String appointment_enddatetime_UTC_String = (appointment_enddatetime_UTC != NULL) ? appointment_enddatetime_UTC.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') : appointment_enddatetime;
        System.debug('appointment_enddatetime_UTC_String ' + appointment_enddatetime_UTC_String); //2023-10-11T16:00:00.000Z
        
        if( String.isNotBlank(appointment_startdatetime) && String.isNotBlank(appointment_enddatetime) && (appointment_startdatetime_UTC > appointment_enddatetime_UTC ) ) {
            appointment_enddatetime_UTC_String = NULL;
        }

        if ( String.isNotBlank(salesforcerecorduuid) && String.isNotBlank(productuuid) && String.isNotBlank(appointment_date_UTC_String) ) { //Check if selected slot is available or Not Based on resource type
            List<DateTime> availableSlots = new List<DateTime>();

            //Create Binary Search Availability SSML
            if ( (resource_path == 'getlatestavailability') && (additional_action == 'binary_search') ) { 
                dialogflowFullFillmentResponse = generateBinarySearchAvailableSlotsResponse(salesforcerecorduuid, productuuid, appointment_date_UTC_String, appointment_startdatetime_UTC_String, appointment_enddatetime_UTC_String, additional_action);                
            }

            if( (resource_path == 'checkandbookappointment') ) {
                dialogflowFullFillmentResponse = generateAppointmentBookingResponse(salesforcerecorduuid, productuuid, appointment_date_UTC_String, appointment_startdatetime_UTC_String, appointment_enddatetime_UTC_String, selected_appointment_uuid);
            }
        } else {
            throw new SchedulingAPI_ApplicationServiceException('Missing Keys Error: SchedulingAPI_ApplicationService :\n salesforcerecorduuid\n productuuid\n appointment_date\n');
        }      
        
        return dialogflowFullFillmentResponse;
    }

    /* Generate Binary Search Method based on Availability */
    public String generateBinarySearchAvailableSlotsResponse(String salesforcerecorduuid, String productuuid, String appointment_date_UTC_String, String appointment_startdatetime_UTC_String, String appointment_enddatetime_UTC_String, String additional_action) {
        DialogFlow_Helper.SlotInfo availableSlotsWrapper = new DialogFlow_Helper.SlotInfo();
        List<DateTime> availableSlots = new List<DateTime>();
        Integer availableSlotsCount = 0, appointment_choice_count = 0, available_appointments_count = 0;
        String dialogflowFullFillmentResponse = '', available_appointments_slots_object_list = '', response_appointment_date = 'null', response_appointment_startdatetime = 'null', response_appointment_enddatetime = 'null';
        Boolean isSlotAvailable = false, is_previous_node = false, is_slot_out_of_range = false;

        List<Map<String, Object>> available_appointments_slots_map_list = new List<Map<String, Object>>();
        
        Datetime response_appointment_date_Value = NULL, response_appointment_startdatetime_Value = NULL, response_appointment_enddatetime_Value = NULL;

        response_appointment_date_Value = String.isNotBlank(appointment_date_UTC_String) ? DateTime.valueOfGMT(appointment_date_UTC_String.replace('T', ' ').replace('.000Z', '')) : NULL;
        response_appointment_date = String.isNotBlank(appointment_date_UTC_String) ? response_appointment_date_Value.format('yyyy-MM-dd HH:mm:ss:ssZ', timeZoneName) : NULL;

        response_appointment_startdatetime_Value = String.isNotBlank(appointment_startdatetime_UTC_String) ? DateTime.valueOfGMT(appointment_startdatetime_UTC_String.replace('T', ' ').replace('.000Z', '')) : NULL;
        response_appointment_startdatetime = String.isNotBlank(appointment_startdatetime_UTC_String) ? response_appointment_startdatetime_Value.format('yyyy-MM-dd HH:mm:ss:ssZ', timeZoneName) : NULL;

        response_appointment_enddatetime_Value = String.isNotBlank(appointment_enddatetime_UTC_String) ? DateTime.valueOfGMT(appointment_enddatetime_UTC_String.replace('T', ' ').replace('.000Z', '')) : NULL;
        response_appointment_enddatetime = String.isNotBlank(appointment_enddatetime_UTC_String) ? response_appointment_enddatetime_Value.format('yyyy-MM-dd HH:mm:ss:ssZ', timeZoneName) : NULL;


        timeZoneName = String.isNotBlank(timeZoneName) ? timeZoneName : 'America/Los_Angeles';

        Datetime appointment_date_UTC = freeBusyResponseWrapper.formatDateTime(appointment_date_UTC_String, 'YYYY-MM-DDThh:mm:ssZ');
        System.debug('appointment_enddatetime_UTC ' + appointment_date_UTC);
        

        availableSlotsWrapper = DialogFlow_Helper.getAvailableAppointments(salesforcerecorduuid, productuuid, appointment_date_UTC_String, appointment_startdatetime_UTC_String, appointment_enddatetime_UTC_String, false);
        availableSlots = availableSlotsWrapper.availableSlot;
        availableSlotsCount = availableSlotsWrapper.countOfSlotsInBetween;

        if(availableSlots.size() == 0) {
            List<Availability_History__c> searchHistory = (List<Availability_History__c>) DialogFlow_Helper.getRecentAvailabilityHistory(salesforcerecorduuid, productuuid);
            if( searchHistory.size() > 0 ) {
                response_appointment_date_Value = String.isNotBlank(searchHistory[0].Customer_DateTime_Input__c) ? DateTime.valueOfGMT(searchHistory[0].Customer_DateTime_Input__c.replace('T', ' ').replace('.000Z', '')) : NULL;
                response_appointment_date = String.isNotBlank(searchHistory[0].Customer_DateTime_Input__c) ? response_appointment_date_Value.format('yyyy-MM-dd HH:mm:ss:ssZ', timeZoneName) : NULL;

                response_appointment_startdatetime_Value = String.isNotBlank(searchHistory[0].Start_DateTime__c) ? DateTime.valueOfGMT(searchHistory[0].Start_DateTime__c.replace('T', ' ').replace('.000Z', '')) : NULL;
                response_appointment_startdatetime = String.isNotBlank(searchHistory[0].Start_DateTime__c) ? response_appointment_startdatetime_Value.format('yyyy-MM-dd HH:mm:ss:ssZ', timeZoneName) : NULL;

                response_appointment_enddatetime_Value = String.isNotBlank(searchHistory[0].End_DateTime__c) ? DateTime.valueOfGMT(searchHistory[0].End_DateTime__c.replace('T', ' ').replace('.000Z', '')) : NULL;
                response_appointment_enddatetime = String.isNotBlank(searchHistory[0].End_DateTime__c) ? response_appointment_enddatetime_Value.format('yyyy-MM-dd HH:mm:ss:ssZ', timeZoneName) : NULL;

                availableSlotsWrapper = DialogFlow_Helper.getAvailableAppointments(salesforcerecorduuid, productuuid, searchHistory[0].Customer_DateTime_Input__c, searchHistory[0].Start_DateTime__c, searchHistory[0].End_DateTime__c, false);
                availableSlots = availableSlotsWrapper.availableSlot;
                availableSlotsCount = availableSlotsWrapper.countOfSlotsInBetween;
                if(availableSlots.size() > 0) {
                    is_previous_node = true;
                } else { //TODO - if latest node is booked or not avaiable - do we need to iterate history or show some message
                    is_slot_out_of_range = true;
                }
            } else { //TODO - NO history found 
                is_slot_out_of_range = true;
            }           
        }

        if(availableSlots.size() == 0) {
            is_slot_out_of_range = true;
        }
        
        
        if( (availableSlots != NULL) && (availableSlots.size() > 0) ) {

            //Store Appointment Traverse History
            DialogFlow_Helper.createTrackingHistory(salesforcerecorduuid, productuuid, appointment_date_UTC_String, appointment_startdatetime_UTC_String, appointment_enddatetime_UTC_String, availableSlots);

            Integer appointments_iterator_counter = 1;
            for(DateTime iter_avaiable_utc_slot: availableSlots) {
                Map<String, Object> iter_available_appointments_slots_map = new Map<String, Object>();

                //Construct a Map and add it to list
                iter_available_appointments_slots_map.put('month', Integer.valueOf(iter_avaiable_utc_slot.format('MM', timeZoneName)) );
                iter_available_appointments_slots_map.put('day', Integer.valueOf(iter_avaiable_utc_slot.format('dd', timeZoneName)) );
                iter_available_appointments_slots_map.put('year', Integer.valueOf(iter_avaiable_utc_slot.format('yyyy', timeZoneName)) );
                iter_available_appointments_slots_map.put('hours', Integer.valueOf(iter_avaiable_utc_slot.format('HH', timeZoneName)) );
                iter_available_appointments_slots_map.put('minutes', Integer.valueOf(iter_avaiable_utc_slot.format('mm', timeZoneName)) );
                iter_available_appointments_slots_map.put('seconds', Integer.valueOf(iter_avaiable_utc_slot.format('ss', timeZoneName)) );
                iter_available_appointments_slots_map.put('nanos', Integer.valueOf(iter_avaiable_utc_slot.format('SSS', timeZoneName)) * 1000000); // Convert milliseconds to nanoseconds
                available_appointments_slots_map_list.add(iter_available_appointments_slots_map);
                appointments_iterator_counter++;    
            }

            //Fetch Chioces limit based on metadata settings
            appointment_choice_count = DialogFlow_Helper.getAppointmentChoiceCount(availableSlotsCount);
            //Store all Possible Slots irrespective of metadata limit
            available_appointments_count = availableSlotsCount;
        }

        if(available_appointments_slots_map_list.size() > 0) {
            available_appointments_slots_object_list = JSON.serialize(available_appointments_slots_map_list);
        }       

        //Fullfillment response for Dialogflow CX
        dialogflowFullFillmentResponse = '{ "sessionInfo": { "parameters": { "is_slot_out_of_range": ' + is_slot_out_of_range + ', "is_previous_node": ' + is_previous_node + ', "available_appointments_count": ' + available_appointments_count + ', "appointment_choice_count": ' + appointment_choice_count + ', "available_appointments_slots_object_list": ' + available_appointments_slots_object_list + ', "appointment_date": "' + response_appointment_date + '", "appointment_startdatetime": "' + response_appointment_startdatetime + '", "appointment_enddatetime": "' + response_appointment_enddatetime + '" } } }';

        return dialogflowFullFillmentResponse;
    }

    /*  Check and Book Appointment */
    public String generateAppointmentBookingResponse(String salesforcerecorduuid, String productuuid, String appointment_date_UTC_String, String appointment_startdatetime_UTC_String, String appointment_enddatetime_UTC_String, String selected_appointment_uuid) {
        DialogFlow_Helper.SlotInfo availableSlotsWrapper = new DialogFlow_Helper.SlotInfo();
        List<DateTime> availableSlots = new List<DateTime>();
        Integer availableSlotsCount = 0;
        String dialogflowFullFillmentResponse = '', latest_available_slot = '', additional_action = '', appointment_uuid = '';
        Boolean isSlotAvailable = false, is_slot_out_of_range = false;
        timeZoneName = String.isNotBlank(timeZoneName) ? timeZoneName : 'America/Los_Angeles';

        Datetime appointment_date_UTC = freeBusyResponseWrapper.formatDateTime(appointment_date_UTC_String, 'YYYY-MM-DDThh:mm:ssZ');
        System.debug('appointment_enddatetime_UTC ' + appointment_date_UTC);

        availableSlotsWrapper = DialogFlow_Helper.getAvailableAppointments(salesforcerecorduuid, productuuid, appointment_date_UTC_String, appointment_startdatetime_UTC_String, appointment_enddatetime_UTC_String, false);
        availableSlots = availableSlotsWrapper.availableSlot;
        availableSlotsCount = availableSlotsWrapper.countOfSlotsInBetween;

        //Check if selectedAppointmentSlot is Available or not
        if(availableSlots != NULL && availableSlots.size() > 0) {
            for(DateTime iterSlot: availableSlots) {
                System.debug('iterSlot ' + iterSlot);
                System.debug('appointment_date_UTC ' + appointment_date_UTC);
                if(appointment_date_UTC == iterSlot) {
                    isSlotAvailable = true;
                }
            }
        }

        // Book Appointment or Reschedule appointment
        if ( (isSlotAvailable == true) ) {
            //Book Appointment
            Appointment_Scheduling__c scheduledAppointment = DialogFlow_Helper.scheduleAppointment(salesforcerecorduuid, productuuid , appointment_date_UTC, additional_action);
            // if(scheduledAppointment == NULL || scheduledAppointment.Id == NULL) throw new SchedulingAPI_ApplicationServiceException('Appointment record not inserted');
            appointment_uuid = (scheduledAppointment != null) ? scheduledAppointment.UUID__c: appointment_uuid;

            //Store Appointment Traverse History
            DialogFlow_Helper.createTrackingHistory(salesforcerecorduuid, productuuid, appointment_date_UTC_String, appointment_startdatetime_UTC_String, appointment_enddatetime_UTC_String, availableSlots);
        
            if( String.isNotBlank(selected_appointment_uuid) ) {
                Appointment_Scheduling__c fetchAppointment = DialogFlow_Helper.cancelAppointment(selected_appointment_uuid);
            }
            
        }

        //Fullfillment response for Dialogflow CX
        dialogflowFullFillmentResponse = '{ "sessionInfo": { "parameters": { "is_slot_scheduled": "'+ isSlotAvailable +'", "is_slot_out_of_range": ' + is_slot_out_of_range + ', "appointment_uuid":"' + appointment_uuid + '" } } }';

        return dialogflowFullFillmentResponse;
    }

}