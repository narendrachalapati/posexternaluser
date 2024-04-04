public without sharing class AuthorizeDOBAPI_SYS_ApplicationService extends SYS_ApplicationService {
  public static String RESPONSE = '';

  public AuthorizeDOBAPI_SYS_ApplicationService() {}

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
    String resource_type = '', sessionString, currentSessionId, objectapiname = 'Account', leadsource = '', salesforcerecorduuid = '', phonenumber = '', dateofbirthString = '', firstname = '', lastname = '', accountname = '', stage = '', loginType = '', authorizeStatusMessage = 'Failed: Unknown Error', salesforceRecordId = '';
    Boolean ignoreLog = false, isauthorized = false;
    List<Account> findAccount = new List<Account>();
    List<Lead> findLead = new List<Lead>();

    Object responseType = JSON.deserializeUntyped(requestBody);
    if (responseType instanceof Map<String, Object>) {
        newflatKeyMap = (SYS_Helper.getFlatKeys(requestBody, 'A.B')); //
        resource_type = newflatKeyMap.containsKey('sessionInfo.parameters.resource_type' ) ? (String) newflatKeyMap.get('sessionInfo.parameters.resource_type') : resource_type;
        leadsource = newflatKeyMap.containsKey( 'sessionInfo.parameters.leadsource' ) ? (String) newflatKeyMap.get('sessionInfo.parameters.leadsource') : leadsource;
        phonenumber = newflatKeyMap.containsKey( 'sessionInfo.parameters.phonenumber' ) ? (String) newflatKeyMap.get('sessionInfo.parameters.phonenumber') : phonenumber;
        isauthorized = newflatKeyMap.containsKey( 'sessionInfo.parameters.isauthorized' ) ? (Boolean) newflatKeyMap.get('sessionInfo.parameters.isauthorized') : isauthorized;
        dateofbirthString = newflatKeyMap.containsKey( 'sessionInfo.parameters.dateofbirth' ) ? (String) newflatKeyMap.get('sessionInfo.parameters.dateofbirth') : dateofbirthString;
        firstname = newflatKeyMap.containsKey('sessionInfo.parameters.firstname') ? (String) newflatKeyMap.get('sessionInfo.parameters.firstname') : firstname;
        lastname = newflatKeyMap.containsKey('sessionInfo.parameters.lastname') ? (String) newflatKeyMap.get('sessionInfo.parameters.lastname') : lastname;

        salesforcerecorduuid = newflatKeyMap.containsKey( 'sessionInfo.parameters.salesforcerecorduuid' ) ? (String) newflatKeyMap.get( 'sessionInfo.parameters.salesforcerecorduuid' ) : salesforcerecorduuid;
        salesforcerecorduuid = (salesforcerecorduuid != 'null') ? salesforcerecorduuid : '';
        objectapiname = newflatKeyMap.containsKey( 'sessionInfo.parameters.objectapiname' ) ? (String) newflatKeyMap.get('sessionInfo.parameters.objectapiname') : objectapiname;

        sessionString = newflatKeyMap.containsKey('sessionInfo.session') ? (String) newflatKeyMap.get('sessionInfo.session') : '';
        currentSessionId = String.isNotBlank(sessionString) ? sessionString.substringAfterLast('sessions/') : '';
    }
    if (String.isNotBlank(resource_type) && (!newflatKeyMap.isEmpty())) {
        loginType = leadsource;
        // findAccount = DialogFlow_Helper.findAccount( salesforceRecordId, phonenumber, firstname, lastname, dateofbirthString );
        MemberService.Member memberinfo = DialogFlow_Helper.findAccount( salesforcerecorduuid, phonenumber, firstname, lastname, dateofbirthString );
        //Found Matching Account Ignore the log and return fullfillment response
        if (memberinfo != NULL && memberinfo.memberRecord != NULL && memberinfo.memberRecord instanceOf Account) {
            authorizeStatusMessage = 'Success';
            isauthorized = true;
            salesforceRecordId = memberinfo.Id;
            objectapiname = 'Account';
            firstname = memberinfo.FirstName;
            firstname = String.isNotBlank(firstname) ? firstname : '';
            lastname = memberinfo.LastName;
            lastname = String.isNotBlank(lastname) ? lastname : '';
            phonenumber = memberinfo.PhoneNumberFormatted;

            DialogFlow_Helper.storeLoginAttempt(salesforceRecordId,loginType,authorizeStatusMessage,phonenumber);

            ((Map<String, Object>) responseType).put('isauthorized', true);
            ((Map<String, Object>) responseType).put('loginstatus', authorizeStatusMessage);
            ((Map<String, Object>) responseType).put('salesforceRecordId', memberinfo.Id);
            ((Map<String, Object>) responseType).put('objectapiname', 'Account');
            //Create List of Account Json to match DOB
            requestBody = JSON.serialize(responseType);

            //Fullfillment response for Dialogflow CX
            RESPONSE = '{"sessionInfo":{"parameters":{"currentSessionId":"' + currentSessionId + '","isauthorized":' + isauthorized + ',"salesforceRecordId":"' + salesforceRecordId + '","objectapiname":"' + objectapiname + '","firstname":"' + firstname + '","lastname":"' + lastname + '","phonenumber":"' + phonenumber + '"}}}';
        }
        else if (memberinfo != NULL && memberinfo.memberRecord != NULL && memberinfo.memberRecord instanceOf Contact) {
            
        }
        else {
            //Not Found Matching Account For Authorize //
            isauthorized = false;
            salesforceRecordId = '';
            objectapiname = 'Account';
            authorizeStatusMessage = 'Invalid Date of Birth';

            ((Map<String, Object>) responseType).put('isauthorized', false);
            ((Map<String, Object>) responseType).put('loginstatus', authorizeStatusMessage);
            ((Map<String, Object>) responseType).put('salesforceRecordId', '');
            ((Map<String, Object>) responseType).put('objectapiname', 'Account');
            requestBody = JSON.serialize(responseType);

            //Fullfillment response for Dialogflow CX
            RESPONSE = '{"sessionInfo":{"parameters":{"currentSessionId":"' + currentSessionId + '","isauthorized":' + isauthorized + ',"salesforceRecordId":"' + salesforceRecordId + '","objectapiname":"' + objectapiname + '"}}}';
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
    SYS_IntegrationLog__c responseLog = (SYS_DataCacheFactory.log != null)? SYS_DataCacheFactory.log: new SYS_IntegrationLog__c();
    String recordWhattId = (responseLog?.whatid__c != null)? responseLog.whatid__c: null;
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
          RestContext.response.responseBody = Blob.valueOf( dialogflowFullFillmentResponse );
        } else {
          RestContext.response.responseBody = Blob.valueOf(requestJson);
        }
      } else {
        RestContext.response.responseBody = Blob.valueOf(requestJson);
      }
    }
  }
}