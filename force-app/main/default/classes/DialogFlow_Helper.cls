public without sharing class DialogFlow_Helper {

    public static String TIMEZONE = 'UTC';

    public DialogFlow_Helper() {

    }

    public static List<Lead> findLead(String salesforceRecordId, String phonenumber, String firstname, String lastname, String dateofbirthString ) {
        List<Lead> findLead = new List<Lead>();

        String objectapiname = String.isNotBlank(salesforceRecordId) ? Id.valueOf(salesforceRecordId).getSObjectType().getDescribe().getName() : '';

        String leadFilterCriteria = ' WHERE isConverted = false';
        
        if( String.isNotBlank(salesforceRecordId) && (objectapiname == 'Lead') ) {
            leadFilterCriteria += ' AND Id =: salesforceRecordId';
        } else {
            if( String.isNotBlank(phonenumber) ) {
                phonenumber = phonenumber.replaceAll('[^\\+\\d]','');
                leadFilterCriteria += ' AND Formatted_Phone_Number__c =: phonenumber';
            }
            if( String.isNotBlank(firstname) ) {
                leadFilterCriteria += ' AND FirstName =: firstname';
            }
            if( String.isNotBlank(lastname) ) {
                leadFilterCriteria += ' AND LastName =: lastname';
            }
            if( String.isNotBlank(dateofbirthString) ) {
                Date DateOfBirth = Date.valueOf(dateofbirthString);
                leadFilterCriteria += ' AND Date_of_Birth__c =: DateOfBirth';
            }
        }

        String findLeadQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Lead') +
        ' FROM Lead' + leadFilterCriteria + ' ORDER BY CreatedDate DESC';
        findLead = Database.query(findLeadQuery);

        return findLead;
    }

    public static MemberService.Member findAccount(String salesforceRecordUUID, String phonenumber, String firstname, String lastname, String dateofbirthString ) {
        MemberService.Member memberInfo = MemberService.getMemberInformation( salesforceRecordUUID,  phonenumber, firstname, lastname, dateofbirthString);
        return memberInfo;
    }

    public static List<Account> findAccountByUUID(String salesforceRecordUUID, String phonenumber, String dateofbirthString ) {
        List<Account> findAccount  = new List<Account>();
        if( String.isNotBlank(salesforceRecordUUID) || String.isNotBlank(phonenumber) || String.isNotBlank(dateofbirthString) ) {
            String accountFilterCriteria = ' WHERE isDeleted = false';
            if( String.isNotBlank(salesforceRecordUUID) ) {
                if ((salesforceRecordUUID.length() == 15) || (salesforceRecordUUID.length() == 18)) {
                    accountFilterCriteria += ' AND Id =: salesforceRecordUUID';
                } else {
                    accountFilterCriteria += ' AND UUID__c =: salesforceRecordUUID';
                }
            } else {
                if( String.isNotBlank(phonenumber) ) {
                    phonenumber = phonenumber.replaceAll('[^\\+\\d]','');
                    accountFilterCriteria += ' AND Formatted_Phone_Number__c =: phonenumber';
                }
                if( String.isNotBlank(dateofbirthString) ) {
                    Date DateOfBirth = Date.valueOf(dateofbirthString);
                    accountFilterCriteria += ' AND Date_of_Birth__c =: DateOfBirth';
                }
            }
            
            String findAccountQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Account') +
            ' FROM Account' + accountFilterCriteria + ' ORDER BY CreatedDate DESC';
            findAccount = Database.query(findAccountQuery);
        }

        return findAccount;
    }

    public static Map<String, String> metadata {
        get{
            Map<String, String> metadataMap = new Map<String, String>();
            for(Integration_Metadata__mdt item : Integration_Metadata__mdt.getAll()?.values()) {
                if(item.Integration_Setting__r.DeveloperName == NULL) {
                    metadataMap.put(item.Key__c, item.Value__c);
                }
            }
            return metadataMap;
        }
    }

    public static String getProfileUpdateLink(String objId ) {
        //set surveyId 
        //TODO - remove hardcoded value for testing purpose only
        // move it to int metadata
        String surveyLink = System.Label.GuestSiteLink + '' +'/apex/FormVf?formid=', 
        surveyId = metadata.get('patient_profile_form_id');
        
        SF_GenerateSurveyLinkInvocable.VariableBucket varset = new SF_GenerateSurveyLinkInvocable.VariableBucket();
        varset.surveyId = surveyId;

        String objectApiName = ((Id)objId).getsobjecttype() + '';
        switch on objectApiName {
            when 'Account' {
                varset.accountId = objId;
            }
            when 'Contact' {
                varset.contactId = objId;
            }
            when 'Lead' {
                varset.leadId = objId;
            }
        }

        List<Custom_Form__c> form = 
        SF_GenerateSurveyLinkInvocable.generateSurveyLink(
            new List<SF_GenerateSurveyLinkInvocable.VariableBucket>{varset}
        );

        if(form.size() > 0) {
            surveyLink += form[0]?.UUID__c; 
        }
        System.debug('SP surveylink '+surveyLink);
        return surveyLink;
    }

    //Fetch Default Contact Point Phonenumber
    public static String getDefaultPhoneNumber() {
        String fromNumber = '';
        try {
            List<Contact_Point__c> contactPoints = getContactPoints();
            for(Contact_Point__c contactPoint: contactPoints) {
                if(contactPoint.Default__c) {
                    fromNumber = contactPoint.Formatted_Phone_Number__c;
                    break;
                }
            }
            if(String.isBlank(fromNumber) && contactPoints != NULL && contactPoints.size() > 0) {
                fromNumber = contactPoints[0].Formatted_Phone_Number__c;
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return fromNumber;
    }

    //Fetch all Contact Points
    public static List<Contact_Point__c> getContactPoints() {
        String query = 'SELECT ' + SYS_Helper.getAllFieldsFor('Contact_Point__c') + ' FROM Contact_Point__c ORDER BY createdDate DESC LIMIT 1000';
        List<Contact_Point__c> allContactPoints = Database.query(query);
        return allContactPoints;
    }

    public static String generateVerificationCode() {
        String verificationcode = generateVerificationCode(4);
        System.debug('verificationcode ' + verificationcode);
        return verificationcode;
    }

    public static String generateVerificationCode(Integer length) {
        String verificationcode = '';
        String firstindexdigits = '123456789';
        String digits = '123456789';
        Integer verificationCodeLength = length;
        for(Integer i=1; i <= verificationCodeLength; i++){
            Integer digitsLength = 0;
            if(i == 0){
                digitsLength = firstindexdigits.length();
            } else {
                digitsLength = digits.length();
            }
            Integer index = Integer.valueOf(Math.floor(Math.random()*(digitsLength)));
            String indexValue = String.valueOf(index);
            verificationcode = verificationcode + indexValue;     
        }
        System.debug('verificationcode ' + verificationcode);
        return verificationcode;
    }
        
    public static Activity__c sendNotificationtoMember(String messageaction, String messagebody, String fromPhone, String toPhone, Id recordId ) {
        String type = 'sms';
        List<String> mediaUrls = new List<String>();
        String messageSubject = 'DialogFlow Voice - ' + messageaction + ' - Outbound SMS';
        //Send OTP SMS
        Activity__c createActivityRecord = CustomActivityService.createActivity(true, type, mediaUrls, messagebody, messageSubject, fromPhone, toPhone, recordId);
        return createActivityRecord;
    }

    public static Activity__c sendVerificationCodetoMember(Boolean isResend, String verificationCode, String fromPhone, String toPhone, Id recordId, String loginType ) {
        String type = 'sms', loginMethod = 'Verification Pin';
        List<String> mediaUrls = new List<String>();
        String messagebody = verificationCode + ' is your Municorn Assistant Verification Code';
        String messageSubject = 'Website Lead ' + ((isResend == true) ? 'Resend' : 'Send') + ' Verification Code - Outbound SMS';
        String loginStatus = ((isResend == true) ? 'Verification Pin Resent' : 'Verification Pin Sent');
        
        //Store Verification Code in Member Login History
        storeLoginAttempt(recordId, loginType, loginMethod, toPhone, loginStatus);

        //Send OTP SMS
        Activity__c createActivityRecord = CustomActivityService.createActivity(true, type, mediaUrls, messagebody, messageSubject, fromPhone, toPhone, recordId);
        return createActivityRecord;
    }

    //To Update Verification Code on Related Record
    public static void updateVerificationCodeRelatedRecord(Id salesforceRecordId, String verificationcode) {
        String objectapiname = (salesforceRecordId != null) ? Id.valueOf(salesforceRecordId).getSObjectType().getDescribe().getName() : '';
        sObject updateMember;
        //Update New Verification Code In Related Record
        if (objectapiname == 'Account') {
            updateMember = new Account();
            updateMember.put('Id', salesforceRecordId);
            updateMember.put('Last_Created_Verification_Pin__c' , verificationcode);
            updateMember.put('Last_Created_Verification_Pin_Time__c' , System.now());
            update updateMember;
        }
        if (objectapiname == 'Contact') {
            updateMember = new Contact();
            updateMember.put('Id', salesforceRecordId);
            updateMember.put('Last_Created_Verification_Pin__c' , verificationcode);
            updateMember.put('Last_Created_Verification_Pin_Time__c' , System.now());
            update updateMember;
        }
    }

    //To Verify Verification Code
    public static Boolean verifyVerificationCode(Id salesforceRecordId, String verificationCodeToCheck) {
        String objectapiname = (salesforceRecordId != null) ? Id.valueOf(salesforceRecordId).getSObjectType().getDescribe().getName() : '';
        Boolean isCodeMatched = false;
        //Fetch Related Record and Verify Code
        if (objectapiname == 'Account') {
            MemberService.Member memberinfo = DialogFlow_Helper.findAccount(salesforceRecordId, '', '', '', '');
            if( memberinfo != NULL && memberinfo.memberRecord != NULL) {
                String fetchVerificationCode = memberinfo.lastVarificationPin;
                Datetime lastCodeSentDatetime = memberinfo.lastVarificationPinTime;
                if( verificationCodeToCheck == fetchVerificationCode ) {
                    isCodeMatched = true;
                }
            }
        }
        //Fetch Related Record and Verify Code
        if (objectapiname == 'Contact') {
            MemberService.Member memberinfo = DialogFlow_Helper.findAccount(salesforceRecordId, '', '', '', '');
            if( memberinfo != NULL && memberinfo.memberRecord != NULL) {
                String fetchVerificationCode = memberinfo.lastVarificationPin;
                Datetime lastCodeSentDatetime = memberinfo.lastVarificationPinTime;
                if( verificationCodeToCheck == fetchVerificationCode ) {
                    isCodeMatched = true;
                }
            }
        }
        return isCodeMatched;
    }

    //Store Login Attempt to Member Login History
    public static void storeLoginAttempt(Id salesforceRecordId, String loginType, String loginMethod, String phoneNumber, String loginStatus) {
        String objectapiname = (salesforceRecordId != null) ? Id.valueOf(salesforceRecordId).getSObjectType().getDescribe().getName() : '';
        Id accountId = null, contactId = null;
        if (objectapiname == 'Account') {
            accountId = salesforceRecordId;
        }
        if (objectapiname == 'Contact') {
            contactId = salesforceRecordId;
        }
        Member_Login_History__c createLoginHistoryRecord = new Member_Login_History__c();
        createLoginHistoryRecord.Login_Type__c = loginType;
        createLoginHistoryRecord.Login_Method__c = loginMethod;
        createLoginHistoryRecord.Phone_Number__c = phoneNumber;
        createLoginHistoryRecord.Status__c = loginStatus;
        createLoginHistoryRecord.Account__c = accountId;
        createLoginHistoryRecord.Contact__c = contactId;
        
        insert createLoginHistoryRecord;
    }

    //Fetch Internal To-Do List Dialogflow Response Params
    public static String getInternalToDoListResponse(String accountuuid, String leadSource) {
        List<Map<String, String>> internalTodoList = new List<Map<String, String>>();

        String accountFilter = '', internalToDoListDialogFlowResponse = '';
        Integer current_todo_iter = 0, todo_list_count = 0;

        accountFilter += ' AND Type__c = \'Internal\'';
        if ( String.isNotBlank(accountuuid) ) {
            accountFilter += ' AND Account__r.UUID__c = :accountuuid ';
        }
        if ( String.isNotBlank(leadSource) ) {
            accountFilter += ' AND Source_Type__c = :leadSource ';
        }
        
        String todoListQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('ToDo__c') +
            ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
            ' FROM ToDo__c WHERE IsDeleted = FALSE' + accountFilter + ' ORDER BY CreatedDate ASC';  
        List<ToDo__c> getTodoListList = Database.query(todoListQuery);

        //Iterate TodoList Records and Create Name List 
        for(ToDo__c iterTodo : getTodoListList) {
            Map<String, String> todo_list_values_map = new Map<String, String>();
            todo_list_values_map.put('name' , iterTodo.Name);
            internalTodoList.add(todo_list_values_map);
        }
        todo_list_count = internalTodoList.size();
        
        internalToDoListDialogFlowResponse = '"todo_list": ' + JSON.serialize(internalTodoList) + ', "todo_list_count": ' + todo_list_count + ', "current_todo_iter": ' + current_todo_iter;
        //"todo_list": [{ "name": "Collect_Phone_Number" }, { "name": "Member_Lookup" }, { "name": "Ask_Phone_Number_Consent" }, { "name": "Connect_Upsert_Member_API" }, { "name": "Ask_Appointment_Consent" }, { "name": "Send_Scheduling_Notification" }, { "name": "Show_Chat_Menu" }], "todo_list_count": 7, "current_todo_iter": 0,
        return internalToDoListDialogFlowResponse;
    }

    //Fetch Scheduling Products Dialogflow Response Params
    public static String getSchedulingServicesResponse(String memberStage, String selected_service_uuid, String selected_service) {
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
                'services_uuid_list' => stageBasedServicesUUIDList,
                'services_name_list' => stageBasedServicesNamesList,
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
            List<String> services_uuid_list_response = new List<String>();
            List<String> services_name_list_response = new List<String>();
            String services_uuid_list_value = '', services_name_list_value = '';
            services_offered_name_ssml = '';
            services_offered_name_text = '';

            memberStage = String.isNotBlank(memberStage) ? memberStage : 'all';
            stage_based_params = stageBasedServicesMap.containsKey(memberStage) ? stageBasedServicesMap.get(memberStage) : null;

            services_uuid_delimited =  stage_based_params.containsKey('services_uuid_delimited') ? (String)stage_based_params.get('services_uuid_delimited') : '';
            services_name_delimited = stage_based_params.containsKey('services_name_delimited') ? (String)stage_based_params.get('services_name_delimited') : '';
            services_offered_name_ssml = stage_based_params.containsKey('services_offered_name_ssml') ? (String)stage_based_params.get('services_offered_name_ssml') : services_offered_name_ssml;
            services_offered_name_ssml = ( String.isNotBlank(services_offered_name_ssml) ) ? services_offered_name_ssml.replaceAll('"' , '\'') : '';
            services_offered_name_text = stage_based_params.containsKey('services_offered_name_text') ? (String)stage_based_params.get('services_offered_name_text') : services_offered_name_text;

            services_uuid_list_response =  stage_based_params.containsKey('services_uuid_list') ? (List<String>)stage_based_params.get('services_uuid_list') : services_uuid_list_response;
            services_name_list_response = stage_based_params.containsKey('services_name_list') ? (List<String>)stage_based_params.get('services_name_list') : services_name_list_response;

            selected_service_uuid = String.isNotBlank(selected_service_uuid) ? selected_service_uuid : ((services_uuid_list_response.size() > 0) ? services_uuid_list_response[0] : '');
            selected_service = String.isNotBlank(selected_service) ? selected_service : ((services_name_list_response.size() > 0) ? services_name_list_response[0] : '');
            
            services_uuid_list_value = (services_uuid_list_response.size() > 0) ? JSON.serialize(services_uuid_list_response) : '[]';
            services_name_list_value = (services_name_list_response.size() > 0) ? JSON.serialize(services_name_list_response) : '[]';

            services_count = stage_based_params.containsKey('services_count') ?  (Integer)stage_based_params.get('services_count') : 0;

            servicesOfferedDialogFlowResponse =  '"services_uuid_list":' + services_uuid_list_value + ',"services_name_list": ' + services_name_list_value + ',"services_uuid_delimited":"' + services_uuid_delimited + '","services_name_delimited":"' + services_name_delimited + '","services_offered_name_ssml":"' + services_offered_name_ssml + '","services_offered_name_text":"' + services_offered_name_text + '","selected_service":"' + selected_service + '","selected_service_uuid":"' + selected_service_uuid + '","services_count":' + services_count + ',"stage_based_services":' + stageBasedServicesMap_JSON;
        } else {
            servicesOfferedDialogFlowResponse = '"services_uuid_list": "","services_name_list": "","services_uuid_delimited":"","services_name_delimited":"","services_offered_name_ssml":"","services_offered_name_text":"","selected_service":"","selected_service_uuid":"","services_count": 0,"stage_based_services":' + stageBasedServicesMap_JSON;
        }
        
        return servicesOfferedDialogFlowResponse;
    }

    //Fetch Scheduling Products List
    public static List<Product__c> getSchedulingProducts(String memberStage) {
        String excludedStageFilter = '';
        if( String.isNotBlank(memberStage) ) {
            excludedStageFilter = ' AND Excluded_Stage__c excludes (\'' + memberStage + '\')';
        }

        String accountId = SYS_DataCacheFactory.accountId;
        if (accountId != NULL) {
            excludedStageFilter += ' AND Account__c = :accountId ';
        }

        String schedulingProductsListQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Product__c') +
            ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
            ' FROM Product__c WHERE Google_Shift_Calendar_Id__c != NULL AND Google_Booking_Calendar_Id__c != NULL AND Meet_Duration__c != NULL AND Allow_scheduling__c = TRUE' + excludedStageFilter + ' ORDER BY CreatedDate ASC';  
        List<Product__c> getSchedulingProductsList = Database.query(schedulingProductsListQuery);
        return getSchedulingProductsList;
    }

    //Fetch Scheduling Products List
    public static List<Product__c> getSchedulingProducts() {
        return getSchedulingProducts('');
    }
    
    
    
    public static Appointment_Scheduling__c scheduleAppointment(String salesforceRecordId, String productuuid , DateTime appointmentStartDateTime) {
        Appointment_Scheduling__c bookedAppointment = new Appointment_Scheduling__c();
        try {
            CalendarUtility utility = new CalendarUtility();
            String timeZoneName = utility.displayTimeZone;
            
            MemberService.Member memberWrapperData = MemberService.getMemberInformation(salesforceRecordId, '', '', '', '');
            Product__c selectedschedulingProduct = utility.getProductDetails(productuuid);

            Boolean hasDuplicateAppointments = AppointmentSchedulingService.hasDuplicateAppointments(appointmentStartDateTime, selectedschedulingProduct.Google_Booking_Calendar_Id__c);
            System.debug('hasDuplicateAppointments ' + hasDuplicateAppointments);
            if(hasDuplicateAppointments) {
                throw new DialogFlow_HelperException('Duplicate Appointment Found.');
            }
            String meetDuration = selectedschedulingProduct.Meet_Duration__c;
            Integer slotInterval = (String.isNotBlank(meetDuration)) ? Integer.valueof(meetDuration) : 0;

            Datetime appointmentEndDateTime = (appointmentStartDateTime.addMinutes(slotInterval));
            String appointmentStartDateTimeISOString = utility.formatDateTimetoISOString(appointmentStartDateTime);
            String appointmentEndDateTimeISOString = utility.formatDateTimetoISOString(appointmentEndDateTime);
            String MeetTitle;
            String appointmentMember;
            Id contactRecordId = null; 
            Id accountRecordId;
            if(memberWrapperData != null && memberWrapperData.memberRecord instanceOf Account) {
                appointmentMember = String.isNotBlank((String)memberWrapperData?.memberRecord?.get('Email__c')) ? (String)memberWrapperData?.memberRecord?.get('Email__c') : '';
                MeetTitle = 'Appointment for ' + memberWrapperData.Name + ' - ' + selectedschedulingProduct.Name;
                accountRecordId = memberWrapperData.Id;
            }
            else if(memberWrapperData != null && memberWrapperData.memberRecord instanceOf Contact) {
                appointmentMember = String.isNotBlank((String)memberWrapperData?.memberRecord?.get('Email')) ? (String)memberWrapperData?.memberRecord?.get('Email') : '';
                MeetTitle = 'Appointment for ' + memberWrapperData.Name + ' - ' + selectedschedulingProduct.Name;
                contactRecordId = memberWrapperData.Id;
                accountRecordId = (String)memberWrapperData.memberRecord.get('accountId');
            }
            else {
                appointmentMember = '';
                List<Lead> findLead = findLead(salesforceRecordId, '', '', '', '');
                String leadName;
                if (findLead.size() > 0) {
                    leadName = (String.isNotBlank(findLead[0].FirstName) ? findLead[0].FirstName : '') + '' + (String.isNotBlank(findLead[0].LastName) ? ' ' + findLead[0].LastName : ''); 
                    MeetTitle = 'Appointment for ' + leadName + ' - ' + selectedschedulingProduct.Name;               
                } else {
                    MeetTitle = 'Appointment for - ' + selectedschedulingProduct.Name;
                }
            }
             
            // Create Calendar Event Request
            GoogleCalenderEventWrapper createEventWrapper = new GoogleCalenderEventWrapper();
            createEventWrapper.summary = MeetTitle;
            createEventWrapper.addStartDatetime(appointmentStartDateTimeISOString);
            createEventWrapper.addEndDatetime(appointmentEndDateTimeISOString);
            if(String.isNotBlank(appointmentMember)){
                createEventWrapper.addAttendees(appointmentMember);
            }
            String newjsonBody = JSON.serialize(createEventWrapper, true);
            Object eventWrapperObject = System.JSON.deserializeUntyped(newjsonBody);
            if(String.isBlank(appointmentMember)){
                ((Map<String, Object>)eventWrapperObject).remove('attendees'); 
            }
            newjsonBody = JSON.serialize(eventWrapperObject);
            newjsonBody = newjsonBody.replaceAll('end_x', 'end');
            newjsonBody = newjsonBody.replaceAll('dateTime_x', 'dateTime');
            System.debug('newjsonBody ' + newjsonBody);
            String Google_Booking_Calendar_Id = selectedschedulingProduct.Google_Booking_Calendar_Id__c;
            String IntegrationName = 'Calendar';
            String calloutMethod = 'POST';
            String calloutUrl = 'https://www.googleapis.com/calendar/v3/calendars/'+ Google_Booking_Calendar_Id +'/events?sendNotifications=true&sendUpdates=all&maxAttendees=1';
            HttpResponse resp = utility.buildOutboundHttpRequest(IntegrationName, calloutMethod, calloutUrl, newjsonBody);
            System.debug('#### resp status: '+resp.getStatus());
            System.debug('#### resp code: '+resp.getStatusCode()); 
            String createAppointmentResponse = resp.getBody();
            Integer createAppointmentResponseStatusCode = resp.getStatusCode();
            String createAppointmentResponseStatus = resp.getStatus();
            if(createAppointmentResponseStatusCode == 201 || createAppointmentResponseStatusCode == 200){
                createAppointmentResponse = createAppointmentResponse.replaceAll('dateTime','dateTime_x').replaceAll('end','end_x');
                GoogleCalenderEventResponseWrapper GoogleCreateEventResponse = GoogleCalenderEventResponseWrapper.parse(createAppointmentResponse);
                
                String googleCalendarEventId = GoogleCreateEventResponse.id;
                String googleCalendarEventStatus = GoogleCreateEventResponse.status;
                String googleCalendarEventTimezone = GoogleCreateEventResponse.start.timeZone;
                Boolean IsActive = true;
                String displayTimeZone = 'America/Los_Angeles' ;
               
                bookedAppointment = AppointmentSchedulingService.createNewAppointment(MeetTitle, appointmentStartDateTime, appointmentEndDateTime, meetDuration, MeetTitle, accountRecordId, contactRecordId, selectedschedulingProduct.Id, appointmentMember, Google_Booking_Calendar_Id, googleCalendarEventId, googleCalendarEventStatus, googleCalendarEventTimezone, displayTimeZone, IsActive);
                System.debug('googleCalendarEventTimezone ' + googleCalendarEventTimezone);
                System.debug('bookedAppointment ' + bookedAppointment);
            }            
            
        } catch (Exception ex) {
            System.debug('Exception ' +  ex.getMessage());
            System.debug('Exception ' +  ex.getStackTraceString());
            throw new DialogFlow_HelperException('Some Error occured during appointment callout'+ex.getMessage()+'\n'+ex.getStackTraceString());
        }
        return bookedAppointment;
    }

    public static Appointment_Scheduling__c cancelAppointment(String appointmentUUID) {
        CalendarUtility utility = new CalendarUtility();
        Appointment_Scheduling__c fetchAppointmentDetails = AppointmentSchedulingService.getAppointmentDetails(appointmentUUID);

        //Update Appointment Status to Cancel
        fetchAppointmentDetails.Status__c = 'cancelled';
        Appointment_Scheduling__c updateAppointment = AppointmentSchedulingService.updateAppointment(fetchAppointmentDetails);
        fetchAppointmentDetails = updateAppointment;
        return fetchAppointmentDetails;
    }

    //Fetch Upcoming Appointments
    public static List<Appointment_Scheduling__c> getUpcomingAppointments(String memberUuid) {
        List<Appointment_Scheduling__c> upcomingAppointments = new List<Appointment_Scheduling__c>();
        List<String> excludeAppointmentStatusList = new List<String>{'cancelled'};
        String appointmentListFilterQuery = '';
        Datetime currentDateTime = Datetime.now();
        
        MemberService.Member memberinfo = DialogFlow_Helper.findAccount(memberUuid, '', '', '', '');

        if (memberinfo != NULL && memberinfo.memberRecord != NULL && memberinfo.memberRecord instanceOf Account) {
            if ((memberUuid.length() == 15) || (memberUuid.length() == 18)) {
                appointmentListFilterQuery += 'Account__c =: memberUuid';
            } else {
                appointmentListFilterQuery += 'Account__r.UUID__c =: memberUuid';
            }
        } else if (memberinfo != NULL && memberinfo.memberRecord != NULL && memberinfo.memberRecord instanceOf Contact) {
            if ((memberUuid.length() == 15) || (memberUuid.length() == 18)) {
                appointmentListFilterQuery += 'Contact__c =: memberUuid';
            } else {
                appointmentListFilterQuery += 'Contact__r.UUID__c =: memberUuid';
            }
        }
        
        String selectedMemberScheduledAppointmentsQuery = 'SELECT ' + SYS_Helper.getAllFieldsFor('Appointment_Scheduling__c') +
            ', ' + SYS_Helper.getAllParentFields('Product__r.', 'Product__c') +
            ', ' + SYS_Helper.getAllParentFields('Account__r.', 'Account') +
            ', ' + SYS_Helper.getAllParentFields('Contact__r.', 'Contact') +
            ' FROM Appointment_Scheduling__c WHERE ' + appointmentListFilterQuery + ' AND Status__c NOT IN :excludeAppointmentStatusList AND StartDate__c >= :currentDateTime ORDER BY StartDate__c ASC';
        upcomingAppointments = Database.query(selectedMemberScheduledAppointmentsQuery);

        return upcomingAppointments;
    }

    /* Fetch Upcoming Appointments Dialogflow Response Params */
    public static String upcomingAppointmentsResponse(String salesforcerecorduuid) {
        String upcoming_appointments_response = '', upcoming_appointments_slots_delimited = '', upcoming_appointments_uuid_delimited = '', upcoming_appointments_service_uuid_delimited = '', upcoming_appointments_service_name_delimited = '', timeZoneName = 'America/Los_Angeles';
        Integer upcoming_appointments_count = 0;
        List<String> upcoming_appointments_slots_list = new List<String>();
        List<String> upcoming_appointments_uuid_list = new List<String>();

        List<String> upcoming_appointments_service_uuid_list = new List<String>();
        List<String> upcoming_appointments_service_name_list = new List<String>();
        Boolean hasUpcomingAppointments = false;
        
        timeZoneName = String.isNotBlank(timeZoneName) ? timeZoneName : 'America/Los_Angeles';

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
            
            upcoming_appointments_response = '"hasupcomingappointments": ' + hasUpcomingAppointments + ', "upcoming_appointments_uuid_delimited": "' + upcoming_appointments_uuid_delimited + '", "upcoming_appointments_slots_delimited": "' + upcoming_appointments_slots_delimited + '", "upcoming_appointments_service_uuid_delimited": "' + upcoming_appointments_service_uuid_delimited + '", "upcoming_appointments_service_name_delimited": "' + upcoming_appointments_service_name_delimited + '", "upcoming_appointments_count": ' + upcoming_appointments_count;
        } else {
            //Fullfillment response for Dialogflow CX
            upcoming_appointments_response = '"hasupcomingappointments": ' + hasUpcomingAppointments;
        }

        return upcoming_appointments_response;
    }

    public static String getTimeZoneOffset(String timeZoneName) {
        TimeZone tz = System.TimeZone.getTimeZone(timeZoneName);
        Integer offset = tz.getOffset(DateTime.now());
        String sign = (offset <= 0 ? '-' : '+');
        Integer hours = Math.abs(offset / 3600000);
        Integer minutes = Math.abs(Math.mod(offset / 60000, 60));
        String formattedOffset = sign + String.valueOf(hours).leftPad(2, '0') + ':' + String.valueOf(minutes).leftPad(2, '0');
        return formattedOffset;
    }

    //Format Datetime to ISO String
    public static String formatDateTimetoISOString(Datetime tempDatetimeToFormatted){
        String tempavailableSlotString = tempDatetimeToFormatted.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        return tempavailableSlotString;
    }

    //Convert Datetime to UTC
    public static DateTime convertToUTCDateTime(String dateTimetoConvert, String timeZoneName) {
        // Convert the string to a Datetime object
        Datetime dt = Datetime.valueOfGmt(dateTimetoConvert);

        // Get the timezone offset for PST
        TimeZone tz = System.TimeZone.getTimeZone(timeZoneName);
        Integer offset = tz.getOffset(dt);
        
        // Convert the datetime to UTC      
        Datetime convertedDateTimeUTC = dt.addSeconds(-offset/1000);
        // Long utcTime = dt.getTime() - offset;
        // DateTime convertedDateTimeUTC = DateTime.newInstance(utcTime);

        return convertedDateTimeUTC;
    }
    
    public static Integer getAppointmentChoiceCount(Integer availableSlotsCount) {
        Integer appointment_Choice_Count = 0, config_Appointment_Choice_Count = 4;
        String appointment_choice_count_metadata = metadata.get('appointment_choice_count');
        appointment_choice_count_metadata = String.isNotBlank(appointment_choice_count_metadata) ? appointment_choice_count_metadata : '0';
        System.debug('appointment_choice_count_metadata ' + appointment_choice_count_metadata);
        try {
            config_Appointment_Choice_Count = Integer.valueOf(appointment_choice_count_metadata);
        } catch (Exception e) {
            config_Appointment_Choice_Count = 4;
        }

        appointment_Choice_Count = (availableSlotsCount > config_Appointment_Choice_Count) ? config_Appointment_Choice_Count : availableSlotsCount;
        
        return appointment_Choice_Count;
    }

    public static List<DateTime> getAvailableSlot(String productuuid , String startDateTime) {
        String startDateTimeString, endDateTimeString, shiftCalendarId, bookingCalendarId, meetDuration;
        Integer SLOT_COUNT = 2;
        Datetime shiftStartDateTime, shiftEndDateTime;
        List<Datetime> initialBookingSlots, availableBookingSlots;
        List<DateTime> latestAvailableSlots = new List<DateTime>();
        try {
            CalendarUtility utility = new CalendarUtility();
            Product__c selectedschedulingProduct = utility.getProductDetails(productuuid);
            String googleShiftCalendarId = selectedschedulingProduct.Google_Shift_Calendar_Id__c;
            String googleBookingCalendarId = selectedschedulingProduct.Google_Booking_Calendar_Id__c;
            Datetime today = Datetime.now();

            Integer slotInterval;
            meetDuration = selectedschedulingProduct.Meet_Duration__c;
            slotInterval = (String.isNotBlank(meetDuration)) ? Integer.valueof(meetDuration) : 0;
            
            String minimumLeadTimeString = selectedschedulingProduct.Minimum_Lead_Time__c;
            Integer minimumLeadTime = (String.isNotBlank(minimumLeadTimeString)) ? Integer.valueof(minimumLeadTimeString) : 0;

            DateTime startDatetimeVariable = freeBusyResponseWrapper.formatDateTime(startDateTime, 'YYYY-MM-DDThh:mm:ssZ');
            System.debug('SP startDatetimeVariable '+startDatetimeVariable);
            DateTime endDateTimeVariable = freeBusyResponseWrapper.formatDateTime(startDatetimeVariable.addHours(24)+'', 'YYYY-MM-DDThh:mm:ssZ');
            TIMEZONE = 'UTC';
            if (startDatetimeVariable < Datetime.now()) {
                // TimeZone tz = System.TimeZone.getTimeZone('America/Los_Angeles');
                startDatetimeVariable = System.Now();
                // startDatetimeVariable = Datetime.valueOf(Datetime.now()?.format('YYYY-MM-DDThh:mm:ssZ', 'America/Los_Angeles'));
            }
            startDatetimeVariable = utility.resetSecondsToZero(startDatetimeVariable);
            startDatetimeVariable = startDatetimeVariable.addMinutes(minimumLeadTime);
            Datetime slotTime = startDatetimeVariable;
            startDatetimeVariable = utility.roundToNextInterval(startDatetimeVariable, slotInterval);

            System.debug('SP startDatetimeVariable '+startDatetimeVariable);
            String freebusyResponseJson = utility.freeBusyCheck(productuuid, startDatetimeVariable, 7);
    
            //Parse freeBusyResponse
            FreeBusyResponseWrapper freeBusyResponseObject = freeBusyResponseWrapper.parse(freebusyResponseJson);
    
            Map<String , List<freeBusyResponseWrapper.Busy>> calendarIdBusySlotsListMap = freeBusyResponseObject?.calendars?.calendarIdBusySlotsMap;
    
            if( calendarIdBusySlotsListMap.containsKey(googleShiftCalendarId) ){
                List<freeBusyResponseWrapper.Busy> shiftBusySlots = calendarIdBusySlotsListMap.get(googleShiftCalendarId);
                // Map<Long , Datetime> slotsTimeDateMap = new Map<Long , Datetime>();
                // List<Long> timeSlotsMilliseconds = new List<Long>();
                List<Datetime> tempshiftStartDateTimeList = new List<Datetime>();
                List<Datetime> tempshiftEndDateTimeList = new List<Datetime>();
                
                if( shiftBusySlots.size() > 0 ){
                    for(freeBusyResponseWrapper.Busy tempShiftSlot : shiftBusySlots){
                        tempshiftStartDateTimeList.add(utility.resetSecondsToZero(tempShiftSlot.start_x));
                        tempshiftEndDateTimeList.add(utility.resetSecondsToZero(tempShiftSlot.end_x));
                    }
                    shiftStartDateTime = tempshiftStartDateTimeList[0];
                    shiftEndDateTime = tempshiftEndDateTimeList[0]; 
                    for(Datetime itertempShiftStartTime :tempshiftStartDateTimeList){
                        shiftStartDateTime = (shiftStartDateTime <= itertempShiftStartTime) ? shiftStartDateTime : itertempShiftStartTime;
                    }
                    for(Datetime itertempShiftEndTime :tempshiftEndDateTimeList){
                        shiftEndDateTime = (shiftEndDateTime >= itertempShiftEndTime) ? shiftEndDateTime : itertempShiftEndTime;
                    }
                }
            }
            System.debug('startDatetimeVariable new ' + startDatetimeVariable);
            System.debug('shiftStartDateTime ' + shiftStartDateTime);
            System.debug('shiftEndDateTime ' + shiftEndDateTime);
            System.debug('slotInterval ' + slotInterval);
            
            //Check if shiftStartDateTime shiftEndDateTime are empty or not
            //Check if Initial slots are empty or not exit with exception
            if (shiftStartDateTime == NULL) {
                shiftStartDateTime = startDatetimeVariable;
            } if (shiftEndDateTime == NULL) {
                shiftEndDateTime = endDateTimeVariable;
            }
            initialBookingSlots = utility.getInitialSlots(shiftStartDateTime, shiftEndDateTime, slotInterval );
            System.debug('initialBookingSlots ' + initialBookingSlots);            
    
            List<freeBusyResponseWrapper.Busy> busySlotsWrapperList = new List<freeBusyResponseWrapper.Busy>();
            if( calendarIdBusySlotsListMap.containsKey(googleBookingCalendarId) ){
                List<freeBusyResponseWrapper.Busy> bookingCalendarBusySlots = calendarIdBusySlotsListMap.get(googleBookingCalendarId);
                if( bookingCalendarBusySlots.size() > 0 ){
                    busySlotsWrapperList = bookingCalendarBusySlots;
                }else {
                    availableBookingSlots = initialBookingSlots;
                }
            }else{
                availableBookingSlots = initialBookingSlots;
            }
    
            availableBookingSlots = utility.getFinalSlots(busySlotsWrapperList, initialBookingSlots);
            System.debug('availableBookingSlots ' + availableBookingSlots);   
            for(DateTime slot: availableBookingSlots) {
                if (SLOT_COUNT == 0) break;
                if(slot != NULL && slotTime <= slot && CalendarUtility.allowAppointmentBooking(slotTime, googleBookingCalendarId)) {
                    // TimeZone tz = System.TimeZone.getTimeZone('America/Los_Angeles');
                    // slot = DateTime.newInstance(slot.getTime() + tz.getOffset(slot));
                    latestAvailableSlots.add(slot);
                    SLOT_COUNT --;
                }
                
            }
        } catch (Exception e) {
            System.debug('Exception e ' + e.getMessage());
            System.debug('Exception string ' + e.getstacktraceString());
        }
        return latestAvailableSlots;
    }
    

    /**
     * @brief used for binary search.
     * @return the availabile slot minStart and maxEnd time
     */
    public static SlotInfo getAvailableAppointments(String salesforcerecorduuid, String productuuid, String dateOfAppointment, String startTime, String endTime, Boolean showLater) {
        List<DateTime> availableSlots = new List<DateTime>();
        SlotInfo info = new SlotInfo();
        try {
            DateTime startDateTime, endDateTime;
            DateTime startDatetimeVariable = freeBusyResponseWrapper.formatDateTime(dateOfAppointment, 'YYYY-MM-DDThh:mm:ssZ');
            if (String.isNotBlank(startTime))
                startDateTime = freeBusyResponseWrapper.formatDateTime(startTime, 'YYYY-MM-DDThh:mm:ssZ');
            if (String.isNotBlank(endTime))
                endDateTime = freeBusyResponseWrapper.formatDateTime(endTime, 'YYYY-MM-DDThh:mm:ssZ');
            Integer dayCount = 90;
            String dateUtc = startDatetimeVariable.format('yyyy-MM-dd');
            CalendarUtility utility = new CalendarUtility();
            Map<String, List<DateTime>> result = utility.getAvailableSlotMap(productuuid, startDatetimeVariable, dayCount);
            List<DateTime> allAvailableSlots = new List<DateTime>();
            for(String datekey : result.keySet() ) {
                if (result.get(datekey) != NULL && result.get(datekey).size() > 0) {
                    allAvailableSlots.addAll(result.get(datekey));
                }
            }
            Integer slotSize = allAvailableSlots.size();
            List<DateTime> allAvailableSlotsFiltered = new List<DateTime>();
            for ( Integer i = 0; i < slotSize ; i++ ) {
                
                if ((startDateTime != NULL && endDateTime != NULL) && allAvailableSlots[i] < startDateTime || allAvailableSlots[i] > endDateTime) {
                    continue;
                }
                else if (allAvailableSlots[i] > DateTime.now()) {
                    allAvailableSlotsFiltered.add(allAvailableSlots[i]);
                }
            }
            if (allAvailableSlotsFiltered.size() > 0) {
                allAvailableSlotsFiltered.sort();
                availableSlots.add(allAvailableSlotsFiltered[0]);
                if (allAvailableSlotsFiltered.size() - 1 > 0) {
                    availableSlots.add(allAvailableSlotsFiltered[allAvailableSlotsFiltered.size() - 1]);
                }
            }
            info.availableSlot = availableSlots;
            info.countOfSlotsInBetween = allAvailableSlotsFiltered.size();
            // createTrackingHistory(salesforcerecorduuid, productuuid, dateOfAppointment, startTime, endTime, availableSlots);

            //##------ Useful Garbage ------###

            // if (result.containsKey(dateUtc)) {
            //     //Slots are in ascending order already
            //     List<DateTime> allSlots = result.get(dateUtc);
            //     Integer slotSize = allSlots.size();
            //     List<DateTime> allAvailableSlots = new List<DateTime>();
            //     if (slotSize > 0) {
            //         for ( Integer i = 0; i < slotSize ; i++ ) {
            //             System.debug('Available '+allSlots[i]);
            //             if ((startDateTime != NULL && endDateTime != NULL) && allSlots[i] < startDateTime || allSlots[i] > endDateTime) {
            //                 continue;
            //             }
            //             else if (allSlots[i] > DateTime.now()) {
            //                 System.debug('Available '+allSlots[i]);
            //                 allAvailableSlots.add(allSlots[i]);
            //             }
            //         }
            //         if (allAvailableSlots.size() > 0) {
            //             availableSlots.add(allAvailableSlots[0]);
            //             if (allAvailableSlots.size() - 1 > 0) {
            //                 availableSlots.add(allAvailableSlots[allAvailableSlots.size() - 1]);
            //             }
            //         }

            //         // if (showLater) {
                        
            //         // }
            //         // else {
            //         //     for ( Integer i = slotSize-1; i >= 0 ; i-- ) {
            //         //         System.debug('iterator '+i+' '+allSlots[i]+' '+startDatetimeVariable);
            //         //         if (allSlots[i] > startDatetimeVariable) {
            //         //             continue;
            //         //         }
            //         //         else if (allSlots[i] <= startDatetimeVariable) {
            //         //             availableSlots.add(allSlots[i]);
            //         //             if (i > 0) {
            //         //                 i = 0;
            //         //                 availableSlots.add(allSlots[i]);
            //         //             }
            //         //             break;
            //         //         }
            //         //     }
            //         // }
            //     }
                
            // } else {
            //     //If no slots available for the provided date and showLater is true
            //     //need to show available slot of next date.

            // }

        } catch (Exception e) {
            System.debug('Exception e ' + e.getMessage());
            System.debug('Exception string ' + e.getstacktraceString());
        }
        return info;
    }

    public class SlotInfo {
        public List<DateTime> availableSlot { get; set; }
        public Integer countOfSlotsInBetween { get; set; }
    }

    public static List<sObject> getRecentAvailabilityHistory(String salesforcerecorduuid, String productuuid) {
        List<sObject> records = new List<sObject>();
        try {
            String query = 'SELECT ' + SYS_Helper.getAllFieldsFor('Availability_History__c') +
            ' FROM Availability_History__c WHERE Product_UUID__c = :productuuid AND Customer_UUID__c = :salesforcerecorduuid ORDER BY createddate DESC LIMIT 5';
            records = Database.query(query);
        } catch ( Exception e ) {
            System.debug('Exception e ' + e.getMessage());
            System.debug('Exception string ' + e.getstacktraceString());
            throw new DialogFlow_HelperException(e.getMessage() + e.getstacktraceString());
        }
        return records;
    }
    
    public static void createTrackingHistory(String salesforcerecorduuid, String productuuid, String dateOfAppointment, String startTime, String endTime, List<DateTime> availableSlots) {
        try {
            String objectApiName = 'Availability_History__c';
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectApiName);
            SObject history = objectType.newSObject();
            history.put('Customer_DateTime_Input__c', dateOfAppointment);
            history.put('Start_DateTime__c', startTime);
            history.put('End_DateTime__c', endTime);
            history.put('Product_UUID__c', productuuid);
            history.put('Customer_UUID__c', salesforcerecorduuid);
            String hashOf = dateOfAppointment+'~'+startTime+'~'+endTime+'~'+productuuid+'~'+salesforcerecorduuid;

            history.put('Hash__c', generateHash(hashOf));


            if (availableSlots != NULL && availableSlots.size() > 0) {
                String availableString = '';
                for(DateTime slot :  availableSlots) {
                    availableString += slot.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' - ';
                }
                history.put('Available_Slot__c', availableString);
            }
            else {
                history.put('Available_Slot__c', 'No Slots Available.');
            }

            upsert (Availability_History__c)history Hash__c;
        } catch ( Exception e ) {
            System.debug('Exception e ' + e.getMessage());
            System.debug('Exception string ' + e.getstacktraceString());
            throw new DialogFlow_HelperException(e.getMessage() + e.getstacktraceString());
        }
    }

    public static String generateHash(String requestBody) {

        Blob requestBlob = Blob.valueOf(requestBody);
        Blob hashBlob = Crypto.generateDigest('SHA-512',requestBlob);
        String base64EncodedHash = EncodingUtil.base64encode(hashBlob);

        return base64EncodedHash;
    }

    public class DialogFlow_HelperException extends Exception {}
}