public without sharing class NotificationAPI_ApplicationService extends SYS_ApplicationService {
    
    public static String RESPONSE = '';
    public static String languageCode = 'en-US';//es-ES
    Map<String, String> languageMap = new Map<String, String>{'en-US' => 'en', 'en' => 'en', 'es-ES' => 'es', 'es' => 'es'};

    public NotificationAPI_ApplicationService() {}

    /** membernotification is_notified phonenumber_to_notify messageaction
     * This hook is called from each of the hook for Http Verb processing
     * Arguement: Http Verb - POST,GET,PATCH,DELETE,PUT
     * Relies on Integration Setting in DataCache and RestContext
     * Override if custom log generation is required
     */
    public override List < SYS_IntegrationLog__c > generateLogForWebhookReq(String method) {
      String requestBody = RestContext.request.requestBody.toString();
      SYS_IntegrationLog__c log = new SYS_IntegrationLog__c();
      List < SYS_IntegrationLog__c > logAfterPartition = new List < SYS_IntegrationLog__c > ();

      //Deserilize JSON and Map Keys for DialogFlow Json
      Map < String, Object > newflatKeyMap = new Map < String, Object > ();
      String resource_path, sessionString, currentSessionId, leadsource, salesforcerecorduuid, phonenumber = '', dateofbirthString = '', firstname = '', lastname = '', accountname = '', stage = '', selected_service_uuid = '', phonenumber_to_notify = '', appointmentlink = '', messageaction = '', dialogflowFullFillmentResponse;
      Boolean ignoreLog = true, is_notified = false, isphoneverified = false, ismemberfound = false;

      List < Account > fetchAccount = new List < Account > ();

      Object responseType = JSON.deserializeUntyped(requestBody);
      if (responseType instanceof Map < String, Object > ) {
        newflatKeyMap = (SYS_Helper.getFlatKeys(requestBody, 'A.B')); //
        resource_path = newflatKeyMap.containsKey('sessionInfo.parameters.resource_path') ? (String) newflatKeyMap.get('sessionInfo.parameters.resource_path') : '';
        leadsource = newflatKeyMap.containsKey('sessionInfo.parameters.leadsource') ? (String) newflatKeyMap.get('sessionInfo.parameters.leadsource') : '';
        Object isphoneverified_obj = newflatKeyMap.containsKey( 'sessionInfo.parameters.isphoneverified' ) ? newflatKeyMap.get('sessionInfo.parameters.isphoneverified') : null;
        isphoneverified = (isphoneverified_obj instanceof Boolean) ?
                (Boolean) isphoneverified_obj :
                ( (isphoneverified_obj instanceof String) ? Boolean.valueOf(String.valueOf(isphoneverified_obj).equalsIgnoreCase('true')) : false);

        Object ismemberfound_obj = newflatKeyMap.containsKey( 'sessionInfo.parameters.ismemberfound' ) ? newflatKeyMap.get('sessionInfo.parameters.ismemberfound') : null;
        ismemberfound = (ismemberfound_obj instanceof Boolean) ?
                (Boolean) ismemberfound_obj :
                ( (ismemberfound_obj instanceof String) ? Boolean.valueOf(String.valueOf(ismemberfound_obj).equalsIgnoreCase('true')) : false);        

        dateofbirthString = newflatKeyMap.containsKey('sessionInfo.parameters.dateofbirth') ? (String) newflatKeyMap.get('sessionInfo.parameters.dateofbirth') : '';
        salesforcerecorduuid = newflatKeyMap.containsKey('sessionInfo.parameters.salesforcerecorduuid') ? (String) newflatKeyMap.get('sessionInfo.parameters.salesforcerecorduuid') : '';
        salesforcerecorduuid = (salesforcerecorduuid != 'null') ? salesforcerecorduuid : '';
        selected_service_uuid = newflatKeyMap.containsKey('sessionInfo.parameters.selected_service_uuid') ? (String) newflatKeyMap.get('sessionInfo.parameters.selected_service_uuid') : '';
        phonenumber = newflatKeyMap.containsKey('sessionInfo.parameters.phonenumber') ? (String) newflatKeyMap.get('sessionInfo.parameters.phonenumber') : '';
        phonenumber_to_notify = newflatKeyMap.containsKey('sessionInfo.parameters.phonenumber_to_notify') ? (String) newflatKeyMap.get('sessionInfo.parameters.phonenumber_to_notify') : '';
        messageaction = newflatKeyMap.containsKey('sessionInfo.parameters.messageaction') ? (String) newflatKeyMap.get('sessionInfo.parameters.messageaction') : '';

        languageCode = newflatKeyMap.containsKey('languageCode') ? (String) newflatKeyMap.get('languageCode') : languageCode;
        languageCode = languageMap.containsKey(languageCode) ? languageMap.get(languageCode) : 'en';

        sessionString = newflatKeyMap.containsKey('sessionInfo.session') ? (String) newflatKeyMap.get('sessionInfo.session') : '';
        currentSessionId = String.isNotBlank(sessionString) ? sessionString.substringAfterLast('sessions/') : '';

        MemberService.Member memberinfo = DialogFlow_Helper.findAccount(salesforcerecorduuid, phonenumber, firstname, lastname, dateofbirthString);

        if (memberinfo != NULL && memberinfo.memberRecord != NULL) {
          //Store Response Fields for Dialogflow
          Id filteredRecordId = memberinfo.Id;
          String fromPhone = DialogFlow_Helper.getDefaultPhoneNumber();
          String recordName = String.isNotBlank(memberinfo.Name) ? memberinfo.Name : '';
          String toPhone = phonenumber_to_notify;
          if (memberinfo != NULL && memberinfo.memberRecord != NULL && memberinfo.memberRecord instanceOf Account) {
            appointmentlink = (String) memberinfo.memberRecord.get('Schedule_Appointment_Link__c');
          } else if (memberinfo != NULL && memberinfo.memberRecord != NULL && memberinfo.memberRecord instanceOf Contact) {
            appointmentlink = (String) memberinfo.memberRecord.get('Appointment_Link__c');
          }

          System.debug('messageaction ' + messageaction);
          System.debug('messageaction ' + appointmentlink);
          //Classify Text message based on messageaction
          if (messageaction == 'send_verification_code') {
            RESPONSE = getSendVerificationCodeResponse(messageaction, recordName, fromPhone, toPhone, filteredRecordId);
          }

          if (messageaction == 'send_appointment_scheduling_text') {
            RESPONSE = getSendAppointmentSchedulingResponse(messageaction, appointmentlink, recordName, fromPhone, toPhone, filteredRecordId); // appointmentlink
          }

          if (messageaction == 'Update Profile') {
            RESPONSE = getUpdateProfileResponse(messageaction, recordName, fromPhone, toPhone, filteredRecordId);
          }
        } else {
          dialogflowFullFillmentResponse = '{"sessionInfo":{"parameters":{"is_notified":"' + is_notified + '"}}}';
          RESPONSE = dialogflowFullFillmentResponse;
        }
      }
      System.debug('RESPONSE ' + RESPONSE);
      //Check criteria when chars more than 1M
      if (requestBody != null && requestBody.length() > SYS_Constants.TEXT_AREA_MAX_SIZE * 10) {
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
      // log.Flat_Key_for_Resource__c = SYS_DataCacheFactory.integrationSetting.Flat_Key_for_Resource__c;
      // log.Integration_Setting__c = SYS_DataCacheFactory.INT_TYPE;
      log.Flat_Key_for_Resource__c = 'sessionInfo.parameters.resource_type';
      log.Integration_Setting__c = 'NotificationAPI';
      log.Status__c = 'NEW';
      if ((ignoreLog == true)) {
        log.How_to_process__c = 'ignore_log';
      } else {
        log.How_to_process__c = 'use_custom_apex_handler';
      }
      // log.Custom_Apex_Handler__c = SYS_DataCacheFactory.integrationSetting.ApexHandler__c;
      log.Custom_Apex_Handler__c = 'NotificationAPI_ApplicationService';

      //new fields
      log.Account_Id__c = SYS_DataCacheFactory.accountId;
      // log.Integration_Type__c = SYS_DataCacheFactory.integrationSetting?.Integration_Type__c;
      log.Integration_Type__c = 'NotificationAPI';

      List < SYS_IntegrationLog__c > returnVal = new List < SYS_IntegrationLog__c > ();
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
      if (RestContext.response != null) {
        String requestJson = RestContext.request.requestBody.toString();
        if (String.isNotBlank(requestJson)) {
          //Fullfillment response for Dialogflow CX
          String dialogflowFullFillmentResponse = RESPONSE;
          RestContext.response.addHeader('Content-Type', 'application/json');
          RestContext.response.responseBody = Blob.valueOf(dialogflowFullFillmentResponse);
        } else {
          String dialogflowFullFillmentResponseNoRecordFound;
          dialogflowFullFillmentResponseNoRecordFound = '{"sessionInfo":{"parameters":{"is_notified":"false"}}}';
          RestContext.response.addHeader('Content-Type', 'application/json');
          RestContext.response.responseBody = Blob.valueOf(dialogflowFullFillmentResponseNoRecordFound);
        }
      }
    }

    public String getSendVerificationCodeResponse(String messageaction, String recordName, String fromPhone, String toPhone, Id filteredRecordId) {
      String dialogflowFullFillmentResponse = '';
      Boolean is_notified = false, isResend = false;
      //Generate OTP
      String verificationcode = DialogFlow_Helper.generateVerificationCode();
      //Send Verification Code SMS
      Activity__c createdActivity = DialogFlow_Helper.sendVerificationCodetoMember(isResend, verificationcode, fromPhone, toPhone, filteredRecordId);
      if (createdActivity != null) {
        is_notified = true;
      }
      dialogflowFullFillmentResponse = '{"sessionInfo":{"parameters":{"is_notified":"' + is_notified + '","verificationcode":"' + verificationcode + '"}}}';

      return dialogflowFullFillmentResponse;
    }

    public String getSendAppointmentSchedulingResponse(String messageaction, String appointmentLink, String recordName, String fromPhone, String toPhone, Id filteredRecordId) {
      String dialogflowFullFillmentResponse = '';
      Boolean is_notified = false;
      String messagebody = '';
      if (languageCode == 'es') {
        messagebody = 'Hola ' + recordName + ', Utilice el siguiente enlace para reservar una cita:\n' + appointmentLink;
      } else {
        messagebody = 'Hi ' + recordName + ', Please use the following link to Book a Appointment:\n' + appointmentLink;
      }
      //Send Book Appointment Notification SMS
      Activity__c createdActivity = DialogFlow_Helper.sendNotificationtoMember(messageaction, messagebody, fromPhone, toPhone, filteredRecordId);
      if (createdActivity != null) {
        is_notified = true;
      }

      dialogflowFullFillmentResponse = '{"sessionInfo":{"parameters":{"is_notified":"' + is_notified + '","appointment_scheduling_link":"' + appointmentLink + '"}}}';

      return dialogflowFullFillmentResponse;
    }

    public String getUpdateProfileResponse(String messageaction, String recordName, String fromPhone, String toPhone, Id filteredRecordId) {
      String dialogflowFullFillmentResponse = '';
      Boolean is_notified = false;
      String profileUpdateLink = DialogFlow_Helper.getProfileUpdateLink(filteredRecordId);

      if (messageaction == 'Update Profile') {
        String messagebody = '';
        if (languageCode == 'es') {
          messagebody = 'Hola ' + recordName + ', Utilice el siguiente enlace para actualizar su perfil:\n' + profileUpdateLink;
        } else {
          messagebody = 'Hi ' + recordName + ', Please use the following link to Update your Profile:\n' + profileUpdateLink;
        }
        //Send Update Profile Notification SMS
        Activity__c createdActivity = DialogFlow_Helper.sendNotificationtoMember(messageaction, messagebody, fromPhone, toPhone, filteredRecordId);
        if (createdActivity != null) {
          is_notified = true;
        }
      }

      dialogflowFullFillmentResponse = '{"sessionInfo":{"parameters":{"is_notified":"' + is_notified + '","profileupdatelink":"' + profileUpdateLink + '"}}}';

      return dialogflowFullFillmentResponse;
    }
}