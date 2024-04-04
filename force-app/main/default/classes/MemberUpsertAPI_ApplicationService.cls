public without sharing class MemberUpsertAPI_ApplicationService extends SYS_ApplicationService {

    public static String RESPONSE = '';

    public MemberUpsertAPI_ApplicationService() {}

    /**
     * This hook is called from each of the hook for Http Verb processing
     * Arguement: Http Verb - POST,GET,PATCH,DELETE,PUT
     * Relies on Integration Setting in DataCache and RestContext
     * Override if custom log generation is required
     */
    public override List<SYS_IntegrationLog__c> generateLogForWebhookReq( String method ) {
    String requestBody = RestContext.request.requestBody.toString();
    SYS_IntegrationLog__c log = new SYS_IntegrationLog__c();
    List<SYS_IntegrationLog__c> logAfterPartition = new List<SYS_IntegrationLog__c>();

    //Deserilize JSON and Map Keys for DialogFlow Json
    Map<String, Object> newflatKeyMap = new Map<String, Object>();
    String resource_path = '', sessionString, currentSessionId, leadsource = '', salesforcerecorduuid = '', phonenumber = '', dateofbirthString = '', firstname = '', lastname = '', accountname = '', stage = '';
    Boolean ignoreLog = true, ismemberfound = false, isphoneverified = false;
    List<Account> findAccount = new List<Account>();

    Object responseType = JSON.deserializeUntyped(requestBody);
    if (responseType instanceof Map<String, Object>) {
        newflatKeyMap = (SYS_Helper.getFlatKeys(requestBody, 'A.B')); //
        resource_path = newflatKeyMap.containsKey( 'sessionInfo.parameters.resource_path' ) ? (String) newflatKeyMap.get('sessionInfo.parameters.resource_path') : resource_path;
        leadsource = newflatKeyMap.containsKey( 'sessionInfo.parameters.leadsource' ) ? (String) newflatKeyMap.get('sessionInfo.parameters.leadsource') : leadsource;
        stage = newflatKeyMap.containsKey('sessionInfo.parameters.stage') ? (String) newflatKeyMap.get('sessionInfo.parameters.stage') : stage;
        Object isphoneverified_obj = newflatKeyMap.containsKey( 'sessionInfo.parameters.isphoneverified' ) ? newflatKeyMap.get('sessionInfo.parameters.isphoneverified') : null;
        isphoneverified = (isphoneverified_obj instanceof Boolean) ?
                (Boolean) isphoneverified_obj :
                ( (isphoneverified_obj instanceof String) ? Boolean.valueOf(String.valueOf(isphoneverified_obj).equalsIgnoreCase('true')) : false);

        phonenumber = newflatKeyMap.containsKey( 'sessionInfo.parameters.phonenumber' ) ? (String) newflatKeyMap.get('sessionInfo.parameters.phonenumber') : phonenumber;
        firstname = newflatKeyMap.containsKey('sessionInfo.parameters.firstname') ? (String) newflatKeyMap.get('sessionInfo.parameters.firstname') : firstname;
        lastname = newflatKeyMap.containsKey('sessionInfo.parameters.lastname') ? (String) newflatKeyMap.get('sessionInfo.parameters.lastname') : lastname;
        firstname = (firstname != 'null') ? firstname : '';
        lastname = (lastname != 'null') ? lastname : '';
        dateofbirthString = newflatKeyMap.containsKey( 'sessionInfo.parameters.dateofbirth' ) ? (String) newflatKeyMap.get('sessionInfo.parameters.dateofbirth') : dateofbirthString;
        salesforcerecorduuid = newflatKeyMap.containsKey( 'sessionInfo.parameters.salesforcerecorduuid' ) ? (String) newflatKeyMap.get( 'sessionInfo.parameters.salesforcerecorduuid' ) : salesforcerecorduuid;
        salesforcerecorduuid = (salesforcerecorduuid != 'null') ? salesforcerecorduuid : '';

        sessionString = newflatKeyMap.containsKey('sessionInfo.session') ? (String) newflatKeyMap.get('sessionInfo.session') : '';
        currentSessionId = String.isNotBlank(sessionString) ? sessionString.substringAfterLast('sessions/') : '';
    }
    if (String.isNotBlank(resource_path) && (!newflatKeyMap.isEmpty())) {
        MemberService.Member memberinfo = DialogFlow_Helper.findAccount( salesforcerecorduuid, phonenumber, firstname, lastname, dateofbirthString );
        sObject updateMember;
        //Found Matching Account Ignore the log and return fullfillment response
        if (memberinfo != NULL && memberinfo.memberRecord != NULL && memberinfo.memberRecord instanceOf Account) {
            updateMember = new Account();
            ((Account)updateMember).Id = (String)memberinfo.memberRecord.get('Id');
            if (String.isNotBlank(salesforcerecorduuid)) {
                ((Account)updateMember).put('UUID__c', salesforcerecorduuid);
            }
            if (String.isNotBlank(stage)) {
                ((Account)updateMember).put('Stage__c', stage);
            }
            ((Account)updateMember).put('Phone_Verified__c', isphoneverified);

            accountname = (String.isNotBlank(firstname) ? firstname : '') + '' + (String.isNotBlank(lastname) ? ' ' + lastname : '');
            ((Account)updateMember).put('Name',  String.isNotBlank(accountname) ? accountname : phonenumber);
            ((Account)updateMember).put('First_Name__c', firstname);
            ((Account)updateMember).put('Last_Name__c', lastname);
            if (String.isNotBlank(dateofbirthString)) {
                ((Account)updateMember).put('Date_of_Birth__c', Date.valueOf(dateofbirthString));
            }
            if (String.isNotBlank(phonenumber)) {
                ((Account)updateMember).put('Phone', phonenumber);
            }

            update ((Account)updateMember);

            // Refetch Created Record
            memberinfo = DialogFlow_Helper.findAccount( (String)updateMember.get('Id'), '', '', '','' );
            salesforcerecorduuid = memberinfo.uuid;
            firstname = memberinfo.FirstName;
            lastname = memberinfo.LastName;
            accountname = memberinfo.Name;
            phonenumber = memberinfo.PhoneNumberFormatted;
            ismemberfound = true;

            //Fullfillment response for Dialogflow CX
            RESPONSE = '{"sessionInfo":{"parameters":{"currentSessionId":"' + currentSessionId + '","ismemberfound":' + ismemberfound + ',"salesforcerecorduuid":"' + salesforcerecorduuid + '","accountname":"' + accountname + '","stage":"' + stage + '","isphoneverified":' + isphoneverified + ',"firstname":"' + firstname + '","lastname":"' + lastname + '","phonenumber":"' + phonenumber + '"}}}';
        } else if (memberinfo != NULL && memberinfo.memberRecord != NULL && memberinfo.memberRecord instanceOf Contact) {
            updateMember = new Contact();
            ((Contact)updateMember).Id = (String)memberinfo.memberRecord.get('Id');
            if (String.isNotBlank(salesforcerecorduuid)) {
                ((Contact)updateMember).put('UUID__c', salesforcerecorduuid );
            }
            if (String.isNotBlank(stage)) {
                ((Contact)updateMember).put('Stage__c', stage);
            }
            ((Contact)updateMember).put('Phone_Verified__c', isphoneverified);

            accountname = (String.isNotBlank(firstname) ? firstname : '') + '' + (String.isNotBlank(lastname) ? ' ' + lastname : '');
            ((Contact)updateMember).put('FirstName', firstname);
            ((Contact)updateMember).put('LastName', lastname);
            if (String.isNotBlank(dateofbirthString)) {
                ((Contact)updateMember).put('Birthdate', Date.valueOf(dateofbirthString));
            }
            if (String.isNotBlank(phonenumber)) {
                ((Contact)updateMember).put('Phone_Number__c', phonenumber);
            }

            update ((Contact)updateMember);

            // Refetch Created Record
            memberinfo = DialogFlow_Helper.findAccount( (String)updateMember.get('Id'), '', '', '','' );
            salesforcerecorduuid = memberinfo.uuid;
            firstname = memberinfo.FirstName;
            lastname = memberinfo.LastName;
            accountname = firstname+' '+lastname;
            phonenumber = memberinfo.PhoneNumberFormatted;
            ismemberfound = true;

            //Fullfillment response for Dialogflow CX
            RESPONSE = '{"sessionInfo":{"parameters":{"currentSessionId":"' + currentSessionId + '","ismemberfound":' + ismemberfound + ',"salesforcerecorduuid":"' + salesforcerecorduuid + '","accountname":"' + accountname + '","stage":"' + stage + '","isphoneverified":' + isphoneverified + ',"firstname":"' + firstname + '","lastname":"' + lastname + '","phonenumber":"' + phonenumber + '"}}}';
        }
        else {
            //Not Found Matching Account // TODO Handle if Account was Deleted
            //Fullfillment response for Dialogflow CX
            RESPONSE = '{"sessionInfo":{"parameters":{"currentSessionId":"' + currentSessionId + '","ismemberfound":' + ismemberfound + ',"salesforcerecorduuid":"' + salesforcerecorduuid + '","accountname":"' + accountname + '","stage":"' + stage + '","isphoneverified":' + isphoneverified + ',"firstname":"' + firstname + '","lastname":"' + lastname + '","phonenumber":"' + phonenumber + '"}}}';
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